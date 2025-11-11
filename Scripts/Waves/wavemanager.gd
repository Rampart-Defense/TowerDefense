extends Node

enum Difficulty { EASY, MEDIUM, HARD }
var difficulty: Difficulty = Difficulty.MEDIUM

# A flag to control whether new enemies can be spawned.
var is_spawning_stopped = false
# A reference to the Node2D where enemies will be spawned.
var current_session_id: int = 0

var paths: Array[Path2D] = []
var current_path_index = 0

#Preload enemies
const goblin_tribesmanLVL1 = preload("res://Scenes/Enemies/GreenGoblins/goblin-tribesman_lvl_1.tscn")
const goblin_huntsmanLVL1 = preload("res://Scenes/Enemies/GreenGoblins/goblin-huntsman_lvl_1.tscn")
const goblin_battle_boyLVL1 = preload("res://Scenes/Enemies/GreenGoblins/goblin-battle-boy_lvl_1.tscn")
const goblin_battle_veteranLVL1 = preload("res://Scenes/Enemies/GreenGoblins/goblin-battle-veteran_lvl_1.tscn")
const goblin_apprentice_shamanLVL1 = preload("res://Scenes/Enemies/GreenGoblins/goblin-apprentice-shaman_lvl_1.tscn")
const goblin_tribes_guardLVL1 = preload("res://Scenes/Enemies/GreenGoblins/goblin-tribesguard_lvl_1.tscn")
const goblin_battle_masterLVL1 = preload("res://Scenes/Enemies/GreenGoblins/goblin-battle-master_lvl_1.tscn")
const goblin_high_shamanLVL1 = preload("res://Scenes/Enemies/GreenGoblins/goblin-high-shaman_lvl_1.tscn")
const goblin_heavy_guardLVL1 = preload("res://Scenes/Enemies/GreenGoblins/goblin-heavy-guard_lvl_1.tscn")
const goblin_light_conjurerLVL1 = preload("res://Scenes/Enemies/GreenGoblins/goblin-light-conjurer_lvl_1.tscn")

const goblin_tribesmanLVL2 = preload("res://Scenes/Enemies/RedGoblins/goblin-tribesman_lvl_2.tscn")
const goblin_huntsmanLVL2 = preload("res://Scenes/Enemies/RedGoblins/goblin-huntsman_lvl_2.tscn")
const goblin_tribes_guardLVL2 = preload("res://Scenes/Enemies/RedGoblins/goblin-tribes-guard_lvl_2.tscn")
const goblin_heavy_guardLVL2 = preload("res://Scenes/Enemies/RedGoblins/goblin-heavy-guard_lvl_2.tscn")
const goblin_light_conjurerLVL2 = preload("res://Scenes/Enemies/RedGoblins/goblin-light-conjurer_lvl_2.tscn")
const goblin_battle_boyLVL2 = preload("res://Scenes/Enemies/RedGoblins/goblin-battle-boy_lvl_2.tscn")
const goblin_battle_veteranLVL2 = preload("res://Scenes/Enemies/RedGoblins/goblin-battle-veteran_lvl_2.tscn")
const goblin_battle_masterLVL2 = preload("res://Scenes/Enemies/RedGoblins/goblin-battle-master_lvl_2.tscn")
const goblin_apprentice_shamanLVL2 = preload("res://Scenes/Enemies/RedGoblins/goblin-apprentice-shaman_lvl_2.tscn")
const goblin_high_shamanLVL2 = preload("res://Scenes/Enemies/RedGoblins/goblin-high-shaman_lvl_2.tscn")
const boss1 = preload("res://Scenes/Enemies/Bosses/Boss_1.tscn")
const boss2 = preload("res://Scenes/Enemies/Bosses/Boss_2.tscn")
const boss3 = preload("res://Scenes/Enemies/Bosses/Boss_3.tscn")
const boss4 = preload("res://Scenes/Enemies/Bosses/Boss_4.tscn")
const boss5 = preload("res://Scenes/Enemies/Bosses/Boss_5.tscn")
const boss6 = preload("res://Scenes/Enemies/Bosses/Boss_6.tscn")
const boss7 = preload("res://Scenes/Enemies/Bosses/Boss_7.tscn")
const boss8 = preload("res://Scenes/Enemies/Bosses/Boss_8.tscn")

#waves data
const WAVES_FILE_PATH = "res://data/waves.json"

var enemy_scenes = {
	"goblin_tribesmanLVL1": goblin_tribesmanLVL1,
	"goblin_huntsmanLVL1": goblin_huntsmanLVL1,
	"goblin_battle_boyLVL1": goblin_battle_boyLVL1,
	"goblin_battle_veteranLVL1": goblin_battle_veteranLVL1,
	"goblin_apprentice_shamanLVL1": goblin_apprentice_shamanLVL1,
	"goblin_battle_masterLVL1": goblin_battle_masterLVL1,
	"goblin_tribes_guardLVL1": goblin_tribes_guardLVL1,
	"goblin_heavy_guardLVL1": goblin_heavy_guardLVL1,
	"goblin_light_conjurerLVL1": goblin_light_conjurerLVL1,
	"goblin_high_shamanLVL1": goblin_high_shamanLVL1,
	"goblin_tribesmanLVL2": goblin_tribesmanLVL2,
	"goblin_huntsmanLVL2": goblin_huntsmanLVL2,
	"goblin_tribes_guardLVL2": goblin_tribes_guardLVL2,
	"goblin_heavy_guardLVL2": goblin_heavy_guardLVL2,
	"goblin_light_conjurerLVL2": goblin_light_conjurerLVL2,
	"goblin_battle_boyLVL2": goblin_battle_boyLVL2,
	"goblin_battle_veteranLVL2": goblin_battle_veteranLVL2,
	"goblin_battle_masterLVL2": goblin_battle_masterLVL2,
	"goblin_apprentice_shamanLVL2": goblin_apprentice_shamanLVL2,
	"goblin_high_shamanLVL2": goblin_high_shamanLVL2,
	"boss1": boss1,
	"boss2": boss2,
	"boss3": boss3,
	"boss4": boss4,
	"boss5": boss5,
	"boss6": boss6,
	"boss7": boss7,
	"boss8": boss8,	
}
var wave_data = {}

var current_wave = 0
var enemies_alive = 0
var should_continue_waves = true
var gold_gained_this_wave: int = 0


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
		
		get_paths()
		
		start_wave()
	else:
		print("Error: Failed to parse JSON data.")


func get_paths() -> void:
	# FIND THE PATHS USING GROUPS
	paths.clear()
	var found_paths = get_tree().get_nodes_in_group("path")
	for p in found_paths:
		if p is Path2D:
			paths.append(p)
	current_path_index = 0
	if paths.is_empty():
		print("Error: No Path2D nodes found in group 'path'. Enemies will not spawn correctly.")
	else:
		print("Found paths: ", paths.size())

func start_wave() -> void:
	
	current_wave += 1
	print(current_wave)
	PlayerStats.set_wave(current_wave)
	if current_wave > wave_data["waves"].size():
		current_wave = 0
		PlayerStats._handle_victory()
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
	_calculate_end_of_round_payout()
	
	if should_continue_waves:
		# Only start the next wave if the flag is true
		start_wave()
	else:
		# Stop the wave progression and perhaps notify the player.
		print("Waves are currently paused. Press Start Wave to continue.")
		
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

	if paths.is_empty():
		print("Error: No paths found. Cannot spawn enemy.")
		return

	if enemy_scenes.has(enemy_type):
		var enemy_scene = enemy_scenes[enemy_type]
		var new_enemy = enemy_scene.instantiate()
		# Add the new enemy to the "enemies" group for easy management.
		new_enemy.add_to_group("enemies")
		
		# Get the path the enemies are supposed to use
		var current_path = paths[current_path_index]
		#print("Current path child: ",current_path.get_child(0))
		current_path.add_child(new_enemy)
		current_path_index = (current_path_index + 1) % paths.size()

		var enemy_area: Area2D = new_enemy.find_child("EnemyHealthSystem")
		if enemy_area:
			enemy_area.died.connect(_on_enemy_died)
		else:
			print("Error: 'EnemyHealthSystem' node not found in enemy scene.")
		
	else:
		print("Error: Enemy type '", enemy_type, "' not found in scene dictionary.")

func _on_enemy_died(gold_value: int) -> void:
	enemies_alive -= 1
	gold_gained_this_wave += gold_value
	print("An enemy has died. Enemies remaining: ", enemies_alive)

func _on_next_wave_button_pressed() -> void:
	start_wave()

# NEW FUNCTION to stop spawning and clear all enemies.
func stop_spawning_and_clear_enemies() -> void:
	# Set the flag to true to stop new enemies from spawning.
	is_spawning_stopped = true
	#increment current_session_id to start the wave at beginning next time.
	current_session_id += 1
	
	# Clear enemies using the "enemies" group (works no matter where they are parented).
	var enemies = get_tree().get_nodes_in_group("enemies")
	for enemy in enemies:
		if is_instance_valid(enemy):
			enemy.queue_free()
	
	# Reset counters
	enemies_alive = 0
	current_wave = 0
	
	print("Spawning stopped and all enemies cleared.")
	
func stop_wave_spawning():
	if current_wave != 0:
		should_continue_waves = false
		print("Wave spawning paused after current wave finishes.")
	
func start_wave_spawning():
	# If should_continue_waves initial value is true, then call begin(). 
	# Else the values is always false, meaning stop button was pressed and now resume spawning  
	if should_continue_waves:
		begin()
	else: 
		should_continue_waves = true
		print("Wave spawing resumed.")
		start_wave()
	
func _calculate_end_of_round_payout(): # <--- NEW function
	var payout_amount = floor(gold_gained_this_wave * 0.2)
	PlayerStats.add_money(payout_amount)
	print("End of Round Payout: ", payout_amount, " gold (", 20, "% of ", gold_gained_this_wave, " earned).")
	gold_gained_this_wave = 0
