extends "res://Scripts/Towers/tower_ai.gd"


@export var projectile_scene2: PackedScene
@export var projectile_scene3: PackedScene

func fire_projectile() -> void:
	var target_pos = pending_target_pos
	var tower_callback = Callable(self, "add_to_total_damage")
	if shoot_target != null:
		target_pos = shoot_target.global_position
	match tower_level:
		1:
			
			var projectile = projectile_scene.instantiate()
			if projectile.has_method("set_damage_callback"):
				projectile.set_damage_callback(tower_callback)
			projectile.global_position = firing_point.global_position / map_scale 
			projectile.direction = (target_pos / map_scale - projectile.global_position  ).normalized()
			projectile.get_node("DamageSource").damage = damage + damage_buff
			get_tree().current_scene.call_deferred("add_child", projectile)
			
		2:
			
			var projectile = projectile_scene2.instantiate()
			if projectile.has_method("set_damage_callback"):
				projectile.set_damage_callback(tower_callback)
			projectile.global_position = firing_point.global_position / map_scale 
			projectile.direction = (target_pos / map_scale  - projectile.global_position).normalized()
			projectile.get_node("DamageSource").damage = damage + damage_buff
			get_tree().current_scene.call_deferred("add_child", projectile)
		3:
			var projectile = projectile_scene3.instantiate()
			if projectile.has_method("set_damage_callback"):
				projectile.set_damage_callback(tower_callback)
			projectile.global_position = firing_point.global_position / map_scale 
			projectile.direction = (target_pos / map_scale  - projectile.global_position).normalized()
			projectile.get_node("DamageSource").damage = damage + damage_buff
			get_tree().current_scene.call_deferred("add_child", projectile)
			
			


func can_place() -> bool:
	return TowerPlacementCheck.can_place(self, 32, 62)

	
