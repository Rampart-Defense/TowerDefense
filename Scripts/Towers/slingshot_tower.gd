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
			


func can_place() -> bool:
	return TowerPlacementCheck.can_place(self, 32, 62)

	
