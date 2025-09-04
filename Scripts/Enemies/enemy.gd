extends CharacterBody2D

@export var movement_speed = 100
var goal: Node2D = null


#Navigoinnin hoitaa NavigationAgent2D ja Tilesettiin asetettu navigointi.
@onready var navAgent:  NavigationAgent2D = $NavigationAgent2D 
@onready var animation: AnimatedSprite2D = $AnimatedSprite2D 
@onready var pathTimer: Timer = $PathUpdateTimer   

func _ready() -> void:
	pathTimer.start()
	pathTimer.one_shot = false
	pathTimer.timeout.connect(_on_path_update_timer_timeout)
	animation.play()
	goal = get_tree().get_current_scene().get_node("Goal")
	if goal == null:
		push_error("Enemy could not find a node named 'goal' in the current scene!")
		return
	navAgent.target_position = goal.position
	print("Enemy goal set to: ", goal.position)


func _physics_process(_delta: float) -> void:
		move_and_slide()

## 0.3s timer ja alle hyvä, pidempi aika aiheuttaa ongelmia.
func _on_path_update_timer_timeout() -> void:
	if goal == null:
		return
	if not navAgent.is_navigation_finished():
		var next_pos = navAgent.get_next_path_position()
		if next_pos == null:
			push_error("NavigationAgent2D returned null for next path position!")
			velocity = Vector2.ZERO
			return
		var nav_direction = to_local(next_pos).normalized()
		velocity = nav_direction * movement_speed
		move_and_slide()
	else:
		velocity = Vector2.ZERO
		print("Enemy has reached the goal! Deleting enemy...")
		self.queue_free()
