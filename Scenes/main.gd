extends Node

@export var level_root: Node3D
@export var entity_root: Node3D
@export var effect_root: Node3D

@export var target_scene: PackedScene
@export var player_scene: PackedScene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if target_scene:
		var scene_instance: Node = target_scene.instantiate()
		level_root.add_child(scene_instance)
	else:
		push_warning("No scene assigned to target_scene variable!")
		
	if player_scene:
		var player_instance: Node = player_scene.instantiate()
		entity_root.add_child(player_instance)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
