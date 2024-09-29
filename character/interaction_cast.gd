extends RayCast3D

@export var hand1: Node3D
@export var hand2: Node3D

var last_obj
var held_obj = null

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("interact") and held_obj != null:
		drop_obj(held_obj)
		return
	elif Input.is_action_just_pressed("interact") and last_obj != null:
		hold_obj(last_obj)
		return
	
	var hit = get_collider()
	deselect(last_obj)
	if hit != null and hit is Holdable:
		hit.hover_start()
		last_obj = hit

func _physics_process(delta: float) -> void:
	pass
	
func hold_obj(obj):
	held_obj = obj
	
	var j1 = JoltSliderJoint3D.new()
	hand1.get_parent().add_child(j1)
	j1.node_a = j1.get_path_to(hand1.get_parent())
	j1.node_b = j1.get_path_to(obj)
	j1.position = Vector3.ZERO
	
	j1.motor_enabled = true
	j1.motor_max_force = 100
	j1.motor_target_velocity = 10
	j1.enabled = true

func drop_obj(obj):
	held_obj = null
	



func deselect(obj):
	if obj:
		obj.hover_end()
