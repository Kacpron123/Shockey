extends Node2D

const SCORE_TO_WIN    := 7
const PUCK_RESET_DELAY := 1.2
const TABLE_WIDTH     := 1280
const TABLE_HEIGHT    :=  640

var score      := [0, 0]
var hit_count  := [0, 0]
var hit_bool   := [false, true]
var game_active := true

@onready var puck            : RigidBody2D       = $Puck
@onready var paddle1         : Paddle            = $Paddle1
@onready var paddle2         : Paddle            = $Paddle2
@onready var label_p1        : Label             = $UI/ScoreP1
@onready var label_p2        : Label             = $UI/ScoreP2
@onready var winner_p1 : Label             = $UI/WinnerP1
@onready var winner_p2 : Label             = $UI/WinnerP2
@onready var sfx_goal        : AudioStreamPlayer = $SFX/GoalSound
@onready var sfx_hit         : AudioStreamPlayer = $SFX/HitSound
@onready var sfx_wall        : AudioStreamPlayer = $SFX/WallSound

func _ready() -> void:
	winner_p1.visible = false
	winner_p2.visible = false
	_reset_puck(0)

func player_scored(player_index: int) -> void:
	if not game_active: return
	game_active = false
	score[player_index] += 1
	sfx_goal.play()
	if score[player_index] >= SCORE_TO_WIN:
		_end_game(player_index)
	else:
		_reset_puck(0 if player_index == 1 else 1)

func get_paddle_hit_count(player_index: int) -> int:
	return hit_count[player_index]
func reset_paddle_hit_count(player_index: int) -> void:
	hit_count[player_index] = 0

func on_puck_hit_paddle(player_index: int) -> void: 
	# use charge animation
	var other_index = 0 if player_index == 1 else 1
	var target_paddle = paddle1 if player_index == 0 else paddle2
	if (!hit_bool[player_index] and hit_bool[other_index]): 
		hit_bool[player_index] = true
		hit_bool[other_index] = false
		hit_count[player_index] += 1
		target_paddle.next_paddle_charge()
	sfx_hit.play()

func on_puck_hit_wall()   -> void: 
	sfx_wall.play()

func _reset_puck(towards_player: int) -> void:
	hit_bool = [false, false]
	hit_bool[towards_player] = true
	hit_count = [0, 0]
	paddle1.reset_paddle_charge()
	paddle2.reset_paddle_charge()
	var rid := puck.get_rid()
	puck.freeze = true
	PhysicsServer2D.body_set_state(rid, PhysicsServer2D.BODY_STATE_TRANSFORM, Transform2D(0.0, Vector2(TABLE_WIDTH / 2.0, TABLE_HEIGHT / 2.0)))
	PhysicsServer2D.body_set_state(rid, PhysicsServer2D.BODY_STATE_LINEAR_VELOCITY, Vector2.ZERO)
	await get_tree().create_timer(PUCK_RESET_DELAY).timeout
	var x : float = -1.0 if towards_player == 0 else 1.0
	var y : float = 1.0 if randf() > 0.5 else -1.0
	var a : float = deg_to_rad(randf_range(25.0, 55.0))
	puck.freeze = false
	PhysicsServer2D.body_set_state(rid, PhysicsServer2D.BODY_STATE_LINEAR_VELOCITY, Vector2(x * cos(a), y * sin(a)) * 380.0)
	game_active = true

func _end_game(winner: int) -> void:
	game_active = false
	puck.freeze = true
	if winner == 0: winner_p1.visible = true
	else: winner_p2.visible = true

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept") or (event is InputEventKey and event.keycode == KEY_R):
		get_tree().reload_current_scene()
		
	if event.is_action_pressed("ui_cancel"):
		get_tree().change_scene_to_file("res://title.tscn")

func _process(delta: float) -> void:
	# use sprite score and charge bar
	label_p1.text = str(score[0])
	label_p2.text = str(score[1])
	$UI/HitP1.text = str(hit_count[0])
	$UI/HitP2.text = str(hit_count[1])


func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://title.tscn")
