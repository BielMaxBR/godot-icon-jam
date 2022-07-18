extends TileMap

export var generate_on_ready = true
export var  MAZE_SIZE = Vector2(15,8)
export var  MAZE_POS = Vector2(1, 1)
export var WALL_ID = 0
export var PATH_ID = 1
export var LIMIT_ID = 2
export var wall_chance = 1

const DIRECTIONS = [
	Vector2.UP * 2,
	Vector2.DOWN * 2,
	Vector2.RIGHT * 2,
	Vector2.LEFT * 2,
]
var current_cell = Vector2.ONE
var visited_cells = [current_cell]
var stack = []
var cells = []

var buffer_path = preload("res://buffer.tscn")

func _ready():
	Global.tilemap = self
	current_cell += MAZE_POS - Vector2.ONE
	if generate_on_ready:
		generate_maze()
		generate_maze()

### MAZE GENERATION ###

func generate_maze():
	#Clear the maze
	randomize()
	current_cell = MAZE_POS
	visited_cells = [current_cell]
	stack.clear()
	clear_map()
	var paths = $Gen.get_used_cells_by_id(PATH_ID)
	var walls = $Gen.get_used_cells_by_id(WALL_ID)
	var limits = $Gen.get_used_cells_by_id(LIMIT_ID)
	for wall in walls:
		$Gen.set_cellv(wall, -1)
	for path in paths:
		$Gen.set_cellv(path, -1)
	for limit in limits:
		$Gen.set_cellv(limit, -1)
	
	# Create walls
	for x in MAZE_SIZE.x:
		for y in MAZE_SIZE.y:
			$Gen.set_cell(x+MAZE_POS.x, y+MAZE_POS.y, WALL_ID)
#			$Path.set_cell(x+MAZE_POS.x, y+MAZE_POS.y, -1)
	# Create limits
	for x in MAZE_SIZE.x+2:
		$Gen.set_cell(x+MAZE_POS.x-1, MAZE_POS.y-1, LIMIT_ID)
		$Gen.set_cell(x+MAZE_POS.x-1, MAZE_POS.y-2, LIMIT_ID)
	for x in MAZE_SIZE.x+2:
		$Gen.set_cell(x+MAZE_POS.x-1, MAZE_SIZE.y + MAZE_POS.y, LIMIT_ID)
		$Gen.set_cell(x+MAZE_POS.x-1, MAZE_SIZE.y + MAZE_POS.y+1, LIMIT_ID)
	for y in MAZE_SIZE.y:
		$Gen.set_cell(MAZE_POS.x-1, MAZE_POS.y + y , LIMIT_ID)
		$Gen.set_cell(MAZE_POS.x-2, MAZE_POS.y + y , LIMIT_ID)
	for y in MAZE_SIZE.y:
		$Gen.set_cell(MAZE_SIZE.x + MAZE_POS.x, MAZE_POS.y + y , LIMIT_ID)
		$Gen.set_cell(MAZE_SIZE.x + MAZE_POS.x+1, MAZE_POS.y + y , LIMIT_ID)
	#create cells
	for x in (MAZE_SIZE.x+1)/2:
		for y in (MAZE_SIZE.y + 1)/2:
			$Gen.set_cell(MAZE_POS.x + 2 * x , MAZE_POS.y + 2 * y, PATH_ID)
	#get cells
	cells = $Gen.get_used_cells_by_id(PATH_ID)
	#generate maze
	while visited_cells.size() < cells.size():
		var neighbours = neighbours_have_not_been_visited(current_cell)
		if neighbours.size() > 0:
			var random_neighbour = neighbours[randi()%neighbours.size()]
			stack.push_front(current_cell)
			var wall = (random_neighbour - current_cell)/2 + current_cell
			$Gen.set_cell(int(wall.x), int(wall.y), PATH_ID)
			if randi()%100 < 2:
				create_buffer(wall)
			current_cell = random_neighbour
			visited_cells.append(current_cell)
		elif stack.size() > 0:
			current_cell = stack[0]
			stack.pop_front()
	
	for x in (MAZE_SIZE.x-1)/2:
		for y in (MAZE_SIZE.y-1)/2:
			var cell_id = PATH_ID if randi()%10 > wall_chance else WALL_ID
			$Gen.set_cell(x*2+1+MAZE_POS.x, y*2+1+MAZE_POS.y, cell_id)
	MAZE_POS.y += MAZE_SIZE.y
	set_to_visible_map()

func neighbours_have_not_been_visited(cell):
	var neighbours = []
	for dir in DIRECTIONS:
		if not visited_cells.has(cell + dir) and ($Gen.get_cell(int(cell.x + dir.x), int(cell.y + dir.y)) != LIMIT_ID):
			neighbours.append(cell + dir)
	return neighbours

func clear_map(): 
	for x in range(MAZE_SIZE.x):
		var _x = x+MAZE_POS.x
		for y in range(MAZE_SIZE.y):
			var _y = y+(MAZE_POS.y-MAZE_SIZE.y*3)
			set_cell(_x,_y,-1)
			$Path.set_cell(_x,_y,-1)


func set_to_visible_map():
	var paths = $Gen.get_used_cells_by_id(PATH_ID)
	var walls = $Gen.get_used_cells_by_id(WALL_ID)
	var limits = $Gen.get_used_cells_by_id(LIMIT_ID)
	for wall in walls:
		set_cellv(wall, WALL_ID)
	for path in paths:
		set_cellv(path, PATH_ID)
		$Path.set_cellv(path, PATH_ID)
	for limit in limits:
		if limit.x < MAZE_POS.x or limit.x > MAZE_SIZE.x:
			set_cellv(limit, LIMIT_ID)
			set_cell(limit.x,limit.y-MAZE_SIZE.y*4,-1)
	
func create_buffer(pos):
	var buffer = buffer_path.instance()
	buffer.position = $Gen.map_to_world(pos)
	get_parent().call_deferred("add_child",buffer)
