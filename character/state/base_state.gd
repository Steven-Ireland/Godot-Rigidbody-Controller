extends Node
class_name BaseState

signal transition(caller: BaseState, next_state: String, args: Dictionary)

func enter(args: Dictionary) -> void:
	pass
	
func exit() -> void:
	pass
	
func update(delta) -> void:
	pass

func physics_update(delta) -> void:
	pass

func can_exit() -> bool:
	return true
