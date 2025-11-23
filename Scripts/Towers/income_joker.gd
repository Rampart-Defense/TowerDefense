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
@export var lvl1_gains: float = 0.05 # 5%
@export var lvl2_gains: float = 0.075 # 7,5%
@export var lvl3_gains: float = 0.1 # 10%

@export var health_gain1: float = 0.01 #1%heal
@export var health_gain2: float = 0.02 #2%heal
@export var health_gain3: float = 0.03 #3%heal

# checking bool for animation
var money_or_health: bool = false # false = health, true = money

@onready var tower_leveling_system: Control = $SimpleLevelUpSystem
#Visuals
@onready var animation =  $Turret
const coin_icon = preload("res://Art/VisualArt/UI/SideBar/GeminiCoin.png")
const heart_icon = preload("res://Art/VisualArt/UI/SideBar/Heart.png")

@onready var timer: Timer = $MoneyTimer
@onready var progress_bar = $ProgressBar
@onready var tower_base = $TowerBase

func _ready() -> void:
	randomize()
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
	animation.play("Generate1")
	if PlayerStats.get_money() > 0:
		PlayerStats.add_money(get_next_payout())
		if sound:
			sound.play()

func generate_health():
	animation.play("Generate2")
	if sound:
		sound.play()
	if PlayerStats.get_current_health() < PlayerStats.get_max_health():
		match tower_level:
			1:
				PlayerStats.heal_player(int(PlayerStats.get_max_health() * health_gain1))
			2:
				PlayerStats.heal_player(int(PlayerStats.get_max_health() * health_gain2))
			3:
				PlayerStats.heal_player(int(PlayerStats.get_max_health() * health_gain3))
		

func generate_info_icon():
	# Determine which icon to use
	var icon_texture: Texture2D
	if money_or_health:
		# Money outcome (coin)
		icon_texture = coin_icon
	else:
		# Heal outcome (heart)
		icon_texture = heart_icon

	# 1. Create a new Sprite2D node for the icon
	var info_icon = Sprite2D.new()
	info_icon.texture = icon_texture
	
	# Set the starting position slightly above the tower (adjust position as needed)
	info_icon.position = Vector2(0, -50)
	info_icon.scale = Vector2(0.2,0.2)
	# Add the icon to the scene tree as a child of the tower
	add_child(info_icon)

	# 2. Create the Tween for the animation
	var tween = create_tween()
	
	# Calculate the target position (bounce height)
	var target_pos = info_icon.position - Vector2(0, 40) # Bounce 40 units up
	
	# Define the animation sequence:
	# Step 1: Move up quickly (bounce)
	tween.tween_property(info_icon, "position", target_pos, 0.3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART)
	
	# Step 2: Fade out while staying at the top
	tween.tween_property(info_icon, "modulate:a", 0.0, 0.6).set_delay(0.2) # Fade out over 0.6s after a 0.2s pause
	
	# 3. Clean up the node when the animation is finished
	tween.tween_callback(info_icon.queue_free)

func _apply_visuals():
	match tower_level:
		1:
			tower_base.frame = 0
			progress_bar.position =Vector2(-19, 40)
		2:
			tower_base.frame = 1
		3:
			tower_base.frame = 2

	if money_or_health:
		animation.play("Default2")
	else:
		animation.play("Default1")

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
		

func get_random_outcome():
	# Use randi() to get a random integer, and modulo 2 (% 2) 
	# to ensure the result is either 0 or 1.
	var roll = randi() % 2
	
	if roll == 0:
		# 50% chance
		money_or_health = false
	else: # roll == 1
		# 50% chance
		money_or_health = true



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
	if not placing_tower:
		get_random_outcome()
		generate_info_icon()
		if money_or_health:
			generate_intrest()
		else:
			generate_health()
	tower_leveling_system.update_payout_text()


func _on_check_box_toggled(toggled_on: bool) -> void:
	progress_bar.visible = toggled_on 
