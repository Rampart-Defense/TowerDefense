extends Marker2D

func _ready():
	Waves.set_spawner_location(self)
	Waves.begin()
