class_name CatStatue
extends Node3D

# ------------------------------------------------------------------------------

signal applied_attack

# ------------------------------------------------------------------------------

const ATTACK_DURATION: float = 2.0
const TURN_ON_EYES_ANIMATION_DURATION: float = 4.0
const TURN_OFF_EYES_ANIMATION_DURATION: float = 1.5


@export var _attack_list: Array[Dictionary] = []

var _current_index: int = 0
var _rotation_tween: Tween = null
var _is_applying_behaviour: bool = false

@onready var cat_character: Node3D = get_node("%CatCharacter")
@onready var laser_mesh: MeshInstance3D = get_node("%LaserMesh")

# ------------------------------------------------------------------------------

func _ready() -> void:
	cat_character.set_animation_state(&"static")
	cat_character.set_visible(true)
	laser_mesh.set_visible(false)
	_update_attack_list()
	applied_attack.connect(_on_applied_attack)
	_start_attacking()


func _process(_delta: float) -> void:
	pass


func _physics_process(_delta: float) -> void:
	pass

# ------------------------------------------------------------------------------

func _start_attacking() -> void:
	_current_index = 0
	if _current_index >= _attack_list.size():
		FDLog.log_message(
				"[CatStatue]: Attempted to access index %d from attack_list, "
				+ "but size is %d." % [_current_index, _attack_list.size()],
				FDLog.LogLevel.WARNING)
		return
	_apply_attack(_attack_list[_current_index])


func _update_attack_list() -> void:
	_attack_list.clear()
	if get_child_count() == 0:
		FDLog.log_message(
				"[CatStatue]: No visualizer found. Statue will not attack.",
				FDLog.LogLevel.NOTICE)
		return
	var next_rotation: Vector3 = get_child(0).rotation_degrees
	var children: Array[Node] = get_children()
	children.reverse()
	for child: Node in children:
		if child is CatStatueVisualizer:
			_attack_list.append({
				&"pre_delay": child.pre_delay,
				&"post_delay": child.post_delay,
				&"turn_duration": child.turn_duration,
				&"target_rotation": next_rotation
			})
			next_rotation = child.rotation_degrees
			child.queue_free()


func _apply_attack(attack_settings: Dictionary) -> void:
	if _is_applying_behaviour:
		FDLog.log_message(
				"[CatStatue]: Attempted to apply behaviour while another "
				+ "behaviour was being applied. Skipping new apply. This "
				+ "may cause synchronization issues later.",
				FDLog.LogLevel.WARNING)
		return
	_is_applying_behaviour = true
	var pre_delay: float = attack_settings.get(&"pre_delay", 0.0)
	var post_delay: float = attack_settings.get(&"post_delay", 0.0)
	var turn_duration: float = attack_settings.get(&"turn_duration", 0.0)
	var target_rotation: Vector3 = (
			attack_settings.get(&"target_rotation", Vector3(0.0, 0.0, 0.0)))
	if pre_delay > 0.0:
		await get_tree().create_timer(pre_delay).timeout
	await cat_character.turn_on_eyes()
	await _attack()
	await cat_character.turn_off_eyes()
	if post_delay > 0.0:
		await get_tree().create_timer(post_delay).timeout
	if _rotation_tween:
		_rotation_tween.kill()
	if turn_duration > 0.0:
		_rotation_tween = get_tree().create_tween()
		_rotation_tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
		_rotation_tween.tween_property(
				cat_character, "rotation_degrees", target_rotation, turn_duration)
		await  _rotation_tween.finished
	else:
		cat_character.rotation_degrees = target_rotation
	_is_applying_behaviour = false
	applied_attack.emit()


func _attack() -> void:
	laser_mesh.set_visible(true)
	await get_tree().create_timer(ATTACK_DURATION).timeout
	laser_mesh.set_visible(false)

# ------------------------------------------------------------------------------

func _on_applied_attack() -> void:
	_current_index = (_current_index + 1) % _attack_list.size()
	if _current_index >= 0:
		_apply_attack(_attack_list[_current_index])
