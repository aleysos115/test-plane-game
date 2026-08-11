extends Node

@export var main_camera: Camera3D 

@export var level_root: Node3D
@export var entity_root: Node3D
@export var effect_root: Node3D

@export var target_scene: PackedScene
@export var player_scene: PackedScene
@export var terrain_scene: PackedScene

var player: Player

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	load_level(target_scene)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func load_level(target: PackedScene) -> void:
	if target:
		var scene_instance: Node = target.instantiate()
		level_root.add_child(scene_instance)
	else:
		push_warning("No scene assigned to target_scene variable!")
	
	if player_scene:
		player = player_scene.instantiate()
		entity_root.add_child(player)
		var spawn_point: Node3D = level_root.get_child(0).get_node("PlayerSpawn")
		if spawn_point:
			player.global_position = spawn_point.global_position
		player.set_camera(main_camera)
	
	load_terrain_scene(terrain_scene)

func load_terrain_scene(target: PackedScene) -> void:
	if target:
		var terrain_scene_instance: Node = target.instantiate()
		level_root.add_child(terrain_scene_instance)
	else:
		push_warning("No scene assigned to terrain_scene variable!")
