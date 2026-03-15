extends CharacterBody2D
class_name Paddle

@export_enum("Player 1", "Player 2") var player_index: int = 0

@export var max_speed        : float = 600.0
@export var acceleration     : float = 3500.0
@export var friction         : float = 2000.0
@export var max_hits         : int   = 2
@export var overload_timeout : float = 3.0

const SHEET_SIZE    := 48
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
	sprite.region_rect.position.y = SHEET_SIZE
	play_animation(0.08)
	await get_tree().create_timer(overload_timeout).timeout
	
	reset_paddle_charge()
	main.reset_paddle_hit_count(player_index)
	_is_overloaded = false

func next_paddle_charge() -> void:
	var rect := sprite.region_rect
	rect.position.x = int(rect.position.x + SHEET_SIZE) % (3 * SHEET_SIZE)
	sprite.region_rect = rect

func play_animation(frame_time: float)->void:
	var elapsed := 0.0
	var x:int = 0
	while elapsed < overload_timeout:
		x=(x+1)%3
		sprite.region_rect.position.x = x*SHEET_SIZE
		
		await get_tree().create_timer(frame_time).timeout
		elapsed += frame_time

	sprite.region_rect.position.x = 0

func reset_paddle_charge() -> void:
	sprite.region_rect.position = Vector2(0,0)
