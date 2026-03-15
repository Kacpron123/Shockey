extends CharacterBody2D

@export var max_speed        : float = 600.0
@export var acceleration     : float = 3500.0
@export var friction         : float = 2000.0
@export var max_hits         : int   = 3
@export var overload_timeout : float = 3.0

const TABLE_WIDTH   := 1280
const TABLE_HEIGHT  :=  640
const PADDLE_RADIUS := 32
const WALL_SIZE     := 32

const BOUND_LEFT   := TABLE_WIDTH / 2 + PADDLE_RADIUS
const BOUND_RIGHT  := TABLE_WIDTH - PADDLE_RADIUS - WALL_SIZE
const BOUND_TOP    := 32 + PADDLE_RADIUS
const BOUND_BOTTOM := TABLE_HEIGHT - 32 - PADDLE_RADIUS

@onready var main   : Node2D    = get_parent()

var _is_overloaded : bool = false

func _physics_process(delta: float) -> void:
	if not _is_overloaded and main.get_paddle_hit_count(1) >= max_hits: _trigger_overload()
	if _is_overloaded: return
	if global_position.y <= BOUND_TOP and main.get_paddle_hit_count(1) > 0:
		main.reset_paddle_hit_count(1)
		main.on_paddle_hit_rail(0)
		$Paddle2Animation.play("Discharge")
	if global_position.y >= BOUND_BOTTOM and main.get_paddle_hit_count(1) > 0:
		main.reset_paddle_hit_count(1)
		main.on_paddle_hit_rail(1)
		$Paddle2Animation.play("Discharge")
	var dir := Vector2.ZERO
	if Input.is_action_pressed("p2_up"):    dir.y -= 1
	if Input.is_action_pressed("p2_down"):  dir.y += 1
	if Input.is_action_pressed("p2_left"):  dir.x -= 1
	if Input.is_action_pressed("p2_right"): dir.x += 1
	dir = dir.normalized()
	if dir != Vector2.ZERO: velocity = velocity.move_toward(dir * max_speed, acceleration * delta)
	else: velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
	move_and_collide(velocity * delta)
	position = position.clamp(Vector2(BOUND_LEFT, BOUND_TOP), Vector2(BOUND_RIGHT, BOUND_BOTTOM))

func _trigger_overload() -> void:
	_is_overloaded = true
	main.get_node("SFX/OverloadSound").play()
	$Paddle2Animation.play("Overload")
	await get_tree().create_timer(overload_timeout).timeout
	main.reset_paddle_hit_count(1)
	_is_overloaded = false
