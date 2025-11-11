extends TextureButton


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("Button ready")

func _on_start_waves_button_button_down() -> void:
	Waves.begin()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
