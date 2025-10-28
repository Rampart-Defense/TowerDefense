extends Control
@onready var money_label = $MoneyLabel
@onready var points_label = $PointsLabel
@onready var health_label = $HealthLabel



func _ready() -> void:
	# --- Signals for player stats
	PlayerStats.health_changed.connect(_on_health_changed)
	PlayerStats.money_changed.connect(_on_money_changed)
	PlayerStats.points_changed.connect(_on_points_changed)
	
	
	_on_health_changed(PlayerStats.get_current_health())
	_on_money_changed(PlayerStats.get_money())
	_on_points_changed(PlayerStats.get_points())
	



	

func _on_health_changed(new_value: int) -> void:
	# Update the ProgressBar value.

	# Update the health label text to show the current health and max health.
	health_label.text = str(new_value) 

func _on_money_changed(new_value: int) -> void:
	# Update the money label text.
	money_label.text = str(new_value)

func _on_points_changed(new_value: int) -> void:
	# Update the points label text.
	points_label.text = str(new_value)
