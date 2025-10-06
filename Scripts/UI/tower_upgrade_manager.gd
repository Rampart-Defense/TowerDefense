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
			if tower.is_in_group("temp"):
				tower.queue_free()
				break
			
			# Get the tower's bounding rectangle in global coordinates.
			var tower_rect = Rect2(tower.global_position - tower.get_node("clickshape").shape.size / 2, tower.get_node("clickshape").shape.size)

			# Check if the world mouse position is inside the tower's rectangle.
			if tower_rect.has_point(world_mouse_position):
				tower_clicked = true
				print("Tower was clicked: " + str(tower.name))
				var side_panel = GlobalUi.get_node("SidePanel")

				# --- CASE 1: Clicked the same tower again (toggle off)
				if current_upgraded_tower == tower:
					print("Same tower clicked again — closing upgrade menu.")
					side_panel.show_shop()

					# Disconnect and hide
					if PlayerStats.money_changed.is_connected(tower.tower_leveling_system._on_money_changed):
						PlayerStats.money_changed.disconnect(tower.tower_leveling_system._on_money_changed)

					tower.tower_leveling_system.reparent(tower)
					tower.tower_leveling_system.visible = false
					tower.get_node("RangeArea").visible = false
					current_upgraded_tower = null
					break

				# --- CASE 2: Clicked a different tower
				if current_upgraded_tower != null and current_upgraded_tower != tower:
					print("Switching from another tower to this one.")
					# Disconnect old tower menu
					if PlayerStats.money_changed.is_connected(current_upgraded_tower.tower_leveling_system._on_money_changed):
						PlayerStats.money_changed.disconnect(current_upgraded_tower.tower_leveling_system._on_money_changed)

					current_upgraded_tower.tower_leveling_system.reparent(current_upgraded_tower)
					current_upgraded_tower.tower_leveling_system.visible = false
					current_upgraded_tower.get_node("RangeArea").visible = false

				# --- CASE 3: Show this tower’s upgrade menu
				side_panel.hide_shop()
				if side_panel.is_hidden:
					side_panel.show_side_panel()
				var anchor = side_panel.get_node("UpgradeAnchor")
				tower.tower_leveling_system.reparent(anchor, false)
				tower.tower_leveling_system.position = Vector2(135, 50)  # move it here since controls are mysterious..
				tower.tower_leveling_system.visible = true
				tower.get_node("RangeArea").visible = true
				current_upgraded_tower = tower

				# Connect the money signal
				if not PlayerStats.money_changed.is_connected(tower.tower_leveling_system._on_money_changed):
					PlayerStats.money_changed.connect(tower.tower_leveling_system._on_money_changed)

				# Initialize buttons and UI state
				tower.tower_leveling_system._on_money_changed(PlayerStats.get_money())

				break

		# If no tower was clicked, hide all menus.
		if not tower_clicked:
			var side_panel = GlobalUi.get_node("SidePanel") # Adjust path if needed
			side_panel.show_shop()
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
