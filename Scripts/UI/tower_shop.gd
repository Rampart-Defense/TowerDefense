extends Control


func _ready() -> void:
	PlayerStats.money_changed.connect(_on_money_changed)
	_on_money_changed(PlayerStats.get_money())

	

func _on_money_changed(money):
	
	for panel in get_children():
		if panel is Panel:
			if panel.price <= money:
				panel.modulate = Color.WHITE
			else:
				panel.modulate = Color(0.5, 0.5, 0.5, 0.8)
	
