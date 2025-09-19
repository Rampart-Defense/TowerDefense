extends Node2D



@export var projectile_scene: PackedScene
@export var firing_cooldown: float = 1.0 # sekuntia per laukaus
@export var turret: AnimatedSprite2D = null #Kuva turretista
@export var firing_point: Marker2D #Kannattaa olla turretin lapsi niin pysyy oikealla kohdalla.
@export var rotating: bool = false #Kääntyykö turret?
@export var fire_timer: Timer 
@export var footprint_size: int = 32 # width x height in tiles

var enemies: Array = [] # kaikki havaitut viholliset
var current_target: Node2D = null
var can_fire: bool = true
var placing_tower = false

# --- TILEMAP FOR PLACEMENT CHECK ---
var tilemap: TileMapLayer = null
var placement_radius := 40


func _ready() -> void:
	turret.play("Default")
	fire_timer.wait_time = firing_cooldown
	fire_timer.one_shot = false
	fire_timer.start()
	fire_timer.timeout.connect(_on_fire_timer_timeout)
	
	# Auto-find the tilemap from "map" group
	if tilemap == null:
		var maps = get_tree().get_nodes_in_group("map")
		if maps.size() > 0:
			tilemap = maps[0].get_node_or_null("Grass&path")
	else:
		print("No tilemap found in 'map' group!")

func _on_fire_timer_timeout() -> void:
	if not placing_tower:
		if current_target and is_instance_valid(current_target):
			# käännä tykki kohti vihollista jos pitää (rotating turret towards enemy)
			if rotating:
				var to_enemy = current_target.global_position - global_position
				turret.rotation = to_enemy.angle() + deg_to_rad(90)

			# ammu
			fire_projectile(current_target.global_position)


func _select_new_target() -> void:
	if enemies.size() > 0:
		current_target = enemies[0] # vihollinen ensimmäinen listasta(alueelle tulo järjestyksessä)
	else:
		current_target = null


func fire_projectile(target_pos: Vector2) -> void:
	var projectile = projectile_scene.instantiate()
	projectile.global_position = firing_point.global_position
	projectile.direction = (target_pos - firing_point.global_position).normalized()
	
	# esim. animaatio tähän
	turret.play("Fire")
	get_tree().current_scene.add_child(projectile)
	

func can_place() -> bool:
	# 1) Outside map check
	if is_outside_map(footprint_size, footprint_size):
		return false
	
	# 2) Road & NoBuild check
	if is_on_blocked_area(footprint_size, footprint_size): # footprint size 32 for our basic towers
		return false

	# 3) Tower overlap check
	var towers_node = get_tree().get_current_scene().get_node_or_null("Towers")
	if towers_node:
		for tower in towers_node.get_children():
			if tower == self:
				continue
			if global_position.distance_to(tower.global_position) < placement_radius:
				return false

	return true


func is_on_blocked_area(base_w := 32.0, base_h := 32.0) -> bool:
	var maps = get_tree().get_nodes_in_group("map")
	if maps.size() == 0:
		return false

	# Go inside Map3 -> TilemapLayers
	var layers_node = maps[0].get_node_or_null("TileMapLayers")
	if layers_node == null:
		print("No TileMapLayers node found! Make sure to type it as TileMapLayers (uppercase T, M, and L)")
		return false

	# Check both Path and NoBuild
	var blocked_layers = [
		layers_node.get_node_or_null("Path"),
		layers_node.get_node_or_null("NoBuild")
	]

	# shift the footprint *down* so it only covers the base area
	var base_offset = Vector2(0, base_h / 2)

	# Sample the 4 corners of the footprint box
	var offsets = [
		Vector2(-base_w/2, -base_h/2),
		Vector2(base_w/2, -base_h/2),
		Vector2(-base_w/2, base_h/2),
		Vector2(base_w/2, base_h/2)
	]

	for layer in blocked_layers:
		if layer == null:
			continue
		for offset in offsets:
			var check_pos = global_position + offset + base_offset
			var local_pos = layer.to_local(check_pos)
			var cell = layer.local_to_map(local_pos)

			# If blocked layer has a tile here → placement denied
			if layer.get_cell_source_id(cell) != -1:
				return true

	return false
	
	
func is_outside_map(base_w := 32, base_h := 32) -> bool:
	var maps = get_tree().get_nodes_in_group("map")
	if maps.size() == 0:
		return true

	var layers_node = maps[0].get_node_or_null("TileMapLayers")
	if layers_node == null:
		return true

	
	var grass_layer: TileMapLayer = layers_node.get_node_or_null("Background")
	if grass_layer == null:
		return true

	var base_offset = Vector2(0, base_h / 2)
	var offsets = [
		Vector2(-base_w/2, -base_h/2),
		Vector2(base_w/2, -base_h/2),
		Vector2(-base_w/2, base_h/2),
		Vector2(base_w/2, base_h/2)
	]

	# Get the used rectangle of the grass layer
	var used_rect = grass_layer.get_used_rect() # Rect2(x, y, width, height)

	for offset in offsets:
		var check_pos = global_position + offset + base_offset
		var local_pos = grass_layer.to_local(check_pos)
		var cell = grass_layer.local_to_map(local_pos)

		if not used_rect.has_point(cell):
			return true # outside buildable area

	return false

func _on_area_2d_area_entered(area: Area2D) -> void:
	
	if area.is_in_group("Enemy"):
		enemies.append(area)
		
		_select_new_target()


func _on_area_2d_area_exited(area: Area2D) -> void:
	
	if area.is_in_group("Enemy"):
		enemies.erase(area)
		if area == current_target:
			_select_new_target()


func _on_turret_animation_finished() -> void:
	turret.play("Default")
