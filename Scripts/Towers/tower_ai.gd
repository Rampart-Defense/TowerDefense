extends Node2D



@export var projectile_scene: PackedScene
@export var firing_cooldown: float = 1.0 # sekuntia per laukaus
@export var turret: AnimatedSprite2D = null #Kuva turretista
@export var firing_point: Marker2D #Kannattaa olla turretin lapsi niin pysyy oikealla kohdalla.
@export var rotating: bool = false #Kääntyykö turret?
@export var fire_timer: Timer 

var enemies: Array = [] # kaikki havaitut viholliset
var current_target: Node2D = null
var can_fire: bool = true

func _ready() -> void:
	turret.play("Default")
	fire_timer.wait_time = firing_cooldown
	fire_timer.one_shot = false
	fire_timer.start()
	fire_timer.timeout.connect(_on_fire_timer_timeout)

func _on_fire_timer_timeout() -> void:
	if current_target and is_instance_valid(current_target):
		# käännä tykki kohti vihollista jos pitää (rotating turret towards enemy)
		if rotating:
			var to_enemy = current_target.global_position - global_position
			turret.rotation = to_enemy.angle() + deg_to_rad(90)

		# ammu
		fire_projectile(current_target.global_position)


func _select_new_target() -> void:
	if enemies.size() > 0:
		current_target = enemies[0] # vihollinen ensimmäinen listasta(alueelle tulo järjestyksessä)
	else:
		current_target = null


func fire_projectile(target_pos: Vector2) -> void:
	var projectile = projectile_scene.instantiate()
	projectile.global_position = firing_point.global_position
	projectile.direction = (target_pos - firing_point.global_position).normalized()
	
	# esim. animaatio tähän
	turret.play("Fire")
	get_tree().current_scene.add_child(projectile)
	print("pam!")
	


func _on_area_2d_area_entered(area: Area2D) -> void:
	
	if area.is_in_group("Enemy"):
		print("iseeu")
		enemies.append(area)
		
		_select_new_target()


func _on_area_2d_area_exited(area: Area2D) -> void:
	
	if area.is_in_group("Enemy"):
		print("byebye")
		enemies.erase(area)
		if area == current_target:
			_select_new_target()


func _on_turret_animation_finished() -> void:
	print("pysähdy!!!!!!")
	turret.play("Default")
