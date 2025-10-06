extends Control
@onready var towershop= $TowerShop

@onready var panel = $Panel
var is_hidden = false
func hide_shop():
	towershop.hide()

func show_shop():
	towershop.show()
	

	
func hide_all():
	panel.hide()
	towershop.hide()

func show_all():
	panel.show()
	towershop.show()

func hide_side_panel():
	is_hidden = true
	GlobalCamera.change_zoom_for_menu()
	GlobalUi.get_node("SidePanelButton").position = Vector2(1123,267)
	
	self.visible = false

func show_side_panel():
	is_hidden = false
	GlobalCamera.change_zoom_for_map()
	GlobalUi.get_node("SidePanelButton").position = Vector2(835,267)
	
	self.visible = true




func _on_side_panel_button_button_down() -> void:
	if is_hidden:
		show_side_panel()
	else:
		hide_side_panel()
