extends CharacterBody2D

signal crashed

const BASE_SPEED := 390.0
const GRAVITY := 2200.0
const JUMP_FORCE := -760.0
const MAX_FALL_SPEED := 1200.0

var speed_multiplier := 1.0
var alive := true

func _physics_process(delta: float) -> void:
	if not alive:
		return

	velocity.x = BASE_SPEED * speed_multiplier
	velocity.y = minf(velocity.y + GRAVITY * delta, MAX_FALL_SPEED)

	move_and_slide()

	if is_on_floor():
		rotation = snappedf(rotation, PI / 2.0)
	else:
		rotation += 7.8 * delta

func try_jump() -> void:
	if alive and is_on_floor():
		velocity.y = JUMP_FORCE

func reset_player(start_position: Vector2) -> void:
	alive = true
	global_position = start_position
	velocity = Vector2.ZERO
	rotation = 0.0
	speed_multiplier = 1.0

func die() -> void:
	if not alive:
		return

	alive = false
	velocity = Vector2.ZERO
	crashed.emit()
