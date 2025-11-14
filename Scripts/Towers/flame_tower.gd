extends "res://Scripts/Towers/tower_ai.gd"

# Maximum angle (in degrees) for the random spread of the flame projectile
const MAX_SPREAD_ANGLE: float = 30.0


# --- Override Base Firing Logic ---

# EDITED: Handles Continuous Tracking, Firing, and Stopping.
func _on_fire_timer_timeout() -> void:

	if fire_cooldown - cdr_buff != fire_timer.wait_time:
		fire_timer.wait_time = fire_cooldown - cdr_buff

	# 1. Stop if enemies are gone
	if enemies.is_empty():
		suppress_next_shot = true
		firing = false
		if shoot_sound and not shoot_sound.is_playing():
			shoot_sound.stop()
		return
		
	# 2. Continuous Stream Logic
	if current_target and is_instance_valid(current_target):
		
		# --- ROTATION AND AIMING (FIXED) ---
		# Update Rotation EVERY TICK (Fixes Direction Issue)
		if rotating:
			var to_enemy = current_target.global_position - global_position
			turret.rotation = to_enemy.angle() + deg_to_rad(90)
		
		pending_target_pos = current_target.global_position
		shoot_target = current_target
		
		# --- FIRING ---
		firing = true
		play_fire_animation()
		if shoot_sound and shoot_sound.is_playing():
			shoot_sound.play()
			
		fire_projectile() # Fire a flame tick immediately

		# 3. Restart Timer (Maintains Continuous Stream)
		fire_timer.start()


# EDITED: The _fire() function is overridden to prevent the base script's
# 'if firing: return' check from interfering with the continuous loop.
# The timer now drives the action completely.
func _fire() -> void:
	# Only allow initial setup once if placing the tower
	if placing_tower:
		return
	
	if current_target and is_instance_valid(current_target):
		# We still set these variables, but the timer will update rotation
		pending_target_pos = current_target.global_position
		shoot_target = current_target
		
		# If the timer calls this, we ensure the initial visual/sound is played.
		# Note: We intentionally DO NOT check 'if firing: return' here.
		firing = true
		play_fire_animation()
		if shoot_sound:
			shoot_sound.play()


# EDITED: Modified to fire a single projectile with random spread and FULL damage
func fire_projectile() -> void:
	if shoot_target == null or not is_instance_valid(shoot_target) or placing_tower:
		return
	var tower_callback = Callable(self, "add_to_total_damage")
	# Determine Projectile Speed (for prediction)
	const FALLBACK_SPEED = 400.0 
	var projectile_speed = FALLBACK_SPEED
	
	var projectile_template = projectile_scene.instantiate()
	if projectile_template.speed:
		projectile_speed = projectile_template.speed
	projectile_template.queue_free()
	
	# --- CALL PREDICTION FUNCTION (from base script) ---
	var target_pos = _calculate_prediction_point(shoot_target, global_position, projectile_speed)
	
	# --- Projectile Spawning Logic ---
	var projectile = projectile_scene.instantiate()
	if projectile.has_method("set_damage_callback"):
		projectile.set_damage_callback(tower_callback)
	# 1. Calculate base direction
	var projectile_start_pos = firing_point.global_position / map_scale
	var base_direction = (target_pos / map_scale - projectile_start_pos).normalized()
	
	# 2. Apply random spread: rotate the direction vector by a random angle
	var random_spread = deg_to_rad(randf_range(-MAX_SPREAD_ANGLE, MAX_SPREAD_ANGLE))
	projectile.direction = base_direction.rotated(random_spread)
	
	# 3. Set Position and Damage
	projectile.global_position = projectile_start_pos
	
	# Damage is the full base damage (no tick reduction)
	projectile.get_node("DamageSource").damage = damage + damage_buff 
	
	get_tree().current_scene.call_deferred("add_child", projectile)


# EDITED: Animation finish hook is adjusted for continuous fire
func _on_turret_animation_finished() -> void:
	if firing:
		
		# If the animation finished while we are still firing (because the timer is running)
		# we restart the 'Fire' animation to keep the visual effect going.
		if not enemies.is_empty():
			play_fire_animation()
		else:
			# If enemies are gone, stop the animation and reset state
			firing = false
			pending_target_pos = Vector2.ZERO
			
			# Reset idle anim
			match tower_level:
				1: turret.play("Default")
				2: turret.play("Default2")
				3: turret.play("Default3")

	# If not firing, just ensure idle animation is playing
	else:
		match tower_level:
			1: turret.play("Default")
			2: turret.play("Default2")
			3: turret.play("Default3")

func _apply_visuals_and_stats():
	#Applying visuals
	match tower_level:
		1: turret.play("Default")
		2: turret.play("Default2")
		3: turret.play("Default3")
	match tower_level:
		1:
			tower_base.frame = 0
			turret.frame = 0
			turret.position = Vector2(0,-32)
		2:
			tower_base.frame = 1
			turret.frame = 1
			turret.position = Vector2(0, -40)
		3:
			tower_base.frame = 2
			turret.frame = 2
			turret.position = Vector2(0, -50)
	# Applying stats and visuals
	range_area.shape.radius = current_range
	get_node("RangeArea").size = Vector2(current_range*2, current_range*2)
	get_node("RangeArea").position = Vector2(-current_range, -current_range)
	_on_turret_animation_finished()
	print("Damage level: " + str(damage_level))
	print("Speed level: " + str(fire_cooldown_level))
	print("Ra(n)ge level: " + str(range_level))


# --- Remaining functions from the base script structure (Unedited) ---

func play_fire_animation() -> void:
	match tower_level:
		1: turret.play("Fire")
		2: turret.play("Fire2")
		3: turret.play("Fire3")
