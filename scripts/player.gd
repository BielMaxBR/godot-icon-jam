extends KinematicBody2D

export(NodePath) var lantern
export(NodePath) var lampiao
export(float) var speed = 10
onready var ray = $RayCast2D
onready var tween = $Tween

var tile_size = 32
var offset = Vector2(16,16)

var inputs = {"right": Vector2.RIGHT,
			"left": Vector2.LEFT,
			"up": Vector2.UP,
			"down": Vector2.DOWN}

var direction = "right"
var is_free = false

func _ready():
	$things/Lantern.texture.viewport_path = lantern
	$things/Lampiao.texture.viewport_path = lampiao
	position = position.snapped(Vector2.ONE * tile_size)
	position += Vector2.ONE * tile_size/2 + offset

func _process(delta):
	for dir in inputs.keys():
		if Input.is_action_pressed(dir):
			direction = dir
			move(direction)
	if Input.is_action_just_pressed("dig"):
		dig(direction)

func move(dir):
	if tween.is_active():
		return
	ray.cast_to = inputs[dir] * tile_size
	ray.force_raycast_update()
	if !ray.is_colliding():
		move_tween(dir)

func dig(dir):
	if tween.is_active():
		return
	var pos = Global.tilemap.world_to_map(position+offset) + inputs[dir]

	if Global.tilemap.get_cellv(pos) == Global.tilemap.WALL_ID:
		if Global.ammo > 0:
			Global.tilemap.set_cellv(pos, Global.tilemap.PATH_ID)
			Global.tilemap.get_node("Path").set_cellv(pos, Global.tilemap.PATH_ID)
			Global.use_ammo(1)
			Global.spread_particle(position + inputs[dir] * tile_size)
			$cavaste.play()
func move_tween(dir):
	if speed == 0: return
	tween.interpolate_property(self, "position",
		position, position + inputs[dir] * tile_size,
		1.0/speed, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	tween.start()
	$things.rotation = inputs[direction].angle()
