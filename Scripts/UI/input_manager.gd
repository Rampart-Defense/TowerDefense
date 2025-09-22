extends Node

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
