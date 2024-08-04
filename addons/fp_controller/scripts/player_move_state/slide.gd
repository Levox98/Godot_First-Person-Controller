class_name Slide extends PlayerState


## This method is necessary for state machine to be able to transition to state
func enter(_msg := {}) -> void:
	pass


func physics_update(_delta: float) -> void:
	player.velocity = player.velocity.lerp(Vector3.ZERO, .01)
	
	if player.velocity.length() > 1.0 && player.velocity.length() < 2.0:
		state_machine.transition_to(state_machine.movement_state[state_machine.WALK])
