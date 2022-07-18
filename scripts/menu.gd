extends Control


func _ready():
	pass

func _process(delta):
	$fundo.region_rect.position.y += 1.3


func _on_jogar_pressed():
	get_tree().change_scene("res://Node2D.tscn")


func _on_sair_pressed():
	$textinho.text = "eu falei pra descer, sem objeções"


func _on_ajuda_pressed():
	$textinho.text = 'WASD pra mexer, e ESPAÇO pra cavar na parede\n tmb tem umas luzinhas pra te ajudar'
