class_name Player_Station extends Node3D

@export var player_lock: RemoteTransform3D

var player_seated: bool = false
var seated_player: Player

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func seat_player(player: Player) -> void:
	seated_player = player;
	player.seat_player()
	player_lock.remote_path = player_lock.get_path_to(player)

func unseat_player() -> void:
	seated_player.unseat_player()
	seated_player = null
	player_lock.remote_path = ""
