extends "res://Scripts/Towers/tower_ai.gd"

#firing_point is UP
@export var firing_point2: Marker2D #Down
@export var firing_point3: Marker2D #Right
@export var firing_point4: Marker2D #Left

# --- HELPER FUNCTION ---
# This function handles instantiating and setting the properties for a single projectile.
func _spawn_single_projectile(start_point: Marker2D, direction_vector: Vector2) -> void:
	# 1. Instantiate a new projectile every time this function is called.
	var new_projectile = projectile_scene.instantiate()

	# 2. Set position and direction
	new_projectile.global_position = start_point.global_position / map_scale
	new_projectile.direction = direction_vector

	# 3. Set damage and add to the scene
	# We assume "DamageSource" node is a child of the projectile.
	new_projectile.get_node("DamageSource").damage = damage

	# Using call_deferred is correct for adding new nodes safely.
	get_tree().current_scene.call_deferred("add_child", new_projectile)

func fire_projectile() -> void:
	# No need to instantiate the projectile here, do it inside the helper function.

	match tower_level:
		1:
			# Level 1: UP only
			_spawn_single_projectile(firing_point, Vector2.UP)

		2:
			# Level 2: UP and DOWN
			_spawn_single_projectile(firing_point, Vector2.UP)
			_spawn_single_projectile(firing_point2, Vector2.DOWN)

		3:
			# Level 3: UP, DOWN, LEFT, RIGHT
			_spawn_single_projectile(firing_point, Vector2.UP)
			_spawn_single_projectile(firing_point3, Vector2.RIGHT)
			_spawn_single_projectile(firing_point2, Vector2.DOWN)
			_spawn_single_projectile(firing_point4, Vector2.LEFT)
