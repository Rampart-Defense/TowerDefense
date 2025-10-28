extends Area2D
@export var maxHealth: int = 10
@export var payout: int = 5
@export var points: int = 5
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
	var actual_payout_for_tracking = payout if win != "win" else 0
	emit_signal("died", actual_payout_for_tracking)
	
	if win != "win":
		PlayerStats.add_points(points)
		PlayerStats.add_money(payout)
		
	var node_to_free = owner if owner else self
	if is_instance_valid(node_to_free):
		node_to_free.queue_free()
