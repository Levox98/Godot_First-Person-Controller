class_name Fall extends PlayerState

## Variable for storing the state prior to falling
var init_state: int


func enter(msg := {}) -> void:
	player.view_bobbing_amount = player.default_view_bobbing_amount
	player.is_affected_by_gravity = true
	if msg:
		init_state = msg[state_machine.TO]


func handle_input(_event: InputEvent) -> void:
	if Input.is_action_just_released("sprint"):
		init_state = state_machine.WALK


func physics_update(_delta: float) -> void:
	if player.is_on_floor():
		state_machine.transition_to(state_machine.movement_state[init_state])
	
	if Input.is_action_pressed("jump") && player.can_climb:
		if player.check_climbable():
			state_machine.transition_to(
				state_machine.movement_state[state_machine.GRAB],
				{ "ledge_position" = player.ledge_position }
			)
