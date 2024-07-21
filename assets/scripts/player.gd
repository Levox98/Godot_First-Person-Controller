class_name Player extends CharacterBody3D

## TODO refactor !!!!!!!!!!!!!!!!!!!!!!
## TODO fix climbing near wall edges

@export var walk_back_speed: float = 3.0
@export var walk_speed: float = 5.0
@export var sprint_speed: float = 10.0
@export var jump_height: float = 1.0
@export var acceleration: float = 10.0

var player_height: float = 1.8
@export var arm_length: float = 0.5

var ledge_position: Vector3 = Vector3.ZERO
var climb_speed: float = 400.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var mouse_motion: Vector2

var is_crouched: bool = false
var allow_climb: bool = true

@onready var camera_pivot: Node3D = %CameraPivot
@onready var state_machine: PlayerStateMachine = %StateMachine

@onready var animation_player: AnimationPlayer = %AnimationPlayer

@onready var bottom_raycast: RayCast3D = %BottomRaycast
@onready var middle_raycast: RayCast3D = %MiddleRaycast
@onready var top_raycast: RayCast3D = %TopRaycast

@onready var surface_raycasts_root: Node3D = %SurfaceRaycasts
@onready var projected_height_raycast: RayCast3D = %ProjectedHeightRaycast
@onready var surface_raycast: RayCast3D = %SurfaceRaycast

@onready var left_climbable_raycast: RayCast3D = %LeftClimbableRaycast
@onready var right_climbable_raycast: RayCast3D = %RightClimbableRaycast


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	surface_raycasts_root.position.y += arm_length


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		mouse_motion = -event.relative * 0.001
	
	if event.is_action_pressed("pause"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	if event.is_action_pressed("crouch"):
		if state_machine.state is Idle || state_machine.state is Walk || state_machine.state is Sprint:
			if is_crouched:
				stand_up()
			else:
				crouch()


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		_handle_camera_motion()
	
	move_and_slide()


func _on_state_machine_transitioned(state: PlayerState) -> void:
	print("Transitioned to: \"" + state.name + "\"")
	pass


func _handle_camera_motion() -> void:
	rotate_y(mouse_motion.x)
	camera_pivot.rotate_x(mouse_motion.y)
	
	camera_pivot.rotation_degrees.x = clampf(
		camera_pivot.rotation_degrees.x , -89.0, 89.0
	)
	mouse_motion = Vector2.ZERO


func check_climbable() -> bool:
	projected_height_raycast.target_position = Vector3.ZERO
	
	var colliding_for_climb = bottom_raycast.is_colliding() || middle_raycast.is_colliding() || top_raycast.is_colliding()
	
	if !colliding_for_climb || projected_height_raycast.is_colliding():
		return false
	
	var climb_surface = surface_raycast.get_collision_point()
	
	var climb_height = climb_surface.y - global_position.y
	
	left_climbable_raycast.global_position.y = climb_surface.y + 0.1
	right_climbable_raycast.global_position.y = climb_surface.y + 0.1
	
	if left_climbable_raycast.is_colliding() || right_climbable_raycast.is_colliding():
		return false
	
	projected_height_raycast.target_position = Vector3(0, climb_height - 0.1, 0)
	
	if projected_height_raycast.is_colliding():
		return false
	
	ledge_position = climb_surface
	
	return true


func check_small_ledge() -> bool:
	var result = bottom_raycast.is_colliding() && !middle_raycast.is_colliding() && !top_raycast.is_colliding()
	if result:
		climb_speed = 400.0
	else:
		climb_speed = 300.0
	return result


func crouch() -> void:
	animation_player.play("crouch")
	is_crouched = true


func stand_up() -> void:
	animation_player.play_backwards("crouch")
	is_crouched = false
