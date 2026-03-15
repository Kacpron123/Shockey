extends Area2D
class_name Goal

@onready var main : Node2D = get_parent().get_parent()
@export_enum("Player 1", "Player 2") var player_index: int = 0

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("puck"):
		main.player_scored(player_index)
