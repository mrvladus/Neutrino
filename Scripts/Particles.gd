extends Particles2D

func _ready():
	emitting = true

func _physics_process(_delta):
	if !emitting:
		queue_free()
