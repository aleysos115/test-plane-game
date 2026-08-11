extends Terrain3D

# Hello Alex.
# I didn't want to put the terrain in the same scene as the base or main, so I just made it get loaded in on start.
# Very temp just to get things working, you can delete this if you are LITERALLY shaking rn

# A note on terrain resolution and region size.
# You define regions in this terrain and they have a size.
# If you want a lower resolution you have to both decrease the Region Size and increase the Vertext Distance
# Kidna weird and the naming is fucking with me but idk doing that for now
# There is a chance I got this wrong because it feels weird

func _ready() -> void:
	TerrainManager.assign_new_terrain(self)
