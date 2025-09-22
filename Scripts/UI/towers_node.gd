extends Node2D
## Deletes all children from the 'Towers' node.
func delete_bought_towers():
	var towers_container = get_node("Towers")
	if towers_container:
		for child in towers_container.get_children():
			child.queue_free()

## Deletes all children from the 'Temp' node.
func delete_temporary_towers():
	var temp_container = get_node("Temp")
	if temp_container:
		for child in temp_container.get_children():
			child.queue_free()
