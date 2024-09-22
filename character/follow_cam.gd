extends Node3D

@export var target: Node3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var targets = target.get_children()
	var pos = Vector3()
	for t in targets:
		pos += t.global_position
	
	pos /= len(targets)
	
	pos += Vector3(0, 1, 0)
		
	global_position = lerp(global_position, pos, 0.3)
