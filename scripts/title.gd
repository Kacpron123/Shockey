extends Node2D

func _ready() -> void:
	$Buttons/StartButton.pressed.connect(_start_button_pressed)
	$Buttons/QuitButton.pressed.connect(_quit_button_pressed) 

func _process(delta: float) -> void:
	pass

func _start_button_pressed() -> void:
	# play scene change animation
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func _quit_button_pressed() -> void:
	get_tree().quit()
