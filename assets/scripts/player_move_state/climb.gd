class_name Climb extends PlayerState

var new_position: Vector3
var should_move_forward: bool = false


func enter(msg := {}) -> void:
	player.gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
	new_position = msg["ledge_position"]
	new_position = Vector3(new_position.x, new_position.y + 0.1, new_position.z)


func handle_input(event: InputEvent) -> void:
	if event.is_action_released("jump"):
		player.setup_can_climb_timer()
		state_machine.transition_to(state_machine.movement_state[state_machine.IDLE])


func physics_update(delta: float) -> void:
	var direction = player.global_position.direction_to(new_position)
	
	player.velocity = direction * player.climb_speed * delta
	
	if int(player.global_position.y * 10) in range(new_position.y * 10 - 1, new_position.y * 10):
		state_machine.transition_to(state_machine.movement_state[state_machine.IDLE])
