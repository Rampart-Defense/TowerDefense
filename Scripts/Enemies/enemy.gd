extends Node2D

@export var movement_speed = 100.0
@export var damage: int = 1
@onready var health_component = $EnemyHealthSystem

# A small buffer for checking if we've reached the end of the path.
var reached_distance = 5

@onready var animation: AnimatedSprite2D = $AnimatedSprite2D

var path_follower: PathFollow2D = null
var direction_vector: Vector2


var stunned: bool = false
var flash_tween: Tween = null

func _ready():
	# Find the Path2D node in the current scene.
	var path_node = get_parent()
	#print("PATH NODE: ", path_node)
	if not path_node:
		push_error("Could not find a Path2D nodes in the current scene!")
		return
	
	# Create a PathFollow2D node to handle movement along the path.
	path_follower = PathFollow2D.new()
	path_follower.h_offset = 0 # Ensure the enemy starts at the beginning of the path.
	path_follower.set_rotates(false)
	# Add the PathFollow2D to the Path2D node in the scene tree.
	path_node.add_child(path_follower)
	var ysortter = TowersNode.get_ysorter()
	# Make the enemy a child of the PathFollow2D.
	if ysortter:
		self.reparent(ysortter, true) 
	# Set the enemy's position to the beginning of the path.
		self.position = path_follower.position
	# Store the reference for later use in _physics_process



func _physics_process(delta: float) -> void:
	if stunned or not path_follower:
		return
	# 1. Store the enemy's global position before movement update.
	var current_global_position = global_position
	
	# 2. Move the PathFollower (The enemy moves with it automatically)
	path_follower.progress += movement_speed * delta
	self.position = path_follower.position
	# 3 We use the vector difference between the new position and the old position.
	direction_vector = (global_position - current_global_position).normalized()
	
	# 4. Update animation based on this derived direction
	update_animation(direction_vector)
	
	# 5. Check if we have reached the end of the path.
	var path_length = path_follower.get_parent().get_curve().get_baked_length()
	if path_follower.progress >= path_length - reached_distance:
		enemy_win()

func enemy_win():
	PlayerStats.damage_player(damage)
	print("Enemy has reached the goal!")
	if health_component:
		health_component.die("win")
	else:
		print("Health component not found, cannot call die().")

func stun_enemy():
	stunned = true
	var current_velocity = direction_vector
	if current_velocity.length_squared() > 0:
		if abs(current_velocity.x) > abs(current_velocity.y):
			if current_velocity.x > 0:
				animation.play("stun_right")
			else:
				animation.play("stun_left")
		else:
			if current_velocity.y > 0:
				animation.play("stun_down")
			else:
				animation.play("stun_up")
	else:
		animation.play("stun_up")
	

func hurt():
	if is_instance_valid(animation):
		# 1. Kill the previously running tween if it exists.
		# This stops the old flash fade-out immediately.
		if flash_tween:
			flash_tween.kill()
		
		# 2. Define colors and duration
		var flash_duration = 0.1
		var normal_color = Color(1, 1, 1, 1) # White (normal)
		var flash_color = Color(1, 0, 0, 1) # Red
		
		# 3. Set initial color to red immediately (The actual flash part)
		animation.modulate = flash_color
		
		# 4. Create a new Tween and store its reference.
		flash_tween = create_tween()
		
		# 5. Tween back to normal color (white) over the duration
		flash_tween.tween_property(animation, "modulate", normal_color, flash_duration)

func update_animation(current_velocity: Vector2) -> void:
	if current_velocity.length_squared() > 0:
		if abs(current_velocity.x) > abs(current_velocity.y):
			if current_velocity.x > 0:
				animation.play("walk_right")
			else:
				animation.play("walk_left")
		else:
			if current_velocity.y > 0:
				animation.play("walk_down")
			else:
				animation.play("walk_up")
	else:
		animation.play("idle")
