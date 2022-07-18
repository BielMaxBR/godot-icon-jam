extends Camera2D

onready var tilemap = $"../TileMap"
export(float) var speed = 8

onready var telay = tilemap.MAZE_SIZE.y * tilemap.cell_size.y
onready var iii = $"../iii"
onready var ooo = $ooo
func _ready():
	pass

func _process(delta):
	position.y += speed
	iii.global_position.y = (tilemap.MAZE_POS.y * tilemap.cell_size.y) - telay
	if ooo.overlaps_area(iii):
		tilemap.generate_maze()
		ooo.monitoring = false
		get_parent().leveling_up()
		yield(get_tree().create_timer(1), "timeout")
		ooo.monitoring = true
