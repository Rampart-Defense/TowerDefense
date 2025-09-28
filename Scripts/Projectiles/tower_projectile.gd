extends Node2D

var direction = Vector2.ZERO
@export var speed = 400.0
@export var death_time: float = 2.0
@onready var animation = $AnimatedSprite2D
@export var on_hit_animation: PackedScene = null

func _ready():
	var death_timer = $DeathTimer
	death_timer.timeout.connect(_on_death_timer_timeout)
	death_timer.wait_time = death_time
	death_timer.start()
	print(death_timer)
	animation.play()
	if direction.length() > 0:
		rotation = direction.angle()

func _process(delta):
	position += direction * speed * delta 


func _on_death_timer_timeout() -> void:
	queue_free()
