extends Node2D

func _ready():
	
	
	var animation = $AnimatedSprite2D

	animation.animation_finished.connect(_die)
	

func _die() -> void:
	queue_free()
