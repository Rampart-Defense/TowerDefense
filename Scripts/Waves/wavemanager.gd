extends Node



enum Difficulty { EASY, MEDIUM, HARD }
var difficulty: Difficulty = Difficulty.MEDIUM

# A flag to control whether new enemies can be spawned.
var is_spawning_stopped = false
# A reference to the Node2D where enemies will be spawned.
var enemies_container: Node2D = null
var current_session_id: int = 0

#Preload enemies
const goblinLVL1 = preload("res://Scenes/Enemies/GreenGoblins/goblin_lvl_1.tscn")
const goblinLVL2 = preload("res://Scenes/Enemies/GreenGoblins/goblin_lvl_2.tscn")
const goblinLVL3 = preload("res://Scenes/Enemies/GreenGoblins/goblin_lvl_3.tscn")
const goblinLVL4 = preload("res://Scenes/Enemies/GreenGoblins/goblin_lvl_4.tscn")
const goblinLVL5 = preload("res://Scenes/Enemies/GreenGoblins/goblin_lvl_5.tscn")
const goblinLVL6 = preload("res://Scenes/Enemies/GreenGoblins/goblin_lvl_6.tscn")
const goblinLVL7 = preload("res://Scenes/Enemies/GreenGoblins/goblin_lvl_7.tscn")
#waves data
const WAVES_FILE_PATH = "res://data/waves.json"

var enemy_scenes = {
	"goblinLVL1": goblinLVL1,
	"goblinLVL2": goblinLVL2,
	"goblinLVL3": goblinLVL3,
	"goblinLVL4": goblinLVL4,
	"goblinLVL5": goblinLVL5,
	"goblinLVL6": goblinLVL6,
	"goblinLVL7": goblinLVL7
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
	# Reset the spawning flag for the new wave
	current_session_id += 1
	is_spawning_stopped = false
	var file = FileAccess.open(WAVES_FILE_PATH, FileAccess.READ)
	if not file:
		print("Error: Could not open file at ", WAVES_FILE_PATH)
		return

	var content = file.get_as_text()
	var json_result = JSON.parse_string(content)
	if json_result is Dictionary:
		wave_data = json_result
		print("Successfully loaded wave data.")
		
		# Find the "Enemies" node to spawn into
		enemies_container = get_tree().current_scene.get_node("Enemies")
		if not enemies_container:
			print("Error: 'Enemies' Node2D not found in the scene tree. Spawning will not work.")
			return
		
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
	await spawn_wave_and_wait(wave_info, current_session_id)
	
func spawn_wave_and_wait(wave_info: Dictionary, session_id: int) -> void:
	if is_spawning_stopped:
		return
	enemies_alive = calculate_total_enemies_in_wave(wave_info)
	print("Spawning for Wave ", wave_info["wave_number"], " has started. Total enemies: ", enemies_alive)
	
	for enemy_group in wave_info["enemies"]:
		_spawn_enemy_group_after_delay(enemy_group, session_id)
	
	while enemies_alive > 0:
		await get_tree().process_frame
	
	# Check the flag before starting the next wave.
	# If spawning was stopped manually, we exit here.
	if is_spawning_stopped:
		return
		
	print("All enemies in Wave ", wave_info["wave_number"], " have been defeated!")
	start_wave()
	
# A helper function to spawn a group of enemies after a specified delay.
func _spawn_enemy_group_after_delay(enemy_group: Dictionary, session_id: int) -> void:
	var delay_before_spawn = enemy_group.get("delay_before_spawn", 0.0)
	var enemy_type = enemy_group["enemy_type"]
	var count = enemy_group["count"]
	var spawn_delay = enemy_group["spawn_delay"]
	
	await get_tree().create_timer(delay_before_spawn).timeout
	if session_id != current_session_id: return
	
	for i in range(count):
		# Check the flag before spawning
		if is_spawning_stopped or session_id != current_session_id:
			break
		spawn_single_enemy(enemy_type)
		await get_tree().create_timer(spawn_delay).timeout
		if session_id != current_session_id: return
		
# A function to spawn a single enemy.
func spawn_single_enemy(enemy_type: String) -> void:
	if not enemies_container:
		print("Error: Enemy container not set. Cannot spawn enemy.")
		return
		
	if enemy_scenes.has(enemy_type):
		var enemy_scene = enemy_scenes[enemy_type]
		var new_enemy = enemy_scene.instantiate()
		# Add the new enemy to the "enemies" group for easy management.
		new_enemy.add_to_group("enemies")
		
		var enemy_area: Area2D = new_enemy.find_child("EnemyHealthSystem")
		if enemy_area:
			enemy_area.died.connect(_on_enemy_died)
		else:
			print("Error: 'EnemyHealthSystem' node not found in enemy scene.")
		
		# Add the new enemy to the dedicated enemies container.
		enemies_container.add_child(new_enemy)
	else:
		print("Error: Enemy type '", enemy_type, "' not found in scene dictionary.")

func _on_enemy_died() -> void:
	enemies_alive -= 1
	print("An enemy has died. Enemies remaining: ", enemies_alive)

func _on_next_wave_button_pressed() -> void:
	start_wave()

# NEW FUNCTION to stop spawning and clear all enemies.
func stop_spawning_and_clear_enemies() -> void:
	# Set the flag to true to stop new enemies from spawning.
	is_spawning_stopped = true
	current_session_id += 1
	
	if not enemies_container:
		print("Error: Enemy container not set. Cannot clear enemies.")
		return
		
	# Get all children that are in the "enemies" group.
	# Using groups is a robust way to identify and manage nodes.
	for child in enemies_container.get_children():
		child.queue_free()
	# Reset the counter since all enemies have been removed.
	enemies_alive = 0
	current_wave = 0
	
	print("Spawning stopped and all enemies cleared.")
