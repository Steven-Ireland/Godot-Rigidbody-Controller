extends RigidBody3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	var left = -1 if Input.is_action_pressed("ui_left") else 1 if Input.is_action_pressed("ui_right") else 0
	var forward = -1 if Input.is_action_pressed("ui_down") else 1 if Input.is_action_pressed("ui_up") else 0
	var direction = Vector2(left, forward)
	
	#linear_velocity = Vector3(direction.x, 0, direction.y) * 0.01


func _process(delta: float) -> void:
	var left = -1 if Input.is_action_pressed("ui_left") else 1 if Input.is_action_pressed("ui_right") else 0
	var forward = -1 if Input.is_action_pressed("ui_down") else 1 if Input.is_action_pressed("ui_up") else 0
	var direction = Vector2(left, forward)
	
	if Input.is_action_just_pressed("ui_accept"):
		$Pose/AnimationPlayer.play("poses/run_jump")
	if forward > 0:
		$Pose/AnimationPlayer.play("poses/run")
	elif forward < 0:
		$Pose/AnimationPlayer.play("poses/back_run")
	#else:
		#$Pose/AnimationPlayer.play("poses/idle")
