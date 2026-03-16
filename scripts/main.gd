extends Node2D

const SCORE_TO_WIN    := 7
const PUCK_RESET_DELAY := 1.2
const TABLE_WIDTH     := 1280
const TABLE_HEIGHT    :=  640

var score      := [0, 0]
var hit_count  := [0, 0]
var hit_bool   := [false, true]
var game_active := true

@onready var toprail : AnimatedSprite2D = $Table/TopRail
@onready var bottomrail : AnimatedSprite2D = $Table/BottomRail
@onready var paddle1animation : AnimatedSprite2D = $Paddle1/PaddleAnimation
@onready var paddle2animation : AnimatedSprite2D = $Paddle2/PaddleAnimation
@onready var puckanimation : AnimatedSprite2D = $Puck/PuckAnimation

@onready var puck            : RigidBody2D       = $Puck
@onready var paddle1         : CharacterBody2D   = $Paddle1
@onready var paddle2         : CharacterBody2D   = $Paddle2

@onready var label_p1        : Label             = $UI/ScoreP1
@onready var label_p2        : Label             = $UI/ScoreP2
@onready var winner_p1 : Label             = $UI/WinnerP1
@onready var winner_p2 : Label             = $UI/WinnerP2

@onready var sfx_goal        : AudioStreamPlayer = $SFX/GoalSound
@onready var sfx_hit         : AudioStreamPlayer = $SFX/HitSound
@onready var sfx_discharge        : AudioStreamPlayer = $SFX/DischargeSound
@onready var sfx_overload         : AudioStreamPlayer = $SFX/OverloadSound

func _ready() -> void:
	toprail.animation_finished.connect(_toprail_af)
	bottomrail.animation_finished.connect(_bottomrail_af)
	paddle1animation.animation_finished.connect(_paddle1animation_af)
	paddle2animation.animation_finished.connect(_paddle2animation_af)
	puckanimation.animation_finished.connect(_puckanimation_af)
	
	toprail.play("Default")
	bottomrail.play("Default")
	paddle1animation.play("Default")
	paddle2animation.play("Default")
	puckanimation.play("Default")
	
	winner_p1.visible = false
	winner_p2.visible = false
	_reset_puck(0)

func _toprail_af(): toprail.play("Default")
func _bottomrail_af(): bottomrail.play("Default")
func _paddle1animation_af(): paddle1animation.play("Default")
func _paddle2animation_af(): paddle2animation.play("Default")
func _puckanimation_af(): puckanimation.play("Default")

func player_scored(player_index: int) -> void:
	if not game_active: return
	game_active = false
	score[ player_index ] += 1
	sfx_goal.play()
	if score[player_index] >= SCORE_TO_WIN:
		_end_game(player_index)
	else:
		_reset_puck(0 if player_index == 1 else 1)
	for i in 3:
		$Table/Center/fill.visible = true
		await get_tree().create_timer(0.2).timeout
		$Table/Center/fill.visible = false
		await get_tree().create_timer(0.1).timeout
	$Table/Center/fill.visible = false

func get_paddle_hit_count(player_index: int) -> int:
	return hit_count[player_index]
func reset_paddle_hit_count(player_index: int) -> void:
	hit_count[player_index] = 0

func on_paddle_hit_rail(rail_index: int) -> void:
	if rail_index == 0:
		toprail.play("Discharge")
	else: 
		bottomrail.play("Discharge")
	sfx_discharge.play()

func on_puck_hit_paddle(player_index: int) -> void: 
	var other_index = 0 if player_index == 1 else 1
	if (!hit_bool[player_index] and hit_bool[other_index]): 
		hit_bool[player_index] = true
		hit_bool[other_index] = false
		hit_count[player_index] += 1
		if player_index == 0:
			paddle1animation.play("Hit")
		else:
			paddle2animation.play("Hit")
		if hit_count[player_index] == 4:
			reset_paddle_hit_count(player_index)
	sfx_hit.play()

func on_puck_hit_wall()   -> void: 
	sfx_hit.play()

func _reset_puck(towards_player: int) -> void:
	hit_bool = [false, false]
	hit_bool[towards_player] = true
	hit_count = [0, 0]
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
	await get_tree().create_timer(3.0).timeout
	get_tree().change_scene_to_file("res://scenes/title.tscn")

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept") or (event is InputEventKey and event.keycode == KEY_R):
		get_tree().reload_current_scene()

func show_hit_count_p1(hit_count_p1: int) -> void:
	$UI/HCP1C0.visible = false
	$UI/HCP1C1.visible = false
	$UI/HCP1C2.visible = false
	$UI/HCP1C3.visible = false
	self.get_node("UI/HCP1C" + str(hit_count_p1)).visible = true
	
func show_hit_count_p2(hit_count_p2: int) -> void:
	$UI/HCP2C0.visible = false
	$UI/HCP2C1.visible = false
	$UI/HCP2C2.visible = false
	$UI/HCP2C3.visible = false
	self.get_node("UI/HCP2C" + str(hit_count_p2)).visible = true

func _process(delta: float) -> void:
	# use charge bar
	label_p1.text = str(score[0])
	label_p2.text = str(score[1])
	show_hit_count_p1(hit_count[0])
	show_hit_count_p2(hit_count[1])
