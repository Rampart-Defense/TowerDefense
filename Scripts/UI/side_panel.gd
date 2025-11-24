extends Control
@onready var towershop= $TowerShop
@onready var startWaveButton = $StartWaves
@onready var stopWaveButton = $StopWaves
@onready var panel = $Panel
var is_hidden = false
var can_start_waves = Waves.should_continue_waves

func _ready() -> void:
	if Waves.has_signal("wave_progression_paused"):
		Waves.wave_progression_paused.connect(_on_wave_progression_paused)

func hide_shop():
	towershop.hide()

func show_shop():
	towershop.show()
	
func hide_all():
	panel.hide()
	towershop.hide()
	hide_buttons()
	can_start_waves = true
	
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
	_update_button_states()
	
func _on_wave_progression_paused() -> void:
	print("UI received: Wave progression paused signal.")
	can_start_waves = true
	_update_button_states()
	startWaveButton.disabled = false
	
func _update_button_states() -> void:
	if can_start_waves:
		stopWaveButton.disabled = true
	else:
		startWaveButton.disabled = true
		stopWaveButton.disabled = false
	
func _on_start_wave_button_down() -> void:
	if can_start_waves:
		SoundManager.get_node("buttonpress").play()
		Waves.start_wave_spawning()
		can_start_waves = false
		_update_button_states()

func _on_stop_waves_button_down() -> void:
	if !can_start_waves:
		SoundManager.get_node("buttonpress").play()
		Waves.stop_wave_spawning()
		can_start_waves = true
		_update_button_states()
