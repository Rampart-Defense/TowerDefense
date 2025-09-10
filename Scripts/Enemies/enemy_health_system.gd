extends Area2D
@export var maxHealth: int = 10
var currentHealth: int
var goal_marker: Marker2D = null
signal died

func _ready() -> void:
	currentHealth = maxHealth

func take_damage(amount: int) -> void:
	currentHealth -= amount
	if currentHealth <= 0:
		die()

func die() -> void:
	if owner:
		emit_signal("died")
		owner.queue_free()
	else:
		emit_signal("died")
		queue_free()

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("damageSource"):
		take_damage(area.damage)
		##delete projectile
		if area.owner:
			area.owner.queue_free()
		else:
			area.queue_free()
