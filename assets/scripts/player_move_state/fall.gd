class_name Fall extends PlayerState

var init_state: int
var move_modifier: float
var move_speed: float
var init_velocity: Vector3

var grab_available_timer: Timer
var grab_available: bool = true


func enter(msg := {}) -> void:
	player.gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
	if msg:
		#if msg.keys().has(state_machine.FROM):
			#if msg[state_machine.FROM] == state_machine.GRAB || msg[state_machine.FROM] == state_machine.CLIMB:
				#grab_available = false
				#_setup_grab_available_timer(_on_grab_available_timeout)
		
		init_state = msg[state_machine.TO]
		


func handle_input(event: InputEvent) -> void:
	if Input.is_action_just_released("sprint"):
		init_state = state_machine.WALK


func physics_update(_delta: float) -> void:
	
	if player.is_on_floor():
		#grab_available = true
		state_machine.transition_to(state_machine.movement_state[init_state])
	
	if Input.is_action_pressed("jump") && grab_available:
		await get_tree().create_timer(0.05).timeout
		if player.check_climbable():
			
			## TODO: add cooldown on grabbing after releasing without climbing
			
			state_machine.transition_to(
				state_machine.movement_state[state_machine.GRAB],
				{ "ledge_position" = player.ledge_position }
			)


func _setup_grab_available_timer(callback: Callable) -> void:
	grab_available_timer = Timer.new()
	add_child(grab_available_timer)
	grab_available_timer.wait_time = 0.5
	grab_available_timer.one_shot = true
	grab_available_timer.connect("timeout", callback)


func _on_grab_available_timeout() -> void:
	grab_available = true
	grab_available_timer.queue_free()
