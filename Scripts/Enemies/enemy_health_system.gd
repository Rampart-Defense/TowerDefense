extends Area2D
@export var maxHealth: int = 10
var currentHealth: int



func _ready() -> void:
	currentHealth = maxHealth

func take_damage(amount: int) -> void:
	currentHealth -= amount
	print("Enemy took ", amount, " damage. Health: ", currentHealth)
	if currentHealth <= 0:
		die()

func die() -> void:
	if owner:
		owner.queue_free()
	else:
		queue_free()



func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("damageSource"):
		take_damage(area.damage)
		##delete projectile
		if area.owner:
			area.owner.queue_free()
		else:
			area.queue_free()
