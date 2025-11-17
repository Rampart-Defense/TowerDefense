extends Control
@onready var money_label = $MoneyLabel
@onready var health_label = $HealthLabel
@onready var wave_label = $WaveLabel
@onready var difficulty: String
var max_wave: int

func _ready() -> void:
	# --- Signals for player stats
	PlayerStats.health_changed.connect(_on_health_changed)
	PlayerStats.money_changed.connect(_on_money_changed)
	PlayerStats.wave_changed.connect(_on_wave_changed)
	
	_on_health_changed(PlayerStats.get_current_health())
	_on_money_changed(PlayerStats.get_money())
	
func _on_health_changed(new_value: int) -> void:
	# Update the ProgressBar value.

	# Update the health label text to show the current health and max health.
	health_label.text = str(new_value) 

func _on_money_changed(new_value: int) -> void:
	# Update the money label text.
	money_label.text = str(new_value)

func _on_wave_changed(new_value: int) -> void:
	#Update the wave lable text.
	if new_value == 1:
		_get_max_wave()
		
	wave_label.text = "Wave: " + str(new_value) + " / " + str(max_wave)
	
func _get_max_wave() -> void:
	difficulty = PlayerStats.get_difficulty()
	print("_get_max_wave difficulty: " + difficulty)
	match difficulty:
		"Easy":
			max_wave = 40
		"Medium":
			max_wave = 60
		"Hard":
			max_wave = 80
