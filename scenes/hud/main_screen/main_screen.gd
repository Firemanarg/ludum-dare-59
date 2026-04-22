extends Node3D

# ------------------------------------------------------------------------------

const IDLE_TIMER_DURATION: float = 5.0
const DANCE_TIMER_DURATION: float = 1.0
const LASER_TIMER_DURATION: float = 1.0
const LASER_LIGHT_1_ENERGY: float = 3.0
const LASER_LIGHT_2_ENERGY: float = 3.0
const DANCE_ANIMATION_COUNT_TO_LASER: int = 5


var _dance_animation_count: int = 0

@onready var cat_character: Node3D = get_node("%CatCharacter")
@onready var left_eye_glow_effect: MeshInstance3D = get_node("%LeftEyeGlowEffect")
@onready var right_eye_glow_effect: MeshInstance3D = get_node("%RightEyeGlowEffect")
@onready var laser_light_1: OmniLight3D = get_node("%LaserLight1")
@onready var laser_light_2: OmniLight3D = get_node("%LaserLight2")

# ------------------------------------------------------------------------------

func _ready() -> void:
	cat_character.set_animation_state(&"idle")
	get_tree().create_timer(IDLE_TIMER_DURATION).timeout.connect(_on_idle_timer_timeout)


func _process(_delta: float) -> void:
	pass


func _physics_process(_delta: float) -> void:
	pass

# ------------------------------------------------------------------------------

func _tween_laser_light(
		light: OmniLight3D, initial_value: float,
		target_value: float, duration: float) -> void:
	light.light_energy = initial_value
	var tween: Tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	return tween.tween_property(light, "light_energy", target_value, duration)


func _tween_glow_effect(
		initial_value: float, target_value: float, duration: float) -> void:
	var tween: Tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	_set_glow_effect_opacity(initial_value)
	return tween.tween_method(
			_set_glow_effect_opacity, initial_value, target_value, duration)


func _set_glow_effect_opacity(value: float) -> void:
	var material: StandardMaterial3D = (
			left_eye_glow_effect.get_surface_override_material(0))
	material.albedo_color.a = value
	left_eye_glow_effect.set_surface_override_material(0, material)
	left_eye_glow_effect.set_surface_override_material(0, material)


func _start_laser_animation() -> void:
	cat_character.set_animation_state(&"laser")
	_tween_glow_effect(0.0, 1.0, CatStatue.TURN_ON_EYES_ANIMATION_DURATION)
	laser_light_1.set_visible(true)
	laser_light_2.set_visible(true)
	_tween_laser_light(
			laser_light_1, 0.0, LASER_LIGHT_1_ENERGY,
			CatStatue.TURN_ON_EYES_ANIMATION_DURATION)
	_tween_laser_light(
			laser_light_2, 0.0, LASER_LIGHT_2_ENERGY,
			CatStatue.TURN_ON_EYES_ANIMATION_DURATION)
	await cat_character.turn_on_eyes()


func _stop_laser_animation() -> void:
	_tween_glow_effect(1.0, 0.0, CatStatue.TURN_OFF_EYES_ANIMATION_DURATION)
	_tween_laser_light(
			laser_light_1, LASER_LIGHT_1_ENERGY, 0.0,
			CatStatue.TURN_OFF_EYES_ANIMATION_DURATION * 0.9)
	_tween_laser_light(
			laser_light_2, LASER_LIGHT_2_ENERGY, 0.0,
			CatStatue.TURN_OFF_EYES_ANIMATION_DURATION * 0.9)
	await cat_character.turn_off_eyes()

# ------------------------------------------------------------------------------

func _on_idle_timer_timeout() -> void:
	if _dance_animation_count >= DANCE_ANIMATION_COUNT_TO_LASER:
		_dance_animation_count = 0
		await _start_laser_animation()
		get_tree().create_timer(
				LASER_TIMER_DURATION).timeout.connect(_on_laser_timer_timeout)
		return
	cat_character.set_animation_state(&"dance")
	get_tree().create_timer(DANCE_TIMER_DURATION).timeout.connect(_on_dance_timer_timeout)


func _on_dance_timer_timeout() -> void:
	_dance_animation_count += 1
	cat_character.set_animation_state(&"idle")
	get_tree().create_timer(IDLE_TIMER_DURATION).timeout.connect(_on_idle_timer_timeout)


func _on_laser_timer_timeout() -> void:
	await _stop_laser_animation()
	_dance_animation_count = 0
	cat_character.set_animation_state(&"idle")
	get_tree().create_timer(IDLE_TIMER_DURATION).timeout.connect(_on_idle_timer_timeout)
