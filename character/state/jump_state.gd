extends BaseState

@export var animation_tree: AnimationTree
@export var animation_player: AnimationPlayer
@export var physics_target: RigidBody3D

@export var foot1: RigidBody3D
@export var foot2: RigidBody3D

var is_active := false
var duration := 0.0

var jump_stage = 0

func _ready():
	animation_tree.animation_finished.connect(_on_animation_end)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("jump"):
		transition.emit(self, "jump", {})

func _on_animation_end(anim_name):
	if is_active and anim_name == "poses/jump_landing":
		transition.emit(self, "movement", {})
		
func get_movement_vector():
	var left = -1 if Input.is_action_pressed("left") else 1 if Input.is_action_pressed("right") else 0
	var forward = -1 if Input.is_action_pressed("backward") else 1 if Input.is_action_pressed("forward") else 0
	
	return Vector3(-left, 0, forward).normalized().rotated(Vector3.UP, physics_target.rotation.y)
	
func physics_update(delta):
	duration += delta
	
	physics_target.apply_central_force(get_movement_vector() * 20)
	physics_target.apply_central_force(Vector3(0, 1, 0) * 40)
	
	#print(foot1.get_contact_count())
	
	if jump_stage == 0 and duration > 0.8 and foot1.get_contact_count() == 0 and foot2.get_contact_count() == 0:
		jump_stage = 1
	elif jump_stage == 1 and (foot1.get_contact_count() > 0 or foot2.get_contact_count() > 0) or duration > 5:
		animation_tree.set("parameters/jump_state/transition_request", "jump_land")

func enter(args):
	duration = 0
	jump_stage = 0
	is_active = true
	animation_tree.set("parameters/Transition/transition_request", "jump")
	animation_tree.set("parameters/jump_state/transition_request", "jump_up")

func exit():
	is_active = false

func can_exit():
	return false
