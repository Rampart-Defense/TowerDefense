extends Node2D


# --- Base stats and things needed.
@export var projectile_scene: PackedScene
@export var base_fire_cooldown: float = 1.0 # sekuntia per laukaus
@export var base_damage: int = 10
@export var tower_range: Area2D = null

@export var base_range: int = 248
@export var tower_base: Sprite2D = null #kuva tower base
@export var turret: AnimatedSprite2D = null #Kuva turretista
@export var firing_point: Marker2D #Kannattaa olla turretin lapsi niin pysyy oikealla kohdalla.
@export var rotating: bool = false #Kääntyykö turret?
@export var fire_timer: Timer 


@onready var range_area: CollisionShape2D = tower_range.get_child(0)

# ---Enemy related ---
var enemies: Array = [] # kaikki havaitut viholliset
var current_target: Node2D = null



# --- Checking bools ---
var can_fire: bool = true
var placing_tower: = false

# --- TILEMAP AND PLACEMENT CHECK RELATED ---
var tilemap: TileMapLayer = null
var placement_radius := 62
var footprint_size: int = 32
const TowerPlacementCheck = preload("res://scripts/Towers/tower_placement_check.gd")

# --- LEVEL SYSTEM UPGRADES ---
var fire_cooldown_level: int = 0
var damage_level: int = 0
var range_level: int = 0



# --- ACTUAL LEVEL ---
var tower_level: int = 1

# --- Current Stats ---
var damage: int = base_damage
var fire_cooldown: float = base_fire_cooldown
var current_range: float = base_range


@onready var tower_leveling_system: Control = $TowerLevelingSystem
@onready var arrow_shoot = $arrowshoot

#Scale of the map
var map_scale = 0

#doubleshot fix
var suppress_next_shot: bool = false


func _ready() -> void:
	
	
	damage = base_damage
	current_range = base_range
	# Connect the `area_entered` signal to the `_on_area_2d_area_entered` function.
	tower_range.area_entered.connect(_on_area_2d_area_entered)
	
	# Connect the `area_exited` signal to the `_on_area_2d_area_exited` function.
	tower_range.area_exited.connect(_on_area_2d_area_exited)
	
	
	turret.animation_finished.connect(_on_turret_animation_finished)
	#make visuals appear as lvl1
	_apply_visuals_and_stats()
	
	fire_cooldown = base_fire_cooldown
	turret.play("Default")
	fire_timer.wait_time = fire_cooldown
	fire_timer.one_shot = true
	fire_timer.timeout.connect(_on_fire_timer_timeout)
	
	# Auto-find the tilemap from "map" group
	if tilemap == null:
		var maps = get_tree().get_nodes_in_group("map")
		if maps.size() > 0:
			map_scale = maps[0].global_scale
			tilemap = maps[0].get_node_or_null("Grass&path")
	else:
		print("No tilemap found in 'map' group!")

func _on_fire_timer_timeout() -> void:
	
	if not placing_tower:
		if fire_cooldown != fire_timer.wait_time:
			fire_timer.wait_time = fire_cooldown

		if current_target and is_instance_valid(current_target):
			if rotating:
				var to_enemy = current_target.global_position - global_position
				turret.rotation = to_enemy.angle() + deg_to_rad(90)
			if suppress_next_shot and enemies.is_empty():
		# cooldown expired while enemies was empty → do nothing if enemies are still empty
				suppress_next_shot = false
				return
			_fire()

	# Keep firing if enemies remain
	if not enemies.is_empty():
		fire_timer.start()


func _fire() -> void:
	fire_projectile(current_target.global_position + current_target.get_parent().velocity * 0.1)

			# ammu
			fire_projectile(current_target.global_position + current_target.get_parent().velocity * 0.1)
			arrow_shoot.play()

func _select_new_target() -> void:
	if enemies.size() > 0:
		current_target = enemies[0] # vihollinen ensimmäinen listasta(alueelle tulo järjestyksessä)
	else:
		current_target = null


func fire_projectile(target_pos: Vector2) -> void:
	var offsets: Array = []

	match tower_level:
		1:
			offsets = [Vector2(0, 0)]  # single shot
			turret.play("Fire")
		2:
			offsets = [Vector2(-5, 0), Vector2(5, 0)]  # two shots
			turret.play("Fire2")
		3:
			offsets = [Vector2(-10, 0), Vector2(0, 0), Vector2(10, 0)]  # three shots
			turret.play("Fire3")

	# Spawn all projectiles with the given offsets. also shoot towards the offset
	for offset in offsets:
		var projectile = projectile_scene.instantiate()
		projectile.global_position = firing_point.global_position / map_scale + offset
		projectile.direction = (target_pos / map_scale - projectile.global_position + offset ).normalized()
		projectile.get_node("DamageSource").damage = damage
		get_tree().current_scene.call_deferred("add_child", projectile)
	

func upgrade_tower(stat: String, value ):
	match stat:
		"fire_rate":
			fire_cooldown_level += 1
			fire_cooldown -= value
		"damage":
			damage_level += 1
			damage += value
		"range":
			range_level += 1
			current_range += value
	_recalculate_level()
	
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
		1:
			tower_base.frame = 0
			turret.frame = 0
			turret.position = Vector2(0,-12)
		2:
			tower_base.frame = 1
			turret.frame = 1
			turret.position = Vector2(0, -20)
		3:
			tower_base.frame = 2
			turret.frame = 2
			turret.position = Vector2(0, -30)
	# Applying stats and visuals
	range_area.shape.radius = current_range
	get_node("RangeArea").size = Vector2(current_range*2, current_range*2)
	get_node("RangeArea").position = Vector2(-current_range, -current_range)
	_on_turret_animation_finished()
	print("Damage level: " + str(damage_level))
	print("Speed level: " + str(fire_cooldown_level))
	print("Ra(n)ge level: " + str(range_level))

func can_place() -> bool:
	return TowerPlacementCheck.can_place(self, footprint_size, placement_radius)
	
func _on_area_2d_area_entered(area: Area2D) -> void:
	
	if area.is_in_group("enemy"):
		
		enemies.append(area)
		_select_new_target()
		
		if fire_timer.is_stopped():
			_fire()
			fire_timer.start()
		


func _on_area_2d_area_exited(area: Area2D) -> void:
	
	if area.is_in_group("enemy"):
		enemies.erase(area)
		if area == current_target:
			_select_new_target()
		if enemies.is_empty():
			suppress_next_shot = true

func _on_turret_animation_finished() -> void:
	if tower_level == 1:
		turret.play("Default")
	if tower_level == 2:
		turret.play("Default2")
	if tower_level == 3:
		turret.play("Default3")

