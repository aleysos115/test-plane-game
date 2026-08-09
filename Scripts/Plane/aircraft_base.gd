@tool #needed to run in editor
class_name aircraft_base extends RigidBody3D

@export var mass_center: Vector3 = Vector3.ZERO:
	set(value):
		mass_center = value
		center_of_mass = mass_center
		update_gizmos()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var meshes: Array[Node] = find_children("*", "CollisionShape3D", true, false)
	for mesh: CollisionShape3D in meshes:
		mesh.reparent(self, true)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
