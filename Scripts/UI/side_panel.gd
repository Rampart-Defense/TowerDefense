extends Control
@onready var towershop= $TowerShop
@onready var startWaveButton = $TextureButton
@onready var panel = $Panel
var is_hidden = false

func hide_shop():
	towershop.hide()

func show_shop():
	towershop.show()

	
func hide_all():
	panel.hide()
	towershop.hide()
	startWaveButton.hide()
	

func show_all():
	panel.show()
	towershop.show()
	startWaveButton.show()


func _on_start_wave_button_down() -> void:
	Waves.begin()
