class_name Player extends CharacterBody3D

@export_range(1, 35, 1) var speed: float = 10 # m/s
@export_range(10, 400, 1) var acceleration: float = 100 # m/s^2

@export_range(0.1, 3.0, 0.1) var jump_height: float = 1 # m
@export_range(0.1, 3.0, 0.1, "or_greater") var camera_sens: float = 1

@export var first_person_camera_point: Node3D
@export var third_person_camera_point: Node3D

var jumping: bool = false
var mouse_captured: bool = false

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

var move_dir: Vector2 # Input direction for movement
var look_dir: Vector2 # Input direction for look/aim

var walk_vel: Vector3 # Walking velocity 
var grav_vel: Vector3 # Gravity velocity 
var jump_vel: Vector3 # Jumping velocity

var camera_root: Camera3D
var is_first_person: bool = true

var is_seated: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_capture_mouse()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		look_dir = (event as InputEventMouseMotion).relative * 0.001
		if mouse_captured: _rotate_camera()
	if Input.is_action_just_pressed(&"exit"): 
		get_tree().quit()
	if Input.is_action_just_pressed(&"toggle_camera"): 
		is_first_person = !is_first_person
	if Input.is_action_just_pressed(&"interact") and not is_seated:
		var space_state: PhysicsDirectSpaceState3D = get_world_3d().direct_space_state
		var mousepos: Vector2 = get_viewport().get_mouse_position()

		var origin: Vector3 = camera_root.project_ray_origin(mousepos)
		var end: Vector3 = origin + camera_root.project_ray_normal(mousepos) * 100
		var query: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(origin, end)
		query.exclude = [self]
		query.collide_with_areas = true

		var result: Dictionary = space_state.intersect_ray(query)
		if result.has("collider") and result.collider is Node:
			var parent: Node = result.collider
			Interactable.Try_Interact(parent, self)

func _physics_process(delta: float) -> void:
	if not is_seated:
		if Input.is_action_just_pressed(&"jump"): jumping = true
		velocity = _walk(delta) + _gravity(delta) + _jump(delta)
		move_and_slide()
	camera_root.global_position = first_person_camera_point.global_position if is_first_person else third_person_camera_point.global_position 
	if not is_first_person: camera_root.look_at(self.global_position)

# PUBLIC FUNCTIONS

func set_camera(camera: Camera3D) -> void:
	camera_root = camera

func seat_player() -> void:
	is_first_person = false
	is_seated = true

# PRIVATE SUPPORT FUNCTIONS

func _capture_mouse() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	mouse_captured = true

func _rotate_camera(sens_mod: float = 1.0) -> void:
	self.rotation.y -= look_dir.x * camera_sens * sens_mod
	if is_first_person: camera_root.rotation.y = self.rotation.y
	camera_root.rotation.x = clamp(camera_root.rotation.x - look_dir.y * camera_sens * sens_mod, -1.5, 1.5)

func _walk(delta: float) -> Vector3:
	move_dir = Input.get_vector(&"move_left", &"move_right", &"move_forward", &"move_backwards")
	var _forward: Vector3 = camera_root.global_transform.basis * Vector3(move_dir.x, 0, move_dir.y)
	var walk_dir: Vector3 = Vector3(_forward.x, 0, _forward.z).normalized()
	walk_vel = walk_vel.move_toward(walk_dir * speed * move_dir.length(), acceleration * delta)
	return walk_vel

func _gravity(delta: float) -> Vector3:
	grav_vel = Vector3.ZERO if is_on_floor() else grav_vel.move_toward(Vector3(0, velocity.y - gravity, 0), gravity * delta)
	return grav_vel

func _jump(delta: float) -> Vector3:
	if jumping:
		if is_on_floor(): jump_vel = Vector3(0, sqrt(4 * jump_height * gravity), 0)
		jumping = false
		return jump_vel
	jump_vel = Vector3.ZERO if is_on_floor() or is_on_ceiling_only() else jump_vel.move_toward(Vector3.ZERO, gravity * delta)
	return jump_vel
