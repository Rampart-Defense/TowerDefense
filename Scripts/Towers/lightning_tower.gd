extends "res://Scripts/Towers/tower_ai.gd"


@export var projectile_scene2: PackedScene
@export var projectile_scene3: PackedScene

func fire_projectile() -> void:
	if shoot_target == null or not is_instance_valid(shoot_target):
		# We also need to reset the pending target and current target 
		# to ensure the tower tries to find a new target next time.
		pending_target_pos = Vector2.ZERO
		current_target = null
		shoot_target = null
		return

	var target_pos = pending_target_pos
	var tower_callback = Callable(self, "add_to_total_damage")
	match tower_level:
		1:
			
			var projectile = projectile_scene.instantiate()
			if projectile.has_method("set_damage_callback"):
				projectile.set_damage_callback(tower_callback)
			var projectile_speed = projectile.speed
			target_pos = _calculate_prediction_point(shoot_target, global_position, projectile_speed)
			projectile.global_position = firing_point.global_position / map_scale 
			projectile.direction = (target_pos / map_scale - projectile.global_position  ).normalized()
			projectile.get_node("DamageSource").damage = damage + damage_buff
			get_tree().current_scene.call_deferred("add_child", projectile)
			
		2:
			
			var projectile = projectile_scene2.instantiate()
			if projectile.has_method("set_damage_callback"):
				projectile.set_damage_callback(tower_callback)
			var projectile_speed = projectile.speed
			target_pos = _calculate_prediction_point(shoot_target, global_position, projectile_speed)
			projectile.global_position = firing_point.global_position / map_scale 
			projectile.direction = (target_pos / map_scale  - projectile.global_position).normalized()
			projectile.get_node("DamageSource").damage = damage + damage_buff
			get_tree().current_scene.call_deferred("add_child", projectile)
		3:
			var projectile = projectile_scene3.instantiate()
			if projectile.has_method("set_damage_callback"):
				projectile.set_damage_callback(tower_callback)
			var projectile_speed = projectile.speed
			target_pos = _calculate_prediction_point(shoot_target, global_position, projectile_speed)
			projectile.global_position = firing_point.global_position / map_scale 
			projectile.direction = (target_pos / map_scale  - projectile.global_position).normalized()
			projectile.get_node("DamageSource").damage = damage + damage_buff
			get_tree().current_scene.call_deferred("add_child", projectile)
			
			

func _apply_visuals_and_stats():
	#Applying visuals
	match tower_level:
		1:
			tower_base.frame = 0
			turret.frame = 0
			turret.position = Vector2(0,-45)
		2:
			tower_base.frame = 1
			turret.frame = 1
			turret.position = Vector2(0, -60)
		3:
			tower_base.frame = 2
			turret.frame = 2
			turret.position = Vector2(0, -90)
	# Applying stats and visuals
	range_area.shape.radius = current_range
	get_node("RangeArea").size = Vector2(current_range*2, current_range*2)
	get_node("RangeArea").position = Vector2(-current_range, -current_range)
	_on_turret_animation_finished()

func can_place() -> bool:
	return TowerPlacementCheck.can_place(self, 32, 62)

	
# --- Animation finish hook ---
func _on_turret_animation_finished() -> void:
	if firing:
		fire_projectile()
		firing = false
		pending_target_pos = Vector2.ZERO

	# Reset idle anim
		match tower_level:
			1: turret.play("Transition")
			2: turret.play("Transition2")
			3: turret.play("Transition3")
	else:
		match tower_level:
			1: turret.play("Default")
			2: turret.play("Default2")
			3: turret.play("Default3")
