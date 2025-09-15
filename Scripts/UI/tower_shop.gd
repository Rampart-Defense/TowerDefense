extends Control

@onready var shop_panel: Panel = $Panel 
@onready var show_shop_button: TextureButton = $ShowShopButton
@onready var towershop_panel_container: FlowContainer = $Panel/FlowContainer

func _ready() -> void:
	PlayerStats.money_changed.connect(_on_money_changed)
	_on_money_changed(PlayerStats.get_money())
	#shop_panel.visible = false
	

func _on_money_changed(money):
	
	for panel in towershop_panel_container.get_children():
		if panel is Panel:
			if panel.price <= money:
				panel.modulate = Color.WHITE
			else:
				panel.modulate = Color(0.5, 0.5, 0.5, 0.8)
	
func hide_shop():
	shop_panel.visible = false
	show_shop_button.visible = false

func show_shop():
	show_shop_button.visible = true

func _on_show_shop_button_pressed() -> void:
	shop_panel.visible = !shop_panel.visible
