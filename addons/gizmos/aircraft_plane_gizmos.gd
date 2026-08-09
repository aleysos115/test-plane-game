@tool
extends EditorNode3DGizmoPlugin

func _init() -> void:
	create_material("com_material", Color.RED, false, true)

func _get_gizmo_name() -> String:
	return "CenterOfMass"

func _has_gizmo(node: Node3D) -> bool:
	return node is aircraft_base

func _redraw(gizmo: EditorNode3DGizmo) -> void:
	gizmo.clear()
	var body: aircraft_base = gizmo.get_node_3d() as aircraft_base
	if body.center_of_mass_mode != RigidBody3D.CENTER_OF_MASS_MODE_CUSTOM:
		return
	var lines: PackedVector3Array = PackedVector3Array()
	var com: Vector3 = body.mass_center
	var s: float = 0.2
	for axis: Vector3 in [Vector3.RIGHT, Vector3.UP, Vector3.FORWARD]:
		lines.append(com - axis * s)
		lines.append(com + axis * s)
	var mat: StandardMaterial3D = get_material("com_material", gizmo)
	mat.no_depth_test = true
	gizmo.add_lines(lines, mat)
