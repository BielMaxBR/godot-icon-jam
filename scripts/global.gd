extends Node

var tilemap = TileMap
var label = Label
var root = Node2D
var score = 0
var top_score = 0

var ammo = 3
var timer = Timer.new()

var part = preload("res://particle.tscn")

func _ready():
	add_child(timer)
	timer.connect("timeout",self,"_timeout")

func _timeout():
	ammo = ammo+1 if ammo < 3 else 3

func use_ammo(v):
	ammo -= v
	timer.start(3)

func spread_particle(pos):
	var new_part = part.instance()
	new_part.position = pos
	root.add_child(new_part)
