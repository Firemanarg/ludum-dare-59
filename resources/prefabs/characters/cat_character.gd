extends Node3D

# ------------------------------------------------------------------------------

@onready var glowing_eyes: Node3D = get_node("%GlowingEyes")
@onready var left_glowing_eye: MeshInstance3D = get_node("%LeftGlowingEye")
@onready var right_glowing_eye: MeshInstance3D = get_node("%RightGlowingEye")
@onready var animation_tree = get_node("AnimationTree")
@onready var playback: AnimationNodeStateMachinePlayback = (
		animation_tree.get(&"parameters/playback"))

# ------------------------------------------------------------------------------

func _ready() -> void:
	pass


func _process(_delta: float) -> void:
	pass


func _physics_process(_delta: float) -> void:
	pass

# ------------------------------------------------------------------------------

func turn_on_eyes(reset_opacity: bool = true) -> void:
	await _turn_on_eyes(reset_opacity)


func turn_off_eyes(reset_opacity: bool = true) -> void:
	await _turn_off_eyes(reset_opacity)


func set_animation_state(state_name: StringName) -> void:
	_set_animation_state(state_name)

# ------------------------------------------------------------------------------

func _turn_on_eyes(reset_opacity: bool = true) -> void:
	var initial_value: float = 0.0
	if not reset_opacity:
		var material: StandardMaterial3D = (
				left_glowing_eye.get_surface_override_material(0))
		initial_value = material.albedo_color.a
	var tween: MethodTweener = _animate_eyes_opacity(
			initial_value, 1.0, CatStatue.TURN_ON_EYES_ANIMATION_DURATION)
	await tween.finished


func _turn_off_eyes(reset_opacity: bool = true) -> void:
	var initial_value: float = 1.0
	if not reset_opacity:
		var material: StandardMaterial3D = (
				left_glowing_eye.get_surface_override_material(0))
		initial_value = material.albedo_color.a
	var tween: MethodTweener = _animate_eyes_opacity(
			initial_value, 0.0, CatStatue.TURN_OFF_EYES_ANIMATION_DURATION)
	await tween.finished
	glowing_eyes.set_visible(false)


func _set_animation_state(state_name: StringName) -> void:
	playback.travel(state_name)


func _animate_eyes_opacity(
		initial_value: float, target_value: float,
		duration: float) -> MethodTweener:
	var tween: Tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	_set_eyes_opacity(initial_value)
	glowing_eyes.set_visible(true)
	return tween.tween_method(
			_set_eyes_opacity, initial_value, target_value, duration)


func _set_eyes_opacity(value: float) -> void:
	var material: StandardMaterial3D = (
			left_glowing_eye.get_surface_override_material(0))
	material.albedo_color.a = value
	left_glowing_eye.set_surface_override_material(0, material)
	right_glowing_eye.set_surface_override_material(0, material)
