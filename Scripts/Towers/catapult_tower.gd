extends "res://Scripts/Towers/tower_ai.gd"



func fire_projectile() -> void:
	var target_pos = pending_target_pos
	var tower_callback = Callable(self, "add_to_total_damage")
	var offsets: Array = []
	var projectile_anim_name: String = "default" # Default animation name
	match tower_level:
		1:
			offsets = [Vector2(0, 0)]  # single shot
			
		2:
			offsets = [Vector2(-5, 0), Vector2(5, 0)]  # two shots
			
		3:
			offsets = [Vector2(0, -5), Vector2(0, 0), Vector2(0, 5)]  # three shots
			
			projectile_anim_name = "default3"
	if shoot_target != null:
		target_pos = shoot_target.global_position
	# Spawn all projectiles with the given offsets. also shoot towards the offset
	for offset in offsets:
		var projectile = projectile_scene.instantiate()
		if projectile.has_method("set_damage_callback"):
			projectile.set_damage_callback(tower_callback)
		var anim_sprite = projectile.get_node_or_null("AnimatedSprite2D")
		if anim_sprite:
			anim_sprite.play(projectile_anim_name)
		projectile.global_position = firing_point.global_position / map_scale + offset
		projectile.direction = (target_pos / map_scale - projectile.global_position).normalized()
		projectile.get_node("DamageSource").damage = damage + damage_buff
		get_tree().current_scene.call_deferred("add_child", projectile)
	
