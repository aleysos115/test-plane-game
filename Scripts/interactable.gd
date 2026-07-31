# Add this node as a top level child of the physics body to allow the player
# to interact
class_name Interactable extends Node

signal interacted_with(player: Player)

# This scans the top layer of the parents children for an interact node
# then if found, interacts
static func Try_Interact(parent: Node, player: Player):
	for child in parent.get_children():
		if child is Interactable:
			(child as Interactable).interact(player)

func interact(player: Player) -> void:
	interacted_with.emit(player)
