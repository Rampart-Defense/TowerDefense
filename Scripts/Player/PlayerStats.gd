extends Node
var _current_health: int
var _max_health: int 
var _money: int
var _points: int
var _wave: int

#Signals
const LEVEL_DEFEAT_SCENE = preload("res://Scenes/Menus/level_defeat.tscn")
const LEVEL_VICTORY_SCENE = preload("res://Scenes/Menus/level_victory.tscn")


signal health_changed(new_value: int) # this is for current_health
signal max_health_changed(new_value: int)
signal money_changed(new_value: int)
signal points_changed(new_value: int)
signal wave_changed(new_value: int)


# --- START GAME  ---
func start_game(difficulty: String):
	match difficulty:
		"MEDIUM":
			set_max_health(150)
			set_current_health(150)
			set_money(400)
		"HARD":
			set_max_health(10)
			set_current_health(100)
			set_money(300)
		# Default case for "EASY" or any other string
		"EASY":	
			set_max_health(200)
			set_money(500)
	set_wave(1)
	set_current_health(_max_health)
	set_points(0)

# --- SETTERS AND GETTERS ---


# --- HEALTH ---

func set_current_health(value: int) -> void:
	
	_current_health = clamp(value, 0, _max_health)
	health_changed.emit(_current_health)

func get_current_health() -> int:
	return _current_health

func set_max_health(value: int) -> void:
	_max_health = max(value, 1)
	_current_health = min(_current_health, _max_health)
	max_health_changed.emit(_max_health)

func get_max_health() -> int:
	return _max_health

func get_health_percent() -> float:
	return float(_current_health) / float(_max_health)

func damage_player(value: int):
	var temp = _current_health - value
	if temp <= 0:
		die()
	set_current_health(temp)

func die():
	Waves.stop_spawning_and_clear_enemies()
	TowerUpgradeManager.close_all_tower_upgrade_menus()
	print("Hävisit")
	var defeat_screen = LEVEL_DEFEAT_SCENE.instantiate()
	get_tree().root.add_child(defeat_screen)
	get_tree().paused = true

	
func _handle_victory() -> void:
	Waves.stop_spawning_and_clear_enemies()
	TowerUpgradeManager.close_all_tower_upgrade_menus()
	print("all waves cleared ez w")
	var victory_screen = LEVEL_VICTORY_SCENE.instantiate()
	get_tree().root.add_child(victory_screen)
	get_tree().paused = true

# --- MONEY ---
func set_money(value: int) -> void:
	_money = max(value, 0)
	money_changed.emit(_money) 

func get_money() -> int:
	return _money

func add_money(amount: int) -> void:
	set_money(_money + amount)

func spend_money(amount: int) -> bool:
	if _money >= amount:
		set_money(_money - amount)
		return true
	return false

# --- POINTS ---
func set_points(value: int) -> void:
	_points = max(value, 0)
	points_changed.emit(_points)
	
func get_points() -> int:
	return _points

func add_points(amount: int) -> void:
	set_points(_points + amount)


# --- Wave ---
func set_wave(value: int) -> void:
	_wave =  max(value, 0)
	wave_changed.emit(_wave)
	
	
