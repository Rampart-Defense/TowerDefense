extends CharacterBody2D

@export var movement_speed = 100.0
@export var damage: int = 1
@onready var health_component = $EnemyHealthSystem

# A small buffer for checking if we've reached the end of the path.
var reached_distance = 5

@onready var animation: AnimatedSprite2D = $AnimatedSprite2D

var path_follower: PathFollow2D = null
var previous_position: Vector2 = Vector2.ZERO

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
	
	# Add the PathFollow2D to the Path2D node in the scene tree.
	path_node.add_child(path_follower)
	

	# Set the enemy's position to the beginning of the path.
	global_position = path_follower.global_position
	previous_position = global_position


func _physics_process(_delta: float) -> void:
	if not path_follower:
		return
		
	# Move the enemy along the path using the PathFollow2D's progress.
	path_follower.progress += movement_speed * _delta
	
	# The enemy's position is automatically updated by the PathFollow2D.
	# Calculate the enemy's velocity for animation.
	var current_position = path_follower.global_position
	velocity = (current_position - previous_position) / _delta
	previous_position = current_position
	update_animation(velocity)
	move_and_slide()
	# Check if we have reached the end of the path.
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
