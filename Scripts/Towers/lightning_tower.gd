extends "res://Scripts/Towers/tower_ai.gd"


@export var projectile_scene2: PackedScene
@export var projectile_scene3: PackedScene

func fire_projectile(target_pos: Vector2) -> void:


	match tower_level:
		1:
			turret.play("Fire")
			var projectile = projectile_scene.instantiate()
			projectile.global_position = firing_point.global_position / map_scale 
			projectile.direction = (target_pos / map_scale - projectile.global_position  ).normalized()
			projectile.get_node("DamageSource").damage = damage
			get_tree().current_scene.call_deferred("add_child", projectile)
			
		2:
			turret.play("Fire2")
			var projectile = projectile_scene2.instantiate()
			projectile.global_position = firing_point.global_position / map_scale 
			projectile.direction = (target_pos / map_scale  - projectile.global_position).normalized()
			projectile.get_node("DamageSource").damage = damage
			get_tree().current_scene.call_deferred("add_child", projectile)
		3:
			var projectile = projectile_scene3.instantiate()
			projectile.global_position = firing_point.global_position / map_scale 
			projectile.direction = (target_pos / map_scale  - projectile.global_position).normalized()
			projectile.get_node("DamageSource").damage = damage
			get_tree().current_scene.call_deferred("add_child", projectile)
			turret.play("Fire3")
			

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

	
