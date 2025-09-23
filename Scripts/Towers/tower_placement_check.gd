extends Object

# Check if tower can be placed at its position
static func can_place(tower: Node2D, footprint_size: int, placement_radius: float) -> bool:
	# 1) Outside map check
	if is_outside_map(tower, footprint_size, footprint_size):
		return false
	
	# 2) Road & NoBuild check
	if is_on_blocked_area(tower, footprint_size, footprint_size):
		return false

	# 3) Tower overlap check
	var towers_node = TowersNode.get_node("Towers")
	if towers_node:
		for other in towers_node.get_children():
			if other == tower:
				continue
			if tower.global_position.distance_to(other.global_position) < placement_radius:
				return false
	return true

# Check if tower footprint overlaps with blocked areas (Path, NoBuild)
static func is_on_blocked_area(tower: Node2D, base_w := 32.0, base_h := 32.0) -> bool:
	var maps = tower.get_tree().get_nodes_in_group("map")
	if maps.size() == 0:
		return false

	var blocked_layers = [
		maps[0].get_node_or_null("Path"),
		maps[0].get_node_or_null("NoBuild")
	]

	var base_offset = Vector2(0, base_h / 2.0)
	var offsets = [
		Vector2(-base_w/2.0, -base_h/2.0),
		Vector2(base_w/2.0, -base_h/2.0),
		Vector2(-base_w/2.0, base_h/2.0),
		Vector2(base_w/2.0, base_h/2.0)
	]

	for layer in blocked_layers:
		if layer == null:
			continue
		for offset in offsets:
			var check_pos = tower.global_position + offset + base_offset
			var local_pos = layer.to_local(check_pos)
			var cell = layer.local_to_map(local_pos)

			if layer.get_cell_source_id(cell) != -1:
				return true
	return false

# Check if tower footprint is outside background layer
static func is_outside_map(tower: Node2D, base_w := 32, base_h := 32) -> bool:
	var maps = tower.get_tree().get_nodes_in_group("map")
	if maps.size() == 0:
		return true

	var background_layer: TileMapLayer = maps[0].get_node_or_null("Background")
	if background_layer == null:
		return true

	var base_offset = Vector2(0, base_h / 2.0)
	var offsets = [
		Vector2(-base_w/2.0, -base_h/2.0),
		Vector2(base_w/2.0, -base_h/2.0),
		Vector2(-base_w/2.0, base_h/2.0),
		Vector2(base_w/2.0, base_h/2.0)
	]

	var used_rect = background_layer.get_used_rect()

	for offset in offsets:
		var check_pos = tower.global_position + offset + base_offset
		var local_pos = background_layer.to_local(check_pos)
		var cell = background_layer.local_to_map(local_pos)

		if not used_rect.has_point(cell):
			return true

	return false
