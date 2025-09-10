extends Node

var spawner_location: Marker2D = null

enum Difficulty { EASY, MEDIUM, HARD }
var difficulty: Difficulty = Difficulty.MEDIUM

func set_spawner_location(marker: Node2D):
	spawner_location = marker

const CLAMPBEETLE = preload("res://Scenes/Enemies/clampbeetle.tscn")
const WAVES_FILE_PATH = "res://data/waves.json"

var enemy_scenes = {
	"clampbeetle": CLAMPBEETLE
}
var wave_data = {}

var current_wave = 0
var enemies_alive = 0

func calculate_total_enemies_in_wave(wave_info: Dictionary) -> int:
	var total_enemies = 0
	for enemy_group in wave_info["enemies"]:
		if enemy_group.has("count"):
			total_enemies += enemy_group["count"]
	return total_enemies

func begin() -> void:
	var file = FileAccess.open(WAVES_FILE_PATH, FileAccess.READ)
	if not file:
		print("Error: Could not open file at ", WAVES_FILE_PATH)
		return

	var content = file.get_as_text()
	var json_result = JSON.parse_string(content)
	if json_result is Dictionary:
		wave_data = json_result
		print("Successfully loaded wave data.")
		start_wave()
	else:
		print("Error: Failed to parse JSON data.")

func start_wave() -> void:
	current_wave += 1
	print(current_wave)
	
	if current_wave > wave_data["waves"].size():
		print("All waves completed! Game over.")
		return

	var wave_info = wave_data["waves"][current_wave - 1]
	print("Starting Wave ", wave_info["wave_number"])
	await spawn_wave_and_wait(wave_info)
	
func spawn_wave_and_wait(wave_info: Dictionary) -> void:
	enemies_alive = calculate_total_enemies_in_wave(wave_info)
	print("Spawning for Wave ", wave_info["wave_number"], " has started. Total enemies: ", enemies_alive)
	
	for enemy_group in wave_info["enemies"]:
		_spawn_enemy_group_after_delay(enemy_group)
	
	while enemies_alive > 0:
		await get_tree().process_frame
		
	print("All enemies in Wave ", wave_info["wave_number"], " have been defeated!")
	start_wave()
	
# A helper function to spawn a group of enemies after a specified delay.
func _spawn_enemy_group_after_delay(enemy_group: Dictionary) -> void:
	var delay_before_spawn = enemy_group.get("delay_before_spawn", 0.0)
	var enemy_type = enemy_group["enemy_type"]
	var count = enemy_group["count"]
	var spawn_delay = enemy_group["spawn_delay"]
	
	await get_tree().create_timer(delay_before_spawn).timeout
	
	for i in range(count):
		spawn_single_enemy(enemy_type)
		await get_tree().create_timer(spawn_delay).timeout
		
# A function to spawn a single enemy.
func spawn_single_enemy(enemy_type: String) -> void:
	if enemy_scenes.has(enemy_type):
		var enemy_scene = enemy_scenes[enemy_type]
		var new_enemy = enemy_scene.instantiate()
		
		var enemy_area: Area2D = new_enemy.find_child("EnemyHealthSystem")
		if enemy_area:
			enemy_area.died.connect(_on_enemy_died)
		else:
			print("Error: 'EnemyHealthSystem' node not found in enemy scene.")
		
		get_parent().add_child(new_enemy)
	else:
		print("Error: Enemy type '", enemy_type, "' not found in scene dictionary.")

func _on_enemy_died() -> void:
	enemies_alive -= 1
	print("An enemy has died. Enemies remaining: ", enemies_alive)

func _on_next_wave_button_pressed() -> void:
	start_wave()
