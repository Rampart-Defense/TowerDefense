extends Node2D

var direction = Vector2.ZERO
@export var speed = 400.0
@export var death_time: float = 2.0
@onready var animation = $AnimatedSprite2D
@export var on_hit_animation: PackedScene = null
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
	var death_timer = $DeathTimer
	death_timer.timeout.connect(_on_death_timer_timeout)
	death_timer.wait_time = death_time
	death_timer.start()
	animation.play()
	if direction.length() > 0:
		rotation = direction.angle()

func _process(delta):
	position += direction * speed * delta 


func _on_death_timer_timeout() -> void:
	queue_free()
