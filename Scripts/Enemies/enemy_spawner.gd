extends Node

# === CONFIG ===
enum Difficulty { EASY, MEDIUM, HARD }
var difficulty: Difficulty = Difficulty.MEDIUM



#SpawnerPoint
var spawner_location: Marker2D = null

#Enemies(TODO add more)
@onready var enemy_scene: PackedScene = preload("res://Scenes/Enemies/clampbeetle.tscn")

# Wave control
var current_wave: int = 0
var max_waves: int = 30
var enemies_per_wave_base: int = 5
var wave_active: bool = false
var wave_cooldown: float = 3.0  # seconds between waves

# Track enemies
var alive_enemies: Array = []

# Signals
signal wave_started(wave_number: int)
signal wave_completed(wave_number: int)

func _ready():

	print("EnemySpawner ready. Difficulty =", difficulty)

# Set difficulty
func set_difficulty(new_difficulty: Difficulty):
	difficulty = new_difficulty

# Link the spawner location (Marker2D)
func set_spawner_location(marker: Node2D):
	spawner_location = marker

# Start waves
func start_waves():
	if not spawner_location or not enemy_scene:
		push_warning("Spawner location or enemy scene not set!")
		return
	current_wave = 0
	_start_next_wave()

func _start_next_wave():
	if current_wave >= max_waves:
		print("All waves completed!")
		return
	
	current_wave += 1
	wave_active = true
	alive_enemies.clear()
	emit_signal("wave_started", current_wave)
	
	var enemy_count = _calculate_enemies_for_wave(current_wave)
	print("Spawning wave %s with %s enemies" % [current_wave, enemy_count])
	
	for i in range(enemy_count):
		_spawn_enemy(i)

func _calculate_enemies_for_wave(wave: int) -> int:
	var base = enemies_per_wave_base * wave
	match difficulty:
		Difficulty.EASY:
			return int(base * 0.75)
		Difficulty.MEDIUM:
			return base
		Difficulty.HARD:
			return int(base * 1.5)
	return base

func _spawn_enemy(index: int):
	

	var enemy = enemy_scene.instantiate()
	
	var enemies_container = get_tree().current_scene.get_node_or_null("Enemies")
	if enemies_container == null:
		push_error("Cannot spawn enemy: No Node2D named 'Enemies' found in the current scene!")
		return
	var spacing = 32  # horizontal distance between enemies
	var start_pos = spawner_location.global_position
	var x_offset = -index * spacing
	var y_offset = randf_range(-5, 5)  # small random vertical variation
	enemy.global_position = start_pos + Vector2(x_offset, y_offset)
	#var size = randf_range(0.8, 1.2)
	
	#Random Scaling
	#enemy.scale = Vector2(size, size)


	

	enemies_container.add_child(enemy)
	print("Spawned enemy at:", enemy.global_position)
	
	alive_enemies.append(enemy)
	# When enemy is removed (killed), check if wave is cleared
	enemy.tree_exited.connect(_on_enemy_removed.bind(enemy))

func _on_enemy_removed(enemy):
	alive_enemies.erase(enemy)
	if alive_enemies.is_empty() and wave_active:
		_finish_wave()

func _finish_wave():
	wave_active = false
	emit_signal("wave_completed", current_wave)
	
	var t = Timer.new()
	t.wait_time = wave_cooldown
	t.one_shot = true
	t.timeout.connect(_start_next_wave)
	add_child(t)
	t.start()
