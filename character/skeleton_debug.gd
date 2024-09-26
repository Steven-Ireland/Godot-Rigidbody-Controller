extends Node

@export var skeleton: Skeleton3D

var bone_debugs = []

func _ready():
	for bone_idx in range(skeleton.get_bone_count()):
		var rc = RayCast3D.new()
		add_child(rc)
		bone_debugs.push_back(rc)

func _process(delta: float) -> void:
	for bone_idx in range(skeleton.get_bone_count()):
		var target = skeleton.transform * skeleton.get_bone_global_pose(bone_idx)
		var bone_rotation = target.basis.get_euler()
		var bone_position = target.origin
		
		bone_debugs[bone_idx].position = bone_position
		bone_debugs[bone_idx].rotation = bone_rotation
