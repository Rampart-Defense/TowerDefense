extends Node2D
@export var move_duration: float = 0.3

func _ready():
	
	
	
	var damage_source_area = $DamageSource/DamageArea
	var animation = $AnimatedSprite2D

	animation.animation_finished.connect(_die)
	
	
	# Create a new Tween object. A Tween handles animating properties over time.
	var tween = create_tween()
	# The `tween_property` function takes four arguments:
	# 1. The object to animate (in this case, our damage_source_area).
	# 2. The property to animate (its "position").
	# 3. The final value of the property (a Vector2 with an x of 40 and a y of 0).
	# 4. The duration of the animation (our exposed `move_duration` variable).
	tween.tween_property(damage_source_area, "position", Vector2(40, 0), move_duration)


func _die() -> void:
	queue_free()
