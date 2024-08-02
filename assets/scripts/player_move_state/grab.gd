class_name Grab extends PlayerState

var ledge_position: Vector3
var grab_timer: Timer


func enter(msg := {}) -> void:
	if msg:
		ledge_position = msg["ledge_position"]
	
	player.velocity = Vector3.ZERO
	player.gravity = 0
	
	
	if player.check_small_ledge():
		if player.can_climb:
			state_machine.transition_to(
				state_machine.movement_state[state_machine.CLIMB],
				{ "ledge_position" = player.ledge_position }
			)
	else:
		_setup_timer(_on_grab_timer_timeout)
		grab_timer.start()


func handle_input(event: InputEvent) -> void:
	if event.is_action_released("jump"):
		player.setup_can_climb_timer()
		if grab_timer != null:
			grab_timer.queue_free()
		state_machine.transition_to(
			state_machine.movement_state[state_machine.FALL],
			{ 
				state_machine.TO : state_machine.WALK,
				state_machine.FROM : state_machine.GRAB,
			}
		)


func physics_update(delta: float) -> void:
	if !Input.is_action_pressed("jump"):
		
		if grab_timer != null:
			grab_timer.queue_free()
			state_machine.transition_to(
				state_machine.movement_state[state_machine.FALL],
				{ 
					state_machine.TO : state_machine.WALK,
					state_machine.FROM : state_machine.GRAB,
				}
			)


func _setup_timer(callback: Callable) -> void:
	grab_timer = Timer.new()
	add_child(grab_timer)
	grab_timer.wait_time = 0.5
	grab_timer.one_shot = true
	grab_timer.connect("timeout", callback)


func _on_grab_timer_timeout() -> void:
	grab_timer.queue_free()
	state_machine.transition_to(
		state_machine.movement_state[state_machine.CLIMB],
		{ "ledge_position" = player.ledge_position }
	)
	
