extends CharacterBody2D

signal crashed

const CONFIG := preload("res://scripts/GameConfig.gd")

var speed_multiplier := 1.0
var alive := true
var coyote_timer := 0.0
var jump_buffer_timer := 0.0
var jump_held := false
var active_jump_orb: Area2D = null
var used_jump_orb: Area2D = null
var floor_rotation_lock_timer := 0.0
var wall_stuck_timer := 0.0
var previous_x := 0.0

func _physics_process(delta: float) -> void:
	if not alive:
		return

	previous_x = global_position.x
	velocity.x = CONFIG.RUN_SPEED * speed_multiplier
	velocity.y = minf(velocity.y + CONFIG.GRAVITY * delta, CONFIG.MAX_FALL_SPEED)

	if is_on_floor():
		coyote_timer = CONFIG.COYOTE_TIME
	else:
		coyote_timer = maxf(coyote_timer - delta, 0.0)

	jump_buffer_timer = maxf(jump_buffer_timer - delta, 0.0)
	if jump_buffer_timer > 0.0 and coyote_timer > 0.0:
		_jump()
	elif jump_held and is_on_floor():
		_jump()

	move_and_slide()
	_check_wall_stuck(delta)

	if is_on_floor():
		floor_rotation_lock_timer = CONFIG.FLOOR_ROTATION_LOCK_TIME
		rotation = 0.0
	elif floor_rotation_lock_timer > 0.0:
		floor_rotation_lock_timer = maxf(floor_rotation_lock_timer - delta, 0.0)
		rotation = 0.0
	else:
		rotation += 7.8 * delta

func try_jump() -> void:
	if not alive:
		return

	if active_jump_orb != null and active_jump_orb != used_jump_orb:
		orb_jump(active_jump_orb)
		return

	jump_buffer_timer = CONFIG.JUMP_BUFFER_TIME
	if is_on_floor() or coyote_timer > 0.0:
		_jump()

func set_jump_held(is_held: bool) -> void:
	jump_held = is_held
	if is_held:
		try_jump()

func _jump() -> void:
	velocity.y = CONFIG.JUMP_FORCE
	coyote_timer = 0.0
	jump_buffer_timer = 0.0

func orb_jump(orb: Area2D) -> void:
	if not alive:
		return

	velocity.y = CONFIG.ORB_JUMP_FORCE
	coyote_timer = 0.0
	jump_buffer_timer = 0.0
	used_jump_orb = orb

func _check_wall_stuck(delta: float) -> void:
	var actual_x_speed := (global_position.x - previous_x) / maxf(delta, 0.0001)
	if is_on_wall() and actual_x_speed < CONFIG.WALL_STUCK_MIN_SPEED:
		wall_stuck_timer += delta
	else:
		wall_stuck_timer = 0.0

	if wall_stuck_timer >= CONFIG.WALL_STUCK_KILL_TIME:
		die()

func enter_jump_orb(orb: Area2D) -> void:
	active_jump_orb = orb
	if jump_held and used_jump_orb != orb:
		orb_jump(orb)

func exit_jump_orb(orb: Area2D) -> void:
	if active_jump_orb == orb:
		active_jump_orb = null
	if used_jump_orb == orb:
		used_jump_orb = null

func reset_player(start_position: Vector2) -> void:
	alive = true
	global_position = start_position
	velocity = Vector2.ZERO
	rotation = 0.0
	speed_multiplier = 1.0
	coyote_timer = 0.0
	jump_buffer_timer = 0.0
	jump_held = false
	active_jump_orb = null
	used_jump_orb = null
	floor_rotation_lock_timer = 0.0
	wall_stuck_timer = 0.0
	previous_x = start_position.x

func die() -> void:
	if not alive:
		return

	alive = false
	velocity = Vector2.ZERO
	crashed.emit()
