class_name Player extends CharacterBody3D

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

# Customizable player stats
@export var walk_back_speed: float = 3.0
@export var walk_speed: float = 5.0
@export var sprint_speed: float = 10.0
@export var jump_height: float = 1.0
@export var acceleration: float = 10.0
@export var arm_length: float = 0.5
@export var regular_climb_speed: float = 300.0
@export var fast_climb_speed: float = 400.0

@onready var camera_pivot: Node3D = %CameraPivot
@onready var state_machine: PlayerStateMachine = %StateMachine
@onready var animation_player: AnimationPlayer = %AnimationPlayer

# Raycasts used for detecting if the player is touching a wall
@onready var bottom_raycast: RayCast3D = %BottomRaycast
@onready var middle_raycast: RayCast3D = %MiddleRaycast
@onready var top_raycast: RayCast3D = %TopRaycast

# Raycasts used for getting the ledge position and checking if there's enough space
@onready var surface_raycasts_root: Node3D = %SurfaceRaycasts
@onready var projected_height_raycast: RayCast3D = %ProjectedHeightRaycast
@onready var surface_raycast: RayCast3D = %SurfaceRaycast

# Raycasts used for checking if there's enough horizontal space to climb
@onready var left_climbable_raycast: RayCast3D = %LeftClimbableRaycast
@onready var right_climbable_raycast: RayCast3D = %RightClimbableRaycast

# Raycast for detecting ceiling
@onready var crouch_raycast = %CrouchRaycast

# Dynamic values used for calculation 
var ledge_position: Vector3 = Vector3.ZERO
var mouse_motion: Vector2

# Player state values that aren't supposed to be changed directly
var climb_speed: float = fast_climb_speed
var is_crouched: bool = false
var can_climb: bool
var can_climb_timer: Timer
var is_affected_by_gravity: bool = true


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		mouse_motion = -event.relative * 0.001
	
	if event.is_action_pressed("pause"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	if event.is_action_pressed("crouch"):
		if is_crouched:
			stand_up()
		else:
			crouch()


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor() && is_affected_by_gravity:
		velocity.y -= gravity * delta
	
	# Resetting climb ability when on ground
	if is_on_floor() && !can_climb:
		if can_climb_timer != null:
			can_climb_timer.queue_free()
		can_climb = true
	
	move_and_slide()


func _process(_delta: float):
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		# Handling camera in '_process' so that camera movement is framerate independent
		_handle_camera_motion()


func _handle_camera_motion() -> void:
	rotate_y(mouse_motion.x)
	camera_pivot.rotate_x(mouse_motion.y)
	
	camera_pivot.rotation_degrees.x = clampf(
		camera_pivot.rotation_degrees.x , -89.0, 89.0
	)
	
	mouse_motion = Vector2.ZERO


func check_climbable() -> bool:
	if crouch_raycast.is_colliding():
		return false
	
	if not bottom_raycast.is_colliding() && not middle_raycast.is_colliding() && not top_raycast.is_colliding():
		return false
	
	var climb_point = surface_raycast.get_collision_point()
	var climb_height = climb_point.y - global_position.y
	
	left_climbable_raycast.global_position.y = climb_point.y + 0.1
	right_climbable_raycast.global_position.y = climb_point.y + 0.1
	
	if left_climbable_raycast.is_colliding() || right_climbable_raycast.is_colliding():
		return false
	
	projected_height_raycast.target_position = Vector3(0, climb_height - 0.1, 0)
	
	if projected_height_raycast.is_colliding():
		return false
	
	ledge_position = climb_point
	return true


func check_small_ledge() -> bool:
	return bottom_raycast.is_colliding() && not middle_raycast.is_colliding() && not top_raycast.is_colliding()


func set_climb_speed(is_small_ledge) -> void:
	if is_small_ledge:
		climb_speed = fast_climb_speed
	else:
		climb_speed = regular_climb_speed


func crouch() -> void:
	if not state_machine.state_allows_crouch():
		return
	
	animation_player.play("crouch")
	is_crouched = true


func stand_up() -> void:
	if crouch_raycast.is_colliding():
		return
	
	animation_player.play_backwards("crouch")
	is_crouched = false


func setup_can_climb_timer(callback: Callable = _on_grab_available_timeout) -> void:
	if can_climb_timer != null:
		return
	
	can_climb = false
	
	can_climb_timer = Timer.new()
	add_child(can_climb_timer)
	can_climb_timer.wait_time = 1.0
	can_climb_timer.one_shot = true
	can_climb_timer.connect("timeout", callback)
	can_climb_timer.start()


func _on_grab_available_timeout() -> void:
	can_climb = true
	
	if can_climb_timer != null:
		can_climb_timer.queue_free()


## Triggers on every state transition. Could be useful for side effects and debugging
## Note that it's triggered after the '_state' "enter" method
func _on_state_machine_transitioned(_state: PlayerState) -> void:
	pass
