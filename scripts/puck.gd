extends RigidBody2D

@export var min_speed : float = 200.0
@export var max_speed : float = 1000.0

@onready var main : Node2D = get_parent()

func _ready() -> void:
	contact_monitor = true
	max_contacts_reported = 4
	body_entered.connect(_on_body_entered)

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	# FIX weird ass puck/paddle interaction
	for i in state.get_contact_count():
		var body : Object = state.get_contact_collider_object(i)
		if body == null: continue
		if body.is_in_group("paddles"):
			var paddle_vel : Vector2 = body.velocity if "velocity" in body else Vector2.ZERO
			var normal  : Vector2 = (global_position - body.global_position).normalized()
			var rel_vel : Vector2 = state.linear_velocity - paddle_vel
			var dot     : float   = rel_vel.dot(normal)
			if dot < 0: state.linear_velocity = (rel_vel - 2.0 * dot * normal) + paddle_vel
		elif body.is_in_group("walls"):
			var normal : Vector2 = state.get_contact_local_normal(i)
			var dot    : float   = state.linear_velocity.dot(normal)
			if dot < 0: state.linear_velocity -= 2.0 * dot * normal
	var spd : float = state.linear_velocity.length()
	if spd > 0.1 and spd < min_speed:
		state.linear_velocity = state.linear_velocity.normalized() * min_speed
	elif spd > max_speed:
		state.linear_velocity = state.linear_velocity.normalized() * max_speed

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("paddles"):
		main.on_puck_hit_paddle(0 if body.name == "Paddle1" else 1)
	elif body.is_in_group("walls"):
		main.on_puck_hit_wall()
