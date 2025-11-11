extends Control
#The tower this leveling system is on(parent/base node)
@export var tower: Area2D = null
@export var sell_price: int = 100

@export var level_2_cost: int = 2500
@export var level_3_cost: int = 5000

#The buttons for disabling.
@onready var TowerLevelUpButton = $Panel/TowerLevelUp

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
	if tower == null:
		queue_free()
	# Set initial button text and prices
	TowerLevelUpButton.get_child(1).text = "cost: " + str(level_2_cost)

	
	update_sell_price()
	update_stats_display()
	# Initial check to set button disabled states
	_on_money_changed(PlayerStats.get_money())
	


func update_stats_display() -> void:
	pass

func _on_money_changed(money: int) -> void:
	if tower == null:
		return
		
	var current_money = money
	print("i saw that money")
	# Check Attack Speed Button
	if tower.tower_level == 1:
		TowerLevelUpButton.disabled = current_money < level_2_cost
	elif tower.tower_level == 2:
		TowerLevelUpButton.disabled = current_money < level_3_cost
	else:
		TowerLevelUpButton.disabled = true
	update_stats_display()



func update_sell_price():
	SellButton.get_child(1).text = "price: " + str(sell_price)


func _on_sell_tower_pressed() -> void:
	self.visible = false
	PlayerStats.add_money(sell_price)
	tower.queue_free()
	var side_panel = GlobalUi.get_node("SidePanel")
	side_panel.show_shop()


func _on_tower_level_up_button_down() -> void:
	if tower != null:
		if tower.tower_level == 1:
			TowerLevelUpButton.get_child(1).text = "cost: " + str(level_3_cost)
			tower.upgrade_tower(2)
			sell_price += level_2_cost/2
			update_sell_price()
			PlayerStats.spend_money(level_2_cost)
		elif tower.tower_level == 2:
			TowerLevelUpButton.get_child(1).text = "MAX"
			sell_price += level_3_cost/2
			update_sell_price()
			tower.upgrade_tower(3)
			PlayerStats.spend_money(level_3_cost)
			TowerLevelUpButton.disabled = true
	else:
		push_error("Please set the tower for the tower leveling system.")
	update_stats_display()
	_on_money_changed(PlayerStats.get_money())
