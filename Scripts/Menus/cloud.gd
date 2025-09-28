extends Sprite2D

@export var speed: float = 20.0 # pixels per second

func _process(delta: float) -> void:
	# Move cloud to the right
	position.x += speed * delta

	# Wrap cloud to left when it goes offscreen
	var screen_width = get_viewport_rect().size.x
	if position.x > screen_width + texture.get_width() / 2:
		position.x = -texture.get_width() / 2
