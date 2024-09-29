extends RigidBody3D
class_name Holdable

var selected_override = preload("res://selected_override.tres")

var mesh: GeometryInstance3D

func _ready() -> void:
	for c in get_children():
		if c is GeometryInstance3D:
			mesh = c

func hover_start():
	mesh.material_override = selected_override
	
func hover_end():
	mesh.material_override = null
