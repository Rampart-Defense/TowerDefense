extends Node2D
var damage_tracking_callback: Callable

func set_damage_callback(callback: Callable):
	# 1. Store the callback
	damage_tracking_callback = callback

	# 2. Get the child node by name
	var damage_node = $DamageSource 

	# 3. Check if the child exists AND has the function before calling
	if damage_node and damage_node.has_method("set_damage_callback"):
		damage_node.set_damage_callback(damage_tracking_callback)
	else:
		print("ERROR: Could not find or set damage callback on DamageSource child.")

func _ready():
	
	
	var animation = $AnimatedSprite2D

	animation.animation_finished.connect(_die)
	

func _die() -> void:
	queue_free()
