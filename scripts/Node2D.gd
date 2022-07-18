extends Node2D
export var leveling = 1

var tween = Tween.new()

func _ready():
	Global.label = $Camera2D/CanvasLayer/Control/Label
	Global.root = self
	Global.score = 0
	add_child(tween)
	tween.interpolate_property($Camera2D, "speed", 0, 
		$Camera2D.speed, 10, 
		Tween.TRANS_LINEAR, Tween.EASE_OUT)
	tween.start()


func leveling_up():
	$TileMap.wall_chance += leveling/1.3
	$miner.speed += leveling*2.5
	leveling += 0.1

func _physics_process(delta):
	var playery = $TileMap.world_to_map($miner.position-$miner.offset).y
	
	Global.score = playery if Global.score <= playery else Global.score
	Global.top_score = playery if Global.top_score < playery else Global.top_score
	Global.label.text = "score atual: %s \nmelhor score: %s \nmunição: %s" % [Global.score, Global.top_score, Global.ammo]
	
	if $Camera2D/morreste.overlaps_body($miner):
		tween.stop_all()
		$Camera2D.speed = 0
		$miner.speed = 0
		$Camera2D/CanvasLayer/Control/Morreste.show()
		if not $morreste.playing:
			$morreste.play()
		yield($morreste,"finished")
func buff():
	tween.interpolate_property($CanvasModulate, "color", Color(1,1,1,1), Color(0.1,0.1,0.1,1),10,Tween.TRANS_EXPO,Tween.EASE_IN_OUT)
	tween.start()
	$power.play()

func _on_Button_pressed():
	get_tree().reload_current_scene()
