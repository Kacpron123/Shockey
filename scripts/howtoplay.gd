extends Node2D

func _ready() -> void:
	$NextButton.pressed.connect(_next_button_pressed)

func _next_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func _process(delta: float) -> void:
	if not $Theme.playing: $Theme.play()
