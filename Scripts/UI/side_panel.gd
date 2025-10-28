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
