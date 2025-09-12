extends Panel
@onready var tower = preload("res://Scenes/Towers/archery_tower.tscn")
var price := 200
var preview_tower: Node2D = null
func _on_gui_input(event: InputEvent) -> void:
	_handle_shopkeeping(event)
	

func _handle_shopkeeping(event):
	
	if event is InputEventMouseButton and event.button_mask == 1: #1 = hiiren vasen näppäin pohjassa
		if PlayerStats.get_money() >= price and preview_tower == null:
			preview_tower = tower.instantiate()
			add_child(preview_tower)
			preview_tower.modulate = Color(1,1,1,0.7) # semi-transparent while dragging
			preview_tower.get_node("RangeArea").visible = true
	if event is InputEventMouseMotion and event.button_mask == 1 and  PlayerStats.get_money() >= price:
	
		if preview_tower:
			preview_tower.global_position = get_global_mouse_position()

			if preview_tower.can_place():
				# valid spot → white-ish
				preview_tower.modulate = Color(1, 1, 1, 0.7)
				print("this is a good spot maybe...")
			else:
				# invalid spot → red tint
				preview_tower.modulate = Color(1, 0.3, 0.3, 0.7)
				print("not there")
	if event is InputEventMouseButton and event.button_mask == 0:
		if preview_tower:
			if preview_tower.can_place():
			# Finalize placement
				var tower_parent = get_tree().get_current_scene().get_node_or_null("Towers")
				if tower_parent:
					# Save current global position
					preview_tower.get_node("RangeArea").visible = false
					var final_pos = preview_tower.global_position
					preview_tower.modulate = Color(1,1,1,1) # full color
					preview_tower.get_parent().remove_child(preview_tower)
					tower_parent.add_child(preview_tower)
					preview_tower.global_position = final_pos
					PlayerStats.spend_money(price)
					preview_tower = null
					print("Tower placed!")
				else:
					print('No "Towers" node found')
			else:
				# Invalid placement → cancel
				preview_tower.queue_free()
				preview_tower = null
				print("Cannot place turret on road!")
		print("clickup")
	
