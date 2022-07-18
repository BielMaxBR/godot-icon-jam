extends CPUParticles2D


func _ready():
	$Timer.wait_time = lifetime
	$Timer.start()

func _on_Timer_timeout():
	queue_free()
