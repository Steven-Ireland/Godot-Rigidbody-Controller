extends BaseState

@export var pose_match_body: PoseMatchBody
@export var animation_tree: AnimationTree
@export var animation_player: AnimationPlayer
@export var physics_target: RigidBody3D
@export var skeleton: Skeleton3D
@export var feet: Array[RigidBody3D]

var is_active := false
var duration := 0.0



func _ready():
	animation_tree.animation_finished.connect(_on_animation_end)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("jump"):
		transition.emit(self, "jump", {})

func _on_animation_end(anim_name):
	if is_active and anim_name == "poses/jump":
		transition.emit(self, "fall", {})
		
func get_movement_vector():
	var left = -1 if Input.is_action_pressed("left") else 1 if Input.is_action_pressed("right") else 0
	var forward = -1 if Input.is_action_pressed("backward") else 1 if Input.is_action_pressed("forward") else 0
	
	return Vector3(-left, 0, forward).normalized()
	
func physics_update(delta):
	duration += delta
	var movement = get_movement_vector()
	
	var rotation_radians_x = movement.z * PI / 20.0
	var rotation_radians_z = movement.x * PI / 20.0
	
	skeleton.rotation.z = 0
	skeleton.rotation.x = 0
	
	skeleton.rotate(skeleton.transform.basis.x.normalized(), rotation_radians_x)
	skeleton.rotate(skeleton.transform.basis.z.normalized(), -rotation_radians_z)
	
	physics_target.apply_central_force(get_movement_vector().rotated(Vector3.UP, physics_target.rotation.y) * 10)
	physics_target.apply_central_force(Vector3(0, 1, 0) * 20)

func update(delta):
	if Input.is_action_just_released("jump"):
		pose_match_body.stiffness_modifier = 1.5
		animation_tree.set("parameters/jump_seek/seek_request", 0.65)

func enter(args):
	duration = 0
	is_active = true
	animation_tree.set("parameters/Transition/transition_request", "jump")
	for f in feet:
		f.physics_material_override.friction = 0.3

func exit():
	is_active = false
	pose_match_body.stiffness_modifier = 1.0
	skeleton.rotation.z = 0
	skeleton.rotation.x = 0
	
	for f in feet:
		f.physics_material_override.friction = 1.0

func can_exit(new_state_name):
	return new_state_name == "fall"
