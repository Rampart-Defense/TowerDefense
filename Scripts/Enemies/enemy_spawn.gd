extends Marker2D

func _ready():
	EnemySpawner.set_spawner_location(self)
	EnemySpawner.start_waves()
