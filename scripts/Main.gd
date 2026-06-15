extends Node2D

const CONFIG := preload("res://scripts/GameConfig.gd")
const GROUND_Y := 520.0
const START_POSITION := Vector2(180, 456)
const BLOCK_SIZE := Vector2(96, 48)
const LEVEL_LENGTH := 7200.0

@onready var world: Node2D = $World
@onready var player: CharacterBody2D = $World/Player
@onready var camera: Camera2D = $World/Camera2D
@onready var stats_label: Label = $UI/HudPanel/Stats
@onready var message_label: Label = $UI/Message

var game_over := false
var best_distance := 0
var camera_x := CONFIG.CAMERA_START_X

func _ready() -> void:
	player.crashed.connect(_on_player_crashed)
	_build_level()
	_start_run()

func _process(delta: float) -> void:
	if game_over:
		return

	var distance := maxf(0.0, player.global_position.x - START_POSITION.x)
	player.speed_multiplier = 1.0
	camera_x += CONFIG.RUN_SPEED * delta
	camera.global_position = Vector2(camera_x, CONFIG.CAMERA_Y)
	best_distance = maxi(best_distance, int(distance / 10.0))
	stats_label.text = "%dm  |  Speed 1.00x" % int(distance / 10.0)

	if player.global_position.y > 820.0:
		player.die()

	if distance >= LEVEL_LENGTH:
		game_over = true
		player.alive = false
		message_label.text = "Level Clear\nPress R to run again"

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_SPACE or event.keycode == KEY_UP or event.keycode == KEY_W:
			player.set_jump_held(true)
			if game_over:
				_start_run()
			else:
				player.try_jump()
		elif event.keycode == KEY_R:
			_start_run()
	elif event is InputEventKey and not event.pressed:
		if event.keycode == KEY_SPACE or event.keycode == KEY_UP or event.keycode == KEY_W:
			player.set_jump_held(false)
	elif event is InputEventMouseButton and event.pressed:
		if game_over:
			_start_run()

func _start_run() -> void:
	game_over = false
	player.reset_player(START_POSITION)
	camera_x = CONFIG.CAMERA_START_X
	camera.global_position = Vector2(camera_x, CONFIG.CAMERA_Y)
	stats_label.text = "0m  |  Speed 1.00x"
	message_label.text = "Space / Up / W to jump"
	await get_tree().create_timer(1.0).timeout
	if not game_over:
		message_label.text = ""

func _on_player_crashed() -> void:
	game_over = true
	message_label.text = "Crashed at %dm\nPress R / Space / Click to retry" % best_distance

func _build_level() -> void:
	_create_background()
	_create_floor(-320.0, LEVEL_LENGTH + 1600.0)

	var spike_positions := [
		720.0, 920.0, 1260.0, 1680.0, 1780.0, 2240.0, 2580.0,
		3010.0, 3330.0, 3660.0, 3780.0, 4260.0, 4720.0, 5120.0,
		5480.0, 5800.0, 6120.0, 6240.0, 6600.0
	]
	for x in spike_positions:
		_create_spike(Vector2(x, GROUND_Y))

	var block_runs := [
		Vector2(1120.0, GROUND_Y - 84.0),
		Vector2(2060.0, GROUND_Y - 136.0),
		Vector2(2148.0, GROUND_Y - 136.0),
		Vector2(2860.0, GROUND_Y - 84.0),
		Vector2(2928.0, GROUND_Y - 132.0),
		Vector2(4380.0, GROUND_Y - 84.0),
		Vector2(4468.0, GROUND_Y - 84.0),
		Vector2(5350.0, GROUND_Y - 132.0),
		Vector2(5438.0, GROUND_Y - 132.0),
		Vector2(5526.0, GROUND_Y - 132.0),
	]
	for block_position in block_runs:
		_create_block(block_position)

	for orb_x in [2400.0, 4950.0]:
		_create_jump_orb(Vector2(orb_x, GROUND_Y - 120.0))

func _create_background() -> void:
	var background := ColorRect.new()
	background.name = "Background"
	background.color = Color(0.02, 0.025, 0.04)
	background.size = Vector2(LEVEL_LENGTH + 2200.0, 900.0)
	background.position = Vector2(-700.0, -120.0)
	world.add_child(background)
	world.move_child(background, 0)

	for i in range(0, 42):
		var bar := ColorRect.new()
		bar.color = Color(0.08, 0.11, 0.18, 0.55)
		bar.size = Vector2(16.0, 900.0)
		bar.position = Vector2(i * 220.0 - 500.0, -120.0)
		world.add_child(bar)

func _create_floor(start_x: float, width: float) -> void:
	var body := StaticBody2D.new()
	body.name = "Floor"
	body.collision_layer = 1
	body.position = Vector2(start_x, GROUND_Y)
	world.add_child(body)

	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(width, 80.0)
	shape.shape = rect
	shape.position = Vector2(width / 2.0, 40.0)
	body.add_child(shape)

	var visual := ColorRect.new()
	visual.color = Color(0.98, 0.78, 0.08)
	visual.size = Vector2(width, 18.0)
	visual.position = Vector2(0.0, -2.0)
	body.add_child(visual)

	var base := ColorRect.new()
	base.color = Color(0.09, 0.10, 0.13)
	base.size = Vector2(width, 80.0)
	base.position = Vector2(0.0, 16.0)
	body.add_child(base)

func _create_block(position: Vector2) -> void:
	var body := StaticBody2D.new()
	body.name = "Block"
	body.collision_layer = 1
	body.position = position
	world.add_child(body)

	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = BLOCK_SIZE
	shape.shape = rect
	shape.position = BLOCK_SIZE / 2.0
	body.add_child(shape)

	var visual := ColorRect.new()
	visual.color = Color(0.20, 0.86, 0.98)
	visual.size = BLOCK_SIZE
	body.add_child(visual)

	var cap := ColorRect.new()
	cap.color = Color(0.90, 0.96, 1.0)
	cap.size = Vector2(BLOCK_SIZE.x, 8.0)
	body.add_child(cap)

func _create_spike(position: Vector2) -> void:
	var spike := Area2D.new()
	spike.name = "Spike"
	spike.collision_layer = 4
	spike.collision_mask = 2
	spike.position = position
	spike.body_entered.connect(_on_hazard_body_entered)
	world.add_child(spike)

	var points := PackedVector2Array([
		Vector2(-34.0, 0.0),
		Vector2(0.0, -72.0),
		Vector2(34.0, 0.0),
	])

	var shape := CollisionPolygon2D.new()
	shape.polygon = points
	spike.add_child(shape)

	var visual := Polygon2D.new()
	visual.polygon = points
	visual.color = Color(1.0, 0.22, 0.39)
	spike.add_child(visual)

func _create_jump_orb(position: Vector2) -> void:
	var orb := Area2D.new()
	orb.name = "JumpOrb"
	orb.collision_layer = 8
	orb.collision_mask = 2
	orb.position = position
	orb.body_entered.connect(_on_orb_body_entered.bind(orb))
	orb.body_exited.connect(_on_orb_body_exited.bind(orb))
	world.add_child(orb)

	var shape := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = 40.0
	shape.shape = circle
	orb.add_child(shape)

	var ring := Line2D.new()
	ring.width = 6.0
	ring.default_color = Color(0.65, 0.95, 1.0, 0.9)
	ring.closed = true
	for i in range(0, 24):
		var angle := TAU * float(i) / 24.0
		ring.add_point(Vector2(cos(angle), sin(angle)) * 38.0)
	orb.add_child(ring)

	var label := Label.new()
	label.text = "+"
	label.position = Vector2(-6.0, -14.0)
	orb.add_child(label)

func _on_hazard_body_entered(body: Node2D) -> void:
	if body == player:
		player.die()

func _on_orb_body_entered(body: Node2D, orb: Area2D) -> void:
	if body == player:
		player.enter_jump_orb(orb)

func _on_orb_body_exited(body: Node2D, orb: Area2D) -> void:
	if body == player:
		player.exit_jump_orb(orb)
