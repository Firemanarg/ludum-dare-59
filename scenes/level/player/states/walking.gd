extends State


@onready var player: Player = get_parent().get_parent()
@onready var playback: AnimationNodeStateMachinePlayback = (
	player.get_node("AnimationTree").get("parameters/playback")
)
@onready var state_machine: StateMachine = player.get_node("StateMachine")


func _setup() -> void:
	pass


func _s_enter() -> void:
	playback.travel(&"walking")


func _s_exit() -> void:
	pass


func _s_update(_delta: float) -> void:
	pass


func _s_physics_update(delta: float) -> void:
	player.apply_gravity()
	if not player.is_on_floor():
		transition.emit(self, "Falling")
	var direction: Vector3 = player.get_input_direction()
	if not direction:
		transition.emit(self, "Idle")
		return
	player.velocity.x = lerp(
		player.velocity.x,
		direction.x * player.max_ground_speed,
		player.acceleration * delta
	)
	player.velocity.z = lerp(
		player.velocity.z,
		direction.z * player.max_ground_speed,
		player.acceleration * delta
	)
	player.update_character_direction(direction)
