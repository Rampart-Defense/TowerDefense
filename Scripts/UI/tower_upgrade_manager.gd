extends Node2D

# This script should be attached to the root node of your main scene.
# It is now the central handler for all mouse clicks that are NOT handled by other nodes.
var current_upgraded_tower = null # A variable to store the currently selected tower.

func _unhandled_input(event: InputEvent) -> void:
	# Check for a left mouse button press
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:

		# Get the global mouse position in viewport space.
		var viewport_mouse_position = get_viewport().get_mouse_position()

		# Get the main camera node from the GlobalCamera autoload.
		if not is_instance_valid(GlobalCamera.camera):
			print("ERROR: GlobalCamera autoload or its camera property is not valid.")
			return
		var main_camera = GlobalCamera.camera

		# Convert the viewport mouse position to world space using the camera's transform.
		var world_mouse_position = main_camera.get_canvas_transform().affine_inverse() * viewport_mouse_position

		# Assume no tower was clicked at first.
		var tower_clicked = false

		# Get all towers in the scene.
		var towers = get_tree().get_nodes_in_group("tower")

		# Iterate through each tower and check if the mouse position is inside its bounding box.
		for tower in towers:
			#NoNo for moneyglitch #1
			if tower.get_parent().name == "Temp":
				tower.queue_free()
				break
			
			# Get the tower's bounding rectangle in global coordinates.
			var tower_rect = Rect2(tower.global_position - tower.get_node("clickshape").shape.size / 2, tower.get_node("clickshape").shape.size)

			# Check if the world mouse position is inside the tower's rectangle.
			if tower_rect.has_point(world_mouse_position):
				tower_clicked = true
				print("Tower was clicked: " + str(tower.name))

				# If a different tower was previously selected, hide its menu.
				if current_upgraded_tower != null and current_upgraded_tower != tower:
					# Disconnect the signal from the previous tower's menu
					if PlayerStats.money_changed.is_connected(current_upgraded_tower.tower_leveling_system._on_money_changed):
						PlayerStats.money_changed.disconnect(current_upgraded_tower.tower_leveling_system._on_money_changed)
						
					# Move the upgrade system back to its original parent and hide it.
					current_upgraded_tower.tower_leveling_system.reparent(current_upgraded_tower)
					current_upgraded_tower.tower_leveling_system.visible = false
					current_upgraded_tower.get_node("RangeArea").visible = false

				# Toggle visibility and reparent the clicked tower's menu.
				if tower.tower_leveling_system.get_parent() == GlobalUi:
					# If it's already in GlobalUI, move it back to the tower and hide it.
					# Disconnect the signal as the menu is now hidden.
					if PlayerStats.money_changed.is_connected(tower.tower_leveling_system._on_money_changed):
						PlayerStats.money_changed.disconnect(tower.tower_leveling_system._on_money_changed)
						
					tower.tower_leveling_system.reparent(tower)
					tower.tower_leveling_system.visible = false
					tower.get_node("RangeArea").visible = false
					current_upgraded_tower = null
				else:
					# Otherwise, move it to GlobalUI and show it.
					tower.tower_leveling_system.reparent(GlobalUi, true) # `true` keeps the global transform.
					tower.tower_leveling_system.position += get_position_changes(tower)
					tower.tower_leveling_system.visible = true
					tower.get_node("RangeArea").visible = true
					current_upgraded_tower = tower # Set the currently selected tower.
					
					# Connect the signal for the newly selected tower's menu.
					if not PlayerStats.money_changed.is_connected(tower.tower_leveling_system._on_money_changed):
						PlayerStats.money_changed.connect(tower.tower_leveling_system._on_money_changed)
						
					# Also call the update function to set the initial button states.
					tower.tower_leveling_system._on_money_changed(PlayerStats.get_money())


				# We found a tower, so we can stop checking.
				break

		# If no tower was clicked, hide all menus.
		if not tower_clicked:
			print("Blank space clicked. Hiding all tower menus.")
			if current_upgraded_tower != null:
				# Disconnect the signal from the menu before hiding it.
				if PlayerStats.money_changed.is_connected(current_upgraded_tower.tower_leveling_system._on_money_changed):
					PlayerStats.money_changed.disconnect(current_upgraded_tower.tower_leveling_system._on_money_changed)
					
				# Move the upgrade system back to its original parent and hide it.
				current_upgraded_tower.tower_leveling_system.reparent(current_upgraded_tower)
				current_upgraded_tower.tower_leveling_system.visible = false
				current_upgraded_tower.get_node("RangeArea").visible = false
				current_upgraded_tower = null


func get_position_changes(tower: Area2D) -> Vector2:
	var position_changes = Vector2.ZERO
	
	var leveling_system = tower.tower_leveling_system
	var tower_global_position = tower.global_position
	
	# Check and adjust X position
	if tower_global_position.x < 200 and not leveling_system.too_far_left:
		position_changes.x = 350
		position_changes.y = -200
		leveling_system.too_far_left = true
		# Reset other horizontal bools
		leveling_system.too_far_right = false
	elif tower_global_position.x > 900 and not leveling_system.too_far_right:
		position_changes.x = -350
		position_changes.y = -200
		leveling_system.too_far_right = true
		# Reset other horizontal bools
		leveling_system.too_far_left = false
		
	# Check and adjust Y position
	if tower_global_position.y < 50 and not leveling_system.too_far_up:
		position_changes.y = 50
		leveling_system.too_far_up = true
		# Reset other vertical bools
		leveling_system.too_far_down = false
	elif tower_global_position.y > 400 and not leveling_system.too_far_down:
		position_changes.y = -400
		leveling_system.too_far_down = true
		# Reset other vertical bools
		leveling_system.too_far_up = false
		
	return position_changes


func close_all_tower_upgrade_menus() -> void:
	# Get all towers in the scene.
	var towers = get_tree().get_nodes_in_group("tower")

	# Iterate through each tower.
	for tower in towers:
		# Check if the tower's upgrade system is currently visible.
		if is_instance_valid(tower.tower_leveling_system) and tower.tower_leveling_system.visible:
			# If the PlayerStats.money_changed signal is connected to the tower's menu, disconnect it to prevent errors and memory leaks.
			if PlayerStats.money_changed.is_connected(tower.tower_leveling_system._on_money_changed):
				PlayerStats.money_changed.disconnect(tower.tower_leveling_system._on_money_changed)
			
			# Reparent the upgrade menu back to its original tower node.
			tower.tower_leveling_system.reparent(tower)
			
			# Hide the upgrade menu.
			tower.tower_leveling_system.visible = false
			
			# Hide the tower's range indicator.
			# We check if the node exists to prevent potential errors.
			if is_instance_valid(tower.get_node_or_null("RangeArea")):
				tower.get_node("RangeArea").visible = false

	# After hiding all menus, reset the `current_upgraded_tower` variable to `null`.
	# This prevents the script from thinking a tower is still selected.
	if current_upgraded_tower != null:
		current_upgraded_tower = null
		print("All tower menus and ranges have been closed.")
