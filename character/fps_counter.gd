extends Label

@export var state_machine: StateMachine

func _process(delta: float) -> void:
	text = str(Engine.get_frames_per_second()) + "\n" + state_machine.current_state.name
