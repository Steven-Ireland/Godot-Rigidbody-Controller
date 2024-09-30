extends BaseState

@export var animation_tree: AnimationTree
@export var physics_target: RigidBody3D
@export var pose_match_body: PoseMatchBody

func enter(args):
	var hit: Node3D = args.surface
	var foot: Node3D = args.foot
	
	var space_state = foot.get_world_3d().direct_space_state
	
	var ray = PhysicsRayQueryParameters3D.create(foot.global_position, hit.global_position, 1)
	var result = space_state.intersect_ray(ray)
	
	var severity = 1.0
	if result:
		print(result)
		var normal: Vector3 = result.normal
		var along_normal = foot.linear_velocity.project(-normal)
		
		severity = along_normal.length() / 3
		
	print(severity)
	
	animation_tree.set("parameters/Transition/transition_request", "fall_recover")
	animation_tree.set("parameters/landing_severity/blend_amount", severity)

	var tween = get_tree().create_tween()
	pose_match_body.stiffness_modifier = .8
	tween.tween_property(pose_match_body, "stiffness_modifier", .3, severity)
	tween.tween_property(pose_match_body, "stiffness_modifier", 1.0, 0.1)
	tween.play()
	await tween.finished
	tween.kill()
	transition.emit(self, "movement", {})

func can_exit(next_state_name):
	return false
