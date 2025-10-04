extends Node2D
## Deletes all children from the 'Towers' node.
func delete_bought_towers():
	for tower in get_tree().get_nodes_in_group("tower"):
		tower.queue_free()

## Deletes all children from the 'Temp' node.
func delete_temporary_towers():
	for tower in get_tree().get_nodes_in_group("temp"):
		tower.queue_free()
	
func get_ysorter():
	var towers_node = get_tree().get_nodes_in_group("ysorter")
	if towers_node.size() > 0:
		return towers_node[0]
	else:
		return null
		print("no ysortter")
