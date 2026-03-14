extends Node2D

func _ready() -> void:
	$StartButton.pressed.connect(_start_button_pressed)
	$QuitButton.pressed.connect(_quit_button_pressed) 

func _process(delta: float) -> void:
	pass

func _start_button_pressed() -> void:
	# play scene change animation
	get_tree().change_scene_to_file("res://main.tscn")

func _quit_button_pressed() -> void:
	get_tree().quit()
