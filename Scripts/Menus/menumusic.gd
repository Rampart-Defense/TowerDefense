extends AudioStreamPlayer2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	volume_db = -40 # start very quiet
	play()
	var tween = get_tree().create_tween()
	tween.tween_property(self, "volume_db", 0, 3.0) # fade in over 2 seconds

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
