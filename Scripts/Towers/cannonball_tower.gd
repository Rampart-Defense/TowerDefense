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
	new_projectile.get_node("DamageSource").damage = damage + damage_buff

	# Using call_deferred is correct for adding new nodes safely.
	get_tree().current_scene.call_deferred("add_child", new_projectile)

func fire_projectile() -> void:

	# This angle defines the turret's "forward" direction.
	var turret_angle: float = turret.global_rotation
	# 1. Define the base directions (UP, DOWN, LEFT, RIGHT)
	# 2. Rotate them by the turret's current angle (turret_angle)
	# Local Forward/Up direction
	var direction_up: Vector2 = Vector2.UP.rotated(turret_angle)
	# Local Right direction
	var direction_right: Vector2 = Vector2.RIGHT.rotated(turret_angle)
	# Local Down/Backward direction
	var direction_down: Vector2 = Vector2.DOWN.rotated(turret_angle)
	# Local Left direction
	var direction_left: Vector2 = Vector2.LEFT.rotated(turret_angle)

	match tower_level:
		1:
			# Level 1: FORWARD (Local UP) only
			_spawn_single_projectile(firing_point, direction_up)

		2:
			# Level 2: FORWARD (Local UP) and BACKWARD (Local DOWN)
			_spawn_single_projectile(firing_point, direction_up)
			_spawn_single_projectile(firing_point2, direction_down)

		3:
			# Level 3: All four local directions
			_spawn_single_projectile(firing_point, direction_up)    # Fires forward
			_spawn_single_projectile(firing_point3, direction_right) # Fires right
			_spawn_single_projectile(firing_point2, direction_down)  # Fires backward
			_spawn_single_projectile(firing_point4, direction_left)  # Fires left
