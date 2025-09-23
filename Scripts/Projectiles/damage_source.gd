extends Area2D
@export var damage: int = 1
@export var penetrating: bool = false
@export var single_target: bool = true
@export var on_hit: bool = false #true if the damage it self is on-hit
@export var offset:Vector2 = Vector2.ZERO
var on_hit_animation = null
var has_hit = false
func _ready() -> void:
	if not on_hit:
		on_hit_animation = get_parent().on_hit_animation

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemy"):
		if single_target:
			if not has_hit:
				has_hit = true
				area.take_damage(damage)
			else:
				return
		else:
			area.take_damage(damage)
		if on_hit_animation != null:
				var temp_on_hit = on_hit_animation.instantiate()
				temp_on_hit.global_position = global_position + offset
				get_tree().current_scene.call_deferred("add_child", temp_on_hit)
		if not penetrating:
			get_parent().queue_free()
