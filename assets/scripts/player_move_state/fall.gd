class_name Fall extends PlayerState

var init_state: int
var move_modifier: float
var move_speed: float
var init_velocity: Vector3


func enter(msg := {}) -> void:
	player.gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
	if msg:
		init_state = msg[state_machine.TO]
	


func handle_input(event: InputEvent) -> void:
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
