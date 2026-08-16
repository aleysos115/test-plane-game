class_name PlaneBase extends RigidBody3D

@export var interactable: Interactable
@export var player_seat: RemoteTransform3D
@export var max_throttle: float = 500

@export var drag_left: Curve
@export var drag_right: Curve
@export var drag_up: Curve
@export var drag_down: Curve
@export var drag_forward: Curve
@export var drag_back: Curve
@export var air_breaks_drag: float

@export var flaps_drag: float
@export var flaps_lift_power: float
@export var flaps_aoa_bias: float

@export var induced_drag: float

@export var aoa_curve: Curve
@export var rudder_aoa_curve: Curve
@export var lift_power: float
@export var rudder_power: float

var seated_player: Player = null
var throttle_input: float = 0
var air_breaks_deployed: bool = false
var flaps_deployed: bool = false

# Force Calculation Variables
var velocity: Vector3
var local_velocity: Vector3
var local_angular_velocity: Vector3
var aoa: float = 0
var aoa_yaw: float = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	interactable.interacted_with.connect(_on_interacted_with)

func _physics_process(delta: float) -> void:
	_calculate_state(delta)
	_calculate_aoa(delta)
	
	_update_thrust()
	_update_drag()
	_update_lift()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if not seated_player:
		return
	var move_dir: Vector2 = Input.get_vector(&"move_left", &"move_right", &"move_forward", &"move_backwards")
	throttle_input = -move_dir.y
	if throttle_input < 0: throttle_input = 0
	flaps_deployed = true if move_dir.x != 0 else false

func _on_interacted_with(player: Player) -> void:
	seated_player = player;
	player.seat_player()
	player_seat.remote_path = player_seat.get_path_to(player)

func _calculate_state(_delta: float) -> void:
	var inverse_rotation: Basis = global_basis.inverse()
	velocity = linear_velocity
	local_velocity = inverse_rotation * velocity
	local_angular_velocity = inverse_rotation * angular_velocity

func _calculate_aoa(_delta: float) -> void:
	if local_velocity.length_squared() < 0.1:
		aoa = 0
		aoa_yaw = 0
		return
	
	aoa = atan2(-local_velocity.y, local_velocity.z)
	aoa_yaw = atan2(local_velocity.x, local_velocity.z)
	return

func _update_thrust() -> void:
	apply_central_force(throttle_input * max_throttle * global_transform.basis.z)

func _update_drag() -> void:
	var lv: Vector3 = local_velocity
	var lv2: float = local_velocity.length_squared()
	
	var air_breaks: float = air_breaks_drag if air_breaks_deployed else 0.0
	var flaps: float = flaps_drag if flaps_deployed else 0.0
	
	var coefficient: Vector3 = _scale_6(lv.normalized(), \
	Vector2(drag_left.sample(absf(lv.x)), drag_right.sample(absf(lv.x))), \
	Vector2(drag_up.sample(absf(lv.y)), drag_down.sample(absf(lv.y))), \
	Vector2(drag_forward.sample(absf(lv.z)) + air_breaks + flaps, \
	drag_back.sample(absf(lv.z))))
	
	var drag: Vector3 = coefficient.length() * lv2 * -lv.normalized()
	apply_central_force(global_transform.basis * drag)

func _update_lift() -> void:
	if local_velocity.length_squared() < 1:
		return
	
	var flap_lift: float = flaps_lift_power if flaps_deployed else 0.0
	var flaps_bias: float = flaps_aoa_bias if flaps_deployed else 0.0
	
	print(rad_to_deg(aoa + flaps_bias))
	var lift_force: Vector3 = _calculate_lift(aoa + flaps_bias, Vector3.RIGHT, \
	lift_power + flap_lift, aoa_curve)
	
	var yaw_force: Vector3 = _calculate_lift(aoa_yaw, Vector3.UP, rudder_power, rudder_aoa_curve)
	
	print(lift_force)
	apply_central_force(global_transform.basis * lift_force)
	apply_central_force(global_transform.basis * yaw_force)
	

func _calculate_lift(aoa_value: float, right_axis: Vector3, _lift_power: float, curve: Curve) -> Vector3:
	var lift_velocity: Vector3 = Plane(right_axis).project(local_velocity)
	var lift_sqr: float = lift_velocity.length_squared()
	
	# list = velocity ^ 2 * coefiicent * lift_power
	var lift_coefficent: float = curve.sample(rad_to_deg(aoa_value))
	var lift_force: float = lift_sqr * lift_coefficent * _lift_power
	
	# lift is perpendicular to velocity
	var lift_direction: Vector3 = lift_velocity.normalized().cross(right_axis)
	var lift: Vector3 = lift_direction * lift_force
	
	# induced drag
	var drag_force: float = lift_coefficent * lift_coefficent * induced_drag
	var drag_direction: Vector3 = -lift_velocity.normalized()
	var induced: Vector3 = drag_direction * lift_sqr * drag_force
	
	print("lift_sqr: ", lift_sqr, " coef: ", lift_coefficent, " power: ", _lift_power)
	return lift + induced

func _scale_6(value: Vector3, x: Vector2, y: Vector2, z: Vector2) -> Vector3:
	var result: Vector3 = value
	result.x *= x.x if result.x > 0 else x.y
	result.y *= y.x if result.y > 0 else y.y
	result.z *= z.x if result.z > 0 else z.y
	return result
