extends Area2D

#Sound
@export var sound: AudioStreamPlayer2D = null

# --- TILEMAP AND PLACEMENT CHECK RELATED ---
var tilemap: TileMapLayer = null
var placement_radius: int= 62
var footprint_size: int = 32
const TowerPlacementCheck = preload("res://Scripts/Towers/tower_placement_check.gd")

# --- Checking bool ---
var placing_tower: bool = false

#Tower lvl related
var tower_level: int = 1

#Timer variables to handle round stop and continue
var timer_base_time: float = 10.0
var time_left: float = 0.0
var wave_was_stopped = false

#percentual ammount for generating money
@export var lvl1_gains: float = 0.075 # 7.5%
@export var lvl2_gains: float = 0.1 # 10%
@export var lvl3_gains: float = 0.125 # 12.5%

@onready var tower_leveling_system: Control = $SimpleLevelUpSystem
#Visuals
@onready var animation =  $Tower

@onready var timer: Timer = $MoneyTimer
@onready var progress_bar = $ProgressBar

func _ready() -> void:
	_apply_visuals()
	progress_bar.max_value = timer.wait_time
	progress_bar.visible = false
	
	

func _process(delta: float) -> void:
	if progress_bar.visible:
		progress_bar.value = timer.time_left

func upgrade_tower(newLevel: int):
	tower_level = newLevel
	_apply_visuals()


#Placement check
func can_place() -> bool:
	return TowerPlacementCheck.can_place(self, footprint_size, placement_radius)


func generate_intrest():
	if PlayerStats.get_money() > 0 and not placing_tower:
		match tower_level:
			1:
				var money_to_add = int(PlayerStats.get_money() * lvl1_gains)
				animation.play("Generate1")
				PlayerStats.add_money(money_to_add)
				print("Added: "+ str(money_to_add))
			2:
				var money_to_add = int(PlayerStats.get_money() * lvl2_gains)
				PlayerStats.add_money(money_to_add)
				animation.play("Generate2")
				print("Added: "+ str(money_to_add))
			3:
				var money_to_add = int(PlayerStats.get_money() * lvl3_gains)
				PlayerStats.add_money(money_to_add)
				animation.play("Generate3")
				print("Added: "+ str(money_to_add))
		
		if sound:
			sound.play()

func _apply_visuals():
	match tower_level:
		1:
			animation.play("Default1")
			progress_bar.position =Vector2(-19, 40)
		2:
			animation.play("Default2")
			progress_bar.position =Vector2(-19, 32)
		3:
			animation.play("Default3")
			progress_bar.position =Vector2(-19, 25)


func get_next_payout() -> int:
	if PlayerStats.get_money() > 0 and not placing_tower:
		var money_to_add = 0
		match tower_level:
			1:
				money_to_add = int(PlayerStats.get_money() * lvl1_gains)
			2:
				money_to_add = int(PlayerStats.get_money() * lvl2_gains)
			3:
				money_to_add = int(PlayerStats.get_money() * lvl3_gains)
		return money_to_add
	else:
		return 0
		

func continue_generating_income():
	
	timer.start()

func stop_generating_income():
	wave_was_stopped = true
	if not timer.is_stopped():
		timer.wait_time = timer.time_left
	timer.stop()
	
func _on_tower_animation_finished() -> void:
	_apply_visuals() 


func _on_money_timer_timeout() -> void:
	if wave_was_stopped:
		timer.wait_time = timer_base_time
		wave_was_stopped = false
		timer.start()
	generate_intrest()
	tower_leveling_system.update_payout_text()


func _on_check_box_toggled(toggled_on: bool) -> void:
	progress_bar.visible = toggled_on 
