extends Node
class_name StateMachine

@export var initial_state: BaseState
@onready var current_state: BaseState = initial_state

var states = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for c in get_children():
		if c is BaseState:
			states[c.name] = c
			c.transition.connect(_on_transition)
	
	current_state.enter({})

func _on_transition(caller, next_state_name, args):
	if current_state:
		if current_state != caller and not current_state.can_exit(next_state_name):
			return
		else:
			current_state.exit()
	
	current_state = states[next_state_name]
	current_state.enter(args)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	current_state.update(delta)

func _physics_process(delta: float) -> void:
	current_state.physics_update(delta)
