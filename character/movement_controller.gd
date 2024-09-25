extends Node

@export var follow: Node3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	var left = -1 if Input.is_action_pressed("ui_left") else 1 if Input.is_action_pressed("ui_right") else 0
	var forward = -1 if Input.is_action_pressed("ui_down") else 1 if Input.is_action_pressed("ui_up") else 0
	var direction = Vector2(left, forward)
	
	#linear_velocity = Vector3(direction.x, 0, direction.y) * 0.01
	$Skeleton3D.global_position = follow.global_position + Vector3(1, -1, 0);
	
	# todo: project along plane
	$Skeleton3D.rotation.y = lerp($Skeleton3D.rotation.y, get_parent().get_node("SpringArm3D").rotation.y, 0.5)
	var projected: Vector3 = follow.linear_velocity.project(follow.transform.basis.z) / 10
	var a_sign = 1 if projected.angle_to(follow.transform.basis.z) == 0 else -1
	#$Skeleton3D.rotation.x = projected.length() * a_sign


func _process(delta: float) -> void:
	var left = -1 if Input.is_action_pressed("ui_left") else 1 if Input.is_action_pressed("ui_right") else 0
	var forward = -1 if Input.is_action_pressed("ui_down") else 1 if Input.is_action_pressed("ui_up") else 0
	var direction = Vector2(left, forward)
	
	
		
	if Input.is_action_pressed("ui_accept"):
		$AnimationPlayer.play("poses/jump")
	elif forward > 0:
		$AnimationPlayer.play("poses/run")
	elif forward < 0:
		$AnimationPlayer.play("poses/back_run")
	elif left < 0:
		$AnimationPlayer.play("poses/walk_left")
	elif left > 0:
		$AnimationPlayer.play("poses/walk_right")
	else:
		$AnimationPlayer.play("poses/idle")
