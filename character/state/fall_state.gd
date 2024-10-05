extends BaseState

@export var foot1: RigidBody3D
@export var foot2: RigidBody3D

@export var physics_target: RigidBody3D
@export var camera_target: SpringArm3D
@export var animation_tree: AnimationTree

var time_since_foot_touch := 0.0
var is_active

func _process(delta: float) -> void:
	if foot1.get_contact_count() == 0 and foot2.get_contact_count() == 0:
		time_since_foot_touch += delta
	else:
		time_since_foot_touch = 0.0
	
	if time_since_foot_touch > 0.4 and not is_active:
		transition.emit(self, "fall", {})

func update(delta):
	if foot1.get_contact_count() > 0:
		transition.emit(self, "fall_recover", {"surface": foot1.get_colliding_bodies()[0], "foot": foot1})
	elif foot2.get_contact_count() > 0:
		transition.emit(self, "fall_recover", {"surface": foot2.get_colliding_bodies()[0], "foot": foot2})

# REFACTOR TO USE COLLISION SIGNALS YO
func enter(args):
	is_active = true
	if foot1.get_contact_count() == 0 and foot2.get_contact_count() == 0:
		pass
		#animation_tree.set("parameters/Transition/transition_request", "fall")
	else:
		update(0.01)
	
func exit():
	is_active = false
	time_since_foot_touch = 0.0

func physics_update(delta):
	physics_target.apply_central_force(get_movement_vector() * 20)
	physics_target.apply_central_force(Vector3(0, 1, 0) * 40)


func get_movement_vector():
	var left = -1 if Input.is_action_pressed("left") else 1 if Input.is_action_pressed("right") else 0
	var forward = -1 if Input.is_action_pressed("backward") else 1 if Input.is_action_pressed("forward") else 0
	
	return Vector3(-left, 0, forward).normalized().rotated(Vector3.UP, camera_target.rotation.y)
	
func can_exit(next_state_name):
	return "fall_recover" == next_state_name
