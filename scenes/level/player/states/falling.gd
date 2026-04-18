extends State


@onready var player: Player = get_parent().get_parent()
@onready var playback: AnimationNodeStateMachinePlayback = (
	player.get_node("AnimationTree").get("parameters/playback")
)
@onready var state_machine: StateMachine = player.get_node("StateMachine")


func _setup() -> void:
	pass


func _s_enter() -> void:
	playback.travel(&"falling")


func _s_exit() -> void:
	pass


func _s_update(_delta: float) -> void:
	pass


func _s_physics_update(delta: float) -> void:
	player.apply_gravity()
	if player.is_on_floor():
		transition.emit(self, "Idle")
		return
	var direction: Vector3 = player.get_input_direction()
	if not direction:
		player.velocity.x = move_toward(player.velocity.x, 0, player.friction * delta)
		player.velocity.z = move_toward(player.velocity.z, 0, player.friction * delta)
		return
	player.velocity.x = lerp(
		player.velocity.x,
		direction.x * player.max_air_speed,
		player.acceleration * delta
	)
	player.velocity.z = lerp(
		player.velocity.z,
		direction.z * player.max_air_speed,
		player.acceleration * delta
	)
	player.update_character_direction(direction)
	var is_attacking: bool = Input.is_action_just_pressed(&"attack")
	if is_attacking:
		playback.travel(&"idle_attack_melee")
