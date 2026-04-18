extends State


@onready var player: Player = get_parent().get_parent()
@onready var playback: AnimationNodeStateMachinePlayback = (
	player.get_node("AnimationTree").get("parameters/playback")
)
@onready var state_machine: StateMachine = player.get_node("StateMachine")


func _setup() -> void:
	pass


func _s_enter() -> void:
	var direction: Vector3 = player.get_input_direction()
	if direction:
		transition.emit(self, "Walking")
		return
	playback.travel(&"idle")


func _s_exit() -> void:
	pass


func _s_update(_delta: float) -> void:
	pass


func _s_physics_update(delta: float) -> void:
	player.apply_gravity()
	var direction: Vector3 = player.get_input_direction()
	if direction:
		transition.emit(self, "Walking")
		return
	player.velocity.x = move_toward(player.velocity.x, 0, player.friction * delta)
	player.velocity.z = move_toward(player.velocity.z, 0, player.friction * delta)
	player.update_character_direction(direction)
