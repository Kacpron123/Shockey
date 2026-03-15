extends Area2D

@onready var main : Node2D = get_parent().get_parent()

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("puck"):
		main.player_scored(0)
