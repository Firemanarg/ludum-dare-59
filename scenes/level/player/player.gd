class_name Player
extends CharacterBody3D


var friction: float = 40.0
var acceleration: float = 6.0
var max_ground_speed: float = 2.3
#var max_ground_speed: float = 3.0
var max_air_speed: float = 1.5
var jump_velocity: float = 4.5


@onready var character: Node3D = get_node("Character")


func _physics_process(_delta: float) -> void:
	call_deferred(&"move_and_slide")


func apply_gravity() -> void:
	if not is_on_floor():
		velocity += get_gravity() * get_physics_process_delta_time()


func get_input_direction() -> Vector3:
	var input_dir: Vector2 = Input.get_vector(
			&"move_left", &"move_right", &"move_up", &"move_down")
	var direction: Vector3 = (
			(transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized())
	return direction


func update_character_direction(input_direction: Vector3) -> void:
	if not input_direction or not velocity:
		return
	var original_rotation: Vector3 = character.global_rotation
	character.look_at(character.global_position + input_direction, Vector3.UP, true)
	var new_rotation: Vector3 = character.global_rotation
	character.rotation = Vector3(
			original_rotation.x,
			lerp_angle(original_rotation.y, new_rotation.y, 0.3),
			original_rotation.z)
