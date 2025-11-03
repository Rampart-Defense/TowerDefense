extends "res://Scripts/Towers/tower_ai.gd"

@export var projectile_scene2: PackedScene
@export var projectile_scene3: PackedScene

var user_controlled: bool = false

func _process(_delta):
	if user_controlled:
		var mouse_pos = get_global_mouse_position()
		var to_mouse = mouse_pos - global_position
		turret.rotation = to_mouse.angle() + deg_to_rad(90)

func _input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if fire_timer.is_stopped():
			fire_projectile()
			fire_timer.start()



func fire_projectile() -> void:
	
	var target_pos = pending_target_pos
	
	
	if shoot_target != null or user_controlled:
		var projectile
		match tower_level:
			1:
				projectile =  projectile_scene.instantiate()
			2:
				projectile = projectile_scene2.instantiate()
			3: 
				projectile = projectile_scene3.instantiate() 
		# --- if user controls the tower take mouse position.
		if user_controlled:
			target_pos = get_global_mouse_position()
			match tower_level:
				1: turret.play("Fire")
				2: turret.play("Fire2")
				3: turret.play("Fire3")
				
		else:
			var projectile_speed = projectile.speed
			target_pos = _calculate_prediction_point(shoot_target, global_position, projectile_speed)
		# --- Otherwise CALL PREDICTION FUNCTION ---
		
		
		projectile.global_position = firing_point.global_position / map_scale
		projectile.direction = (target_pos / map_scale - projectile.global_position ).normalized()
		projectile.get_node("DamageSource").damage = damage + damage_buff
		get_tree().current_scene.call_deferred("add_child", projectile)


func _on_area_2d_area_entered(area: Area2D) -> void:
	
	if area.is_in_group("enemy"):
		
		enemies.append(area)
		_select_new_target()
		
		if fire_timer.is_stopped()  and not user_controlled:
			_fire()
			fire_timer.start()
		


func _on_fire_timer_timeout() -> void:
	if user_controlled:
		match tower_level:
			1: turret.play("Default")
			2: turret.play("Default2")
			3: turret.play("Default3")
		return
	if fire_cooldown - cdr_buff != fire_timer.wait_time:
		fire_timer.wait_time = fire_cooldown - cdr_buff
		
	if suppress_next_shot and enemies.is_empty():
	# cooldown expired while enemies was empty → do nothing if enemies are still empty
		suppress_next_shot = false
		return
	_fire()
	# Keep firing if enemies remain
	if not enemies.is_empty():
		fire_timer.start()




func _on_check_button_toggled(toggled_on: bool) -> void:
	user_controlled = toggled_on
	rotating = not toggled_on
	if toggled_on and not fire_timer.is_stopped():
		fire_timer.stop()
	if not toggled_on and fire_timer.is_stopped():
		fire_timer.start()
