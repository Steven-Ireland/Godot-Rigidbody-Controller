extends Node3D

@export var target: Node3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _input(e: InputEvent) -> void:
	if e is InputEventMouseMotion:
		rotate(Vector3.UP, -e.screen_relative.x / 100)
		rotate(transform.basis.x, e.screen_relative.y / 100)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var targets = target.get_children()
	var pos = Vector3()
	for t in targets:
		pos += t.global_position
	
	pos /= len(targets)
	
	pos += Vector3(0, 0.5, 0)
		
	global_position = lerp(global_position, pos, 0.3)
	
	
