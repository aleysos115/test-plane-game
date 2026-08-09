@tool
extends EditorPlugin

var gizmo_plugin: EditorNode3DGizmoPlugin = preload("res://addons/gizmos/aircraft_plane_gizmos.gd").new()

func _enable_plugin() -> void:
	# Add autoloads here.
	pass

func _disable_plugin() -> void:
	# Remove autoloads here.
	pass

func _enter_tree() -> void:
	add_node_3d_gizmo_plugin(gizmo_plugin)

func _exit_tree() -> void:
	remove_node_3d_gizmo_plugin(gizmo_plugin)
