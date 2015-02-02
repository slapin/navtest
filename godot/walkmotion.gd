
extends Navigation

# member variables here, example:
# var a=2
# var b="textvar"
var nav
var npc
var path = []
var angles = []
var points = ["start", "point1", "point2"]
var pidx = 0
var pathidx = 0

func _ready():
	# Initalization here
	var i
	nav = get_node("nav")
	npc = get_node("npc")
	
	set_process(true)

func calc_path():
	var i
	var interpolated_path = []
	var m = get_closest_point(get_node(points[pidx]).get_translation())
	var cur = get_closest_point(npc.get_translation())
	path = Array(get_simple_path(cur, m, true))
	for i in range(0, path.size()):
		interpolated_path.append(path[i])
		if i < path.size() - 1:
			angles.append((path[i + 1] - path[i]).normalized())
			var m
			for m in range(0, 10):
				interpolated_path.append(path[i].linear_interpolate(path[i + 1], 0.1 * m))
				angles.append(Vector3(0.0, 0.0, 0.0))
	path = interpolated_path

func next_path():
	pidx += 1
	pathidx = 0
	if pidx >= points.size():
		pidx = 0
	calc_path()
func get_segment():
	var h = path[pathidx]
	var l = h - npc.get_translation()
	return l
func next_point():
	pathidx += 1
	if pathidx >= path.size():
		next_path()

func is_arrived(delta):
	var r = get_segment()
	r.y = 0
	return r.length() < delta

func _process(delta):
	if path.size() == 0:
		pidx = 0
		pathidx = 0
		calc_path()
	if is_arrived(delta):
		next_point()
	else:
		if not npc.is_processing():
			npc.goto(path[pathidx], angles[pathidx])

	
	

	

