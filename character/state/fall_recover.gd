extends BaseState

@export var animation_tree: AnimationTree
@export var physics_target: RigidBody3D
@export var pose_match_body: PoseMatchBody

func enter(args):
	var severity = clamp(physics_target.linear_velocity.length() / 4, 0, 1)
	
	print(severity)
	
	animation_tree.set("parameters/Transition/transition_request", "fall_recover")
	animation_tree.set("parameters/landing_severity/blend_amount", severity)

	var tween = get_tree().create_tween()
	pose_match_body.stiffness_modifier = 0.5
	tween.tween_property(pose_match_body, "stiffness_modifier", 1.0, severity)
	await get_tree().create_timer(severity / 1.5).timeout
	transition.emit(self, "movement", {})

func can_exit(next_state_name):
	return false
