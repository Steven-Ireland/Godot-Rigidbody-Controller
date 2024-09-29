extends BaseState

@export var animation_tree: AnimationTree

# Called when the node enters the scene tree for the first time.
func _ready():
	animation_tree.animation_finished.connect(_on_animation_end)
	
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("emote"):
		transition.emit(self, "emote", {})

func _on_animation_end(anim_name):
	if anim_name == "poses/breakdance":
		transition.emit(self, "movement", {})
	
func enter(args):
	animation_tree.set("parameters/Transition/transition_request", "emote")
