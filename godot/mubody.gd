
extends RigidBody

# member variables here, example:
# var a=2
# var b="textvar"

var dest_point
var move = false
var dest_angle
func _ready():
	# Initalization here
	set_mode(MODE_CHARACTER)
	set_mass(40)
	set_process(false)

func goto(p, a):
	dest_point = p
	dest_angle = a
	print("goto: ", p, " ", a)
	set_process(true)

func check_angle(r, delta):
	var rv = get_rotation()
	var rd = Vector3(0.0, r.y, 0.0).normalized()
	rv = Vector3(0.0, rv.y, 0.0).normalized()
	print("rot: ", rd, " ", rv, "dot:", rd.dot(rv))
	if rd.dot(rv) > -delta and r.dot(rv) < delta:
		return true
	else:
		return false

func check_destination(d, delta):
	var pd = Vector3(d.x, 0.0, d.z)
	var v = get_linear_velocity()
	v.y = 0
	var t = get_translation()
	t.y = 0.0
	if (pd - t + v * delta).length() < delta * 4.0:
		return true
	else:
		return false

func calc_angular_velocity(d, delta):
	var h = get_rotation()
	h.x = 0
	h.z = 0
	d.x = 0
	d.z = 0
	var av = (d.normalized() - h) * 0.5
	print(av, d)
	return av

func _process(delta):
	var h = dest_point - get_translation()
	var v = get_linear_velocity()
	var t = get_transform()
	var th = t.looking_at(dest_point, Vector3(0.0, 1.0, 0.0))
	var q = Quat(t.basis)
	var qh = Quat(th.basis)
	var qr = q.slerp(qh, 0.5)
	var vv = v
	v.z = 0
	var imp
	var pv = Vector3(h.x, 0.0, h.z)
	var rv = get_rotation()
	rv.x = 0
	rv.z = 0
	rv = rv.normalized()
	if check_destination(dest_point, delta):
		set_linear_velocity(Vector3(0.0, 0.0, 0.0))
	if check_angle(dest_angle, delta):
		set_angular_velocity(Vector3(0.0, 0.0, 0.0))
	if check_destination(dest_point, delta) and check_angle(h.normalized(), delta):
		set_process(false)
	elif v.length() < 3.7 and vv.y < 3.9 and vv.y > -3.9:
		if h.x >= 0 and h.z >= 0:
			imp = (h * delta) * get_mass() * 15
		else:
			imp = (h * delta) * get_mass() * 10
		if (vv.y < 0.1 and vv.y > -0.1) or true:
			imp += Vector3(0.0, 10.0, 0.0) * delta * get_mass()
		apply_impulse(Vector3(0.0, 0.0, 0.0), imp)
		set_angular_velocity(calc_angular_velocity(dest_angle, delta))

	
