extends Area2D
@export var maxHealth: int = 10
@export var payout: int = 5
var currentHealth: int
var goal_marker: Marker2D = null
var has_died: bool = false
signal died
var stunned = false
func _ready() -> void:
	currentHealth = maxHealth


func take_damage(amount: int) -> void:
	currentHealth -= amount
	if currentHealth <= 0 and not has_died:
		has_died = true
		die("no")
	var enemy = get_parent()
	enemy.hurt()

func stun(duration: float) -> void:
	var enemy = get_parent()
	if not enemy: 
		return  # parent is gone
	stunned = true
	enemy.stun_enemy() #TODO create function on enemy that plays stun animation and toggles true
	await get_tree().create_timer(duration).timeout
	if is_instance_valid(enemy):
		stunned = false
		enemy.stunned = stunned

func die(win: String) -> void:
	var enemy = get_parent()

	if not is_instance_valid(enemy) or enemy.is_dead:
		return

	var animation_played = false
	if is_instance_valid(enemy) and enemy.has_method("get_velocity") and win != "win":
		var velocity = enemy.get_velocity()
		enemy.is_dead = true
		var animated_sprite = enemy.animation
		var death_animation_name = "death_down"
			
		if velocity.length_squared() > 0:
			if abs(velocity.x) > abs(velocity.y):
				death_animation_name = "death_right" if velocity.x > 0 else "death_left"
			else:
				death_animation_name = "death_down" if velocity.y > 0 else "death_up"
			
		if animated_sprite and animated_sprite.sprite_frames.has_animation(death_animation_name):
			animated_sprite.play(death_animation_name)
			animation_played = true

	if animation_played and is_instance_valid(enemy):
		await enemy.animation.animation_finished
			
	var actual_payout_for_tracking = payout if win != "win" else 0
	emit_signal("died", actual_payout_for_tracking)
	
	if win != "win":
		PlayerStats.add_money(payout)
		
	var node_to_free = owner if owner else self
	if is_instance_valid(node_to_free):
		node_to_free.queue_free()
