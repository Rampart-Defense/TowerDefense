extends Control
#The tower this leveling system is on(parent/base node)
@export var tower: Area2D = null
@export var sell_price: int = 100

@export var attack_damage_cost_1: int = 100
@export var attack_damage_value_1: int = 5

@export var attack_damage_cost_2: int = 150
@export var attack_damage_value_2: int = 5

# --- Attack Speed ---
@export var attack_speed_cost_1: int = 120
@export var attack_speed_value_1: float = 1.5

@export var attack_speed_cost_2: int = 200
@export var attack_speed_value_2: float = 2.0

# --- Range ---
@export var range_cost_1: int = 90
@export var range_value_1: int = 20

@export var range_cost_2: int = 160
@export var range_value_2: int = 20

#The buttons for disabling.
@onready var AttackspeedButton = $Panel/AttackspeedLevelUp
@onready var DamageButton = $Panel/DamageLevelUp
@onready var RangeButton = $Panel/RangeLevelUp
@onready var SellButton =$Panel/SellTower

#Statslabel for tower stats
@onready var StatsLabel = $Panel/StatsLabel
# bools for proper placement on screen
var too_far_up = false
var too_far_down = false
var too_far_left = false
var too_far_right = false


func _ready() -> void:
	# The InputManager will handle connecting this signal,
	# so you don't need to do it here anymore.
	
	# Set initial button text and prices
	AttackspeedButton.get_child(1).text = "cost: " + str(attack_speed_cost_1)
	DamageButton.get_child(1).text = "cost: " + str(attack_damage_cost_1)
	RangeButton.get_child(1).text = "cost: " + str(range_cost_1)
	
	update_sell_price()
	update_stats_display()
	# Initial check to set button disabled states
	_on_money_changed(PlayerStats.get_money())
	pass


func update_stats_display() -> void:
	"""
	Updates the text of the StatsLabel with the tower's current attributes
	and its respective upgrade levels.
	"""
	if tower == null or StatsLabel == null:
		push_error("Tower or StatsLabel is not set for display update.")
		return

	# Retrieve current actual stats
	var dmg: int = tower.damage
	var cd: float = tower.fire_cooldown
	var rng: float = tower.current_range

	# Retrieve current upgrade levels
	var dmg_lvl: int = tower.damage_level
	var cd_lvl: int = tower.fire_cooldown_level
	var rng_lvl: int = tower.range_level
	var t_lvl: int = tower.tower_level

	# Format the display text
	var stat_text: String = "Tower Level: %d\n" % [t_lvl]
	stat_text += "Damage: %d\n (Upgrades: %d/2)\n" % [dmg, dmg_lvl]
	stat_text += "Cooldown: %.2f\n (Upgrades: %d/2)\n" % [cd, cd_lvl]
	stat_text += "Range: %d\n (Upgrades: %d/2)" % [rng, rng_lvl]

	StatsLabel.text = stat_text

func _on_money_changed(money: int) -> void:
	if tower == null:
		return
		
	var current_money = money
	print("i saw that money")
	# Check Attack Speed Button
	if tower.fire_cooldown_level == 0:
		AttackspeedButton.disabled = current_money < attack_speed_cost_1
	elif tower.fire_cooldown_level == 1:
		AttackspeedButton.disabled = current_money < attack_speed_cost_2
	else:
		AttackspeedButton.disabled = true
	
	# Check Damage Button
	if tower.damage_level == 0:
		DamageButton.disabled = current_money < attack_damage_cost_1
	elif tower.damage_level == 1:
		DamageButton.disabled = current_money < attack_damage_cost_2
	else:
		DamageButton.disabled = true
	
	# Check Range Button
	if tower.range_level == 0:
		RangeButton.disabled = current_money < range_cost_1
	elif tower.range_level == 1:
		RangeButton.disabled = current_money < range_cost_2
	else:
		RangeButton.disabled = true
	
func _on_attackspeed_level_up_button_down() -> void:
	if tower != null:
		if tower.fire_cooldown_level == 0:
			AttackspeedButton.get_child(1).text = "cost: " + str(attack_speed_cost_2)
			tower.upgrade_tower("fire_rate", attack_speed_value_1)
			sell_price += attack_speed_cost_1/2
			update_sell_price()
			PlayerStats.spend_money(attack_speed_cost_1)
		elif tower.fire_cooldown_level == 1:
			AttackspeedButton.get_child(1).text = "MAX"
			sell_price += attack_speed_cost_2/2
			update_sell_price()
			tower.upgrade_tower("fire_rate", attack_speed_value_2)
			PlayerStats.spend_money(attack_speed_cost_2)
			AttackspeedButton.disabled = true
	else:
		push_error("Please set the tower for the tower leveling system.")
	update_stats_display()
	_on_money_changed(PlayerStats.get_money())


func _on_damage_level_up_button_down() -> void:
	if tower != null:
		if tower.damage_level == 0:
			DamageButton.get_child(1).text = "cost: " + str(attack_damage_cost_2)
			sell_price += attack_damage_cost_1/2
			update_sell_price()
			tower.upgrade_tower("damage", attack_damage_value_1)
			PlayerStats.spend_money(attack_damage_cost_1)
		elif tower.damage_level == 1:
			DamageButton.get_child(1).text = "MAX"
			sell_price += attack_damage_cost_2/2
			update_sell_price()
			tower.upgrade_tower("damage", attack_damage_value_2)
			PlayerStats.spend_money(attack_damage_cost_2)
			DamageButton.disabled = true
	else:
		push_error("Please set the tower for the tower leveling system.")
	update_stats_display()
	_on_money_changed(PlayerStats.get_money())


func _on_range_level_up_button_down() -> void:
	if tower != null:
		if tower.range_level == 0:
			RangeButton.get_child(1).text = "cost: " + str(range_cost_2)
			sell_price += range_cost_1/2.0
			update_sell_price()
			tower.upgrade_tower("range", range_value_1)
			PlayerStats.spend_money(range_cost_1)
		elif tower.range_level == 1:
			RangeButton.get_child(1).text = "MAX"
			sell_price += range_cost_2/2.0
			update_sell_price()
			tower.upgrade_tower("range", range_value_2)
			PlayerStats.spend_money(range_cost_2)
			RangeButton.disabled = true
	else:
		push_error("Please set the tower for the tower leveling system.")
	update_stats_display()
	_on_money_changed(PlayerStats.get_money())


func update_sell_price():
	SellButton.get_child(1).text = "price: " + str(sell_price)


func _on_sell_tower_pressed() -> void:
	self.visible = false
	PlayerStats.add_money(sell_price)
	tower.queue_free()
	var side_panel = GlobalUi.get_node("SidePanel")
	side_panel.show_shop()
