extends CharacterBody2D
class_name Paddle

@export_enum("Player 1", "Player 2") var player_index: int = 0

@export var max_speed        : float = 600.0
@export var acceleration     : float = 3500.0
@export var friction         : float = 2000.0
@export var max_hits         : int   = 3
@export var overload_timeout : float = 3.0

const TABLE_WIDTH   := 1280
const TABLE_HEIGHT  := 640
const PADDLE_RADIUS := 32
const WALL_SIZE     := 32

var bound_left   : float
var bound_right  : float
var bound_top    : float = 32.0 + PADDLE_RADIUS
var bound_bottom : float = TABLE_HEIGHT - 32.0 - PADDLE_RADIUS

@onready var main : Node2D = get_parent()
@onready var sprite : Sprite2D = get_node("Sprite") 

var _is_overloaded : bool = false

func _ready() -> void:
	if player_index == 0:
		bound_left  = 0.0 + PADDLE_RADIUS + WALL_SIZE
		bound_right = TABLE_WIDTH / 2.0 - PADDLE_RADIUS
	else:
		bound_left  = TABLE_WIDTH / 2.0 + PADDLE_RADIUS
		bound_right = TABLE_WIDTH - PADDLE_RADIUS - WALL_SIZE

func _physics_process(delta: float) -> void:
	if not _is_overloaded and main.get_paddle_hit_count(player_index) >= max_hits:
		_trigger_overload()
	
	if _is_overloaded:
		velocity = Vector2.ZERO
		return

	var current_hits = main.get_paddle_hit_count(player_index)
	if current_hits > 0:
		if global_position.y <= bound_top:
			main.reset_paddle_hit_count(player_index)
			reset_paddle_charge()
		elif global_position.y >= bound_bottom:
			main.reset_paddle_hit_count(player_index)
			reset_paddle_charge()

	var prefix = "p1_" if player_index == 0 else "p2_"
	var dir := Input.get_vector(prefix + "left", prefix + "right", prefix + "up", prefix + "down")
	
	if dir != Vector2.ZERO:
		velocity = velocity.move_toward(dir * max_speed, acceleration * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
	
	move_and_slide()
	
	global_position.x = clamp(global_position.x, bound_left, bound_right)
	global_position.y = clamp(global_position.y, bound_top, bound_bottom)

func _trigger_overload() -> void:
	_is_overloaded = true
	await get_tree().create_timer(overload_timeout).timeout
	sprite.region_rect.position.x = 0
		
	main.reset_paddle_hit_count(player_index)
	_is_overloaded = false

func next_paddle_charge() -> void:
	var frame_width = sprite.texture.get_width() / 4.0
	sprite.region_rect.position.x += frame_width

func reset_paddle_charge() -> void:
	sprite.region_rect.position.x = 0
