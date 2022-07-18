extends Area2D


func _ready():
	pass


func _on_buffer_body_entered(body):
	if body.name == "miner":
		get_parent().buff()
		queue_free()
