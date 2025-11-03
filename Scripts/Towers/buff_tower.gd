extends Area2D

# NOTE: Renamed to clarify they are buff values, not attack stats.
@export var base_fire_cooldown: float = 0.05  # Flat Cooldown Reduction (seconds)
@export var base_damage: int = 10  # Flat Damage Increase(used just for display and TowerLevelingSystem) turned into percents

@export var tower_range: Area2D = null
# ... (omitted: visual/range/placement variables) ...
@export var base_range: int = 248
@export var tower_base: Sprite2D = null 
@export var turret: AnimatedSprite2D = null 


var placing_tower: bool = true

# --- TILEMAP AND PLACEMENT CHECK RELATED ---
var tilemap: TileMapLayer = null
var placement_radius: int= 62
var footprint_size: int = 32
const TowerPlacementCheck = preload("res://Scripts/Towers/tower_placement_check.gd")


# --- LEVEL SYSTEM UPGRADES ---
var fire_cooldown_level: int = 0
var damage_level: int = 0
var range_level: int = 0

#--Towers in range
var towers: Array = []

# --- ACTUAL LEVEL ---
var tower_level: int = 1

# --- Current Stats (Now the Buff Stats) ---
var damage: int  #(used just for display and TowerLevelingSystem) turned to percents to use buff
var fire_cooldown: float 
var current_range: float 
var damage_percent: float = 0.1


#these are for the TowerLevelingSystem
var damage_buff: int = 0
var cdr_buff: float = 0.0

@onready var range_area: CollisionShape2D = tower_range.get_child(0)
@onready var tower_leveling_system: Control = $TowerLevelingSystem

func _ready() -> void:
	if range_area.shape:
		# Duplicates the shape resource, making it unique for this tower.
		# Subsequent changes to range_area.shape.radius will ONLY affect this tower.
		range_area.shape = range_area.shape.duplicate()
		
		turret.play("Default")
		damage = base_damage
		fire_cooldown = base_fire_cooldown
		current_range = base_range
		_apply_visuals_and_stats()

#Placement check
func can_place() -> bool:
	return TowerPlacementCheck.can_place(self, footprint_size, placement_radius)


# U - Upgrade Tower (Modified to trigger incremental buff)
func upgrade_tower(stat: String, value ):

	
	# Applying stats
	match stat:
		"fire_rate":
			fire_cooldown_level += 1
			fire_cooldown += value
		"damage":
			damage_level += 1
			damage += value
			damage_percent = damage *0.01
		"range":
			range_level += 1
			current_range += value
			
	_recalculate_level()
	buff_towers()
	
	
func _recalculate_level():
	var total_upgrades = fire_cooldown_level + damage_level + range_level

	if total_upgrades >= 6:
		tower_level = 3
	elif total_upgrades >= 3:
		tower_level = 2
	else:
		tower_level = 1

	_apply_visuals_and_stats()

func _apply_visuals_and_stats():
	#Applying visuals
	match tower_level:
		1: turret.play("Default")
		2: turret.play("Default2")
		3: turret.play("Default3")
	match tower_level:
		1:
			tower_base.frame = 0
			turret.frame = 0
			turret.position = Vector2(0,-38)
		2:
			tower_base.frame = 1
			turret.frame = 1
			turret.position = Vector2(0, -54)
		3:
			tower_base.frame = 2
			turret.frame = 2
			turret.position = Vector2(0, -70)
	# Applying stats and visuals
	range_area.shape.radius = current_range
	get_node("RangeArea").size = Vector2(current_range*2, current_range*2)
	get_node("RangeArea").position = Vector2(-current_range, -current_range)


func buff_towers():
	for tower in towers:
		if is_instance_valid(tower):
			if (tower.damage * damage_percent) <= 0.15:
				tower.damage_buff = 0
			elif (tower.damage * damage_percent) < 1:
				tower.damage_buff = 1
			else:
				tower.damage_buff = int(tower.damage * damage_percent)
			tower.cdr_buff = tower.fire_cooldown * fire_cooldown


func remove_buffs():
	for tower in towers:
		if is_instance_valid(tower):
			tower.damage_buff = 0
			tower.cdr_buff = 0

func get_towers_in_range():
	# Get all overlapping areas that are towers
	if placing_tower:
		return
	var overlapping_areas = tower_range.get_overlapping_areas()
	for area in overlapping_areas:
		if area.is_in_group("tower") and not area.is_in_group("buffer_tower") and not area.placing_tower:
			if not towers.has(area):
				towers.append(area)
	buff_towers()




func _on_fire_timer_timeout() -> void:
	get_towers_in_range()
