extends Node

# Hello Alex
# This is a semiTemp solution to get the terrain working, although it might be fine for the full game
# I imagine the terrain may or may not have a lot of functionality depending on how procedural the game is
# with creating missions and events and the like, so I thought an AutoLoad would be most appropriate to manage the terrain

#Public Variables
var terrain_exists : bool = false

#Private Variables
var _terrain3D : Terrain3D

#Godot Functions
func _ready() -> void:
	pass

#Public Functions
func assign_new_terrain(terrain: Terrain3D) -> void:
	if terrain == null :
		push_warning("Proivded terrain is null")
		pass
	
	if _terrain3D != null :
		push_warning("Overwriting existing terrain!")
	
	_terrain3D = terrain
	if _terrain3D != null :
		print("Terrain linked successfully!")
	else :
		push_warning("Failed to link Terrain")
	
	_try_grab_player_camera()

func does_terrain_exist() -> bool:
	return _terrain3D != null

#Private Functions
func _try_grab_player_camera() -> bool:
	#TEMPORARY SOLUTION: Alex feel free to change, update etc.
	var camera: Camera3D = get_node("/root/Main/Systems/Camera3D")
	if camera != null :
		_terrain3D.set_camera(camera)
		print("Cam Linked to terrain successfully")
		return true
	else :
		push_warning("Failed to link camera")
		return false
