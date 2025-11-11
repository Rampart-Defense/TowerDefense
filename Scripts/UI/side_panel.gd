extends Control
@onready var towershop= $TowerShop
@onready var startWaveButton = $StartWaves
@onready var stopWaveButton = $StopWaves
@onready var panel = $Panel
var is_hidden = false

func hide_shop():
	towershop.hide()

func show_shop():
	towershop.show()
	
func hide_all():
	panel.hide()
	towershop.hide()
	hide_buttons()
	
func show_all():
	panel.show()
	towershop.show()
	show_buttons()
	
func hide_buttons():
	startWaveButton.hide()
	stopWaveButton.hide()

func show_buttons():
	startWaveButton.show()
	stopWaveButton.show()

func _on_start_wave_button_down() -> void:
	Waves.start_wave_spawning()

func _on_stop_waves_button_down() -> void:
	Waves.stop_wave_spawning()
