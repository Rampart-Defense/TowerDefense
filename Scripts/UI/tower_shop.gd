extends Control
var container: FlowContainer

func _ready() -> void:
	PlayerStats.money_changed.connect(_on_money_changed)
	container = $ScrollContainer/FlowContainer
	_on_money_changed(PlayerStats.get_money())

	

func _on_money_changed(money):
	if container == null:
		return
	for panel in container.get_children():
		if panel is Panel:
			if panel.price <= money:
				panel.modulate = Color.WHITE
			else:
				panel.modulate = Color(0.5, 0.5, 0.5, 0.8)
	
