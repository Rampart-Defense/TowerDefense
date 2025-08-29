extends Node2D

var direction = Vector2.ZERO
@export var speed = 4

@onready var animation = $AnimatedSprite2D
func _ready():
	animation.play()
	if direction.length() > 0:
		rotation = direction.angle()

func _process(_delta):
	position += direction * speed 
