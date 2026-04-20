extends Node3D

# ------------------------------------------------------------------------------

const PLAYER_UNPROJECTED_OFFSET: Vector2 = Vector2(0.0, -20.0)
const CORRIDOR_LENGTH: float = 10.5
const ROOM_LENGTH: float = CORRIDOR_LENGTH * 2.0
const ROWS_COUNT: int = 3
const COLUMNS_COUNT: int = 3
const MAX_CHALLENGE_ROOMS: int = ROWS_COUNT * COLUMNS_COUNT
const MAX_CORRIDORS: int = (ROWS_COUNT + 1) * (COLUMNS_COUNT + 1)

var CHALLENGE_ROOMS: Array[PackedScene] = [
	load("uid://bt12sot3ywwwi"),
	load("uid://xwg1xpytabi2"),
	load("uid://b0twmh7k7dqrq"),
	load("uid://03ipbenr1ecs"),
	load("uid://cfnk6d1c6p3eq"),
	load("uid://bbegutmo2wkyw"),
	load("uid://bh8ofw5ixhtxx"),
	load("uid://d0xvph3iosfmm"),
	load("uid://cfagqskhi80vj"),
]
var CORRIDOR: PackedScene = load("uid://c0fle2j34vmg7")
var START_SAFE_ROOM: PackedScene = load("uid://jxqwrlha4wty")
var TREASURE_FULL_SAFE_ROOM = load("uid://vvplg336cd54")


var _level_seed: int = 0
var _challenge_rooms: Array[ChallengeRoom] = []
var _corridors: Array[Corridor] = []
var _margin_corridors: Array[Corridor] = []
var _margin_corridor_link_offset: PackedVector3Array = []
var _start_room_corridor_index: int = 0
var _treasure_room_corridor_index: int = 0

@onready var transparent_wall_effect: ColorRect = get_node("%TransparentWallEffect")
@onready var player: Player = get_node("%Player")
@onready var camera_3d_walls: Camera3D = get_node("%Camera3DWalls")
@onready var challenge_rooms_root: Node3D = get_node("%ChallengeRooms")
@onready var corridors_root: Node3D = get_node("%Corridors")
@onready var safe_rooms_root: Node3D = get_node("%SafeRooms")

# ------------------------------------------------------------------------------

func _ready() -> void:
	_generate_level(120)
	pass


func _process(_delta: float) -> void:
	pass


func _physics_process(_delta: float) -> void:
	_update_transparent_wall_effect_target()

# ------------------------------------------------------------------------------

func set_level_seed(level_seed: int) -> void:
	_set_level_seed(level_seed)

# ------------------------------------------------------------------------------

func _set_level_seed(level_seed: int) -> void:
	FDLog.log_message("[Level]: Setting level seed to %d." % level_seed)
	_level_seed = level_seed
	seed(_level_seed)


@warning_ignore_start("integer_division")
func _generate_level(level_seed: int) -> void:
	_set_level_seed(level_seed)
	var available_rooms: Array[PackedScene] = CHALLENGE_ROOMS
	available_rooms.shuffle()
	_challenge_rooms.resize(MAX_CHALLENGE_ROOMS)
	_corridors.resize(MAX_CORRIDORS)
	for index: int in MAX_CHALLENGE_ROOMS:
		var room: ChallengeRoom = available_rooms[index].instantiate()
		_challenge_rooms[index] = room
		challenge_rooms_root.add_child(room)
		var room_indices: Vector2i = Vector2i(
				int(index % COLUMNS_COUNT), int(index / ROWS_COUNT))
		room.rotation_degrees.y = [0, 90, 180, 270].pick_random()
		room.position = Vector3(
			ROOM_LENGTH * room_indices.x, 0.0, ROOM_LENGTH * room_indices.y)
	_setup_external_corridors()
	_setup_internal_corridors()
	var available_corridors: Array = range(_margin_corridors.size())
	_start_room_corridor_index = available_corridors.pop_at(
			randi_range(0, available_corridors.size()))
	_treasure_room_corridor_index = available_corridors.pop_at(
			randi_range(0, available_corridors.size()))
	_setup_start_safe_room()
	_setup_treasure_safe_room()
@warning_ignore_restore("integer_division")


func _setup_external_corridors() -> void:
	var offset: Vector3 = Vector3(0, 0, -CORRIDOR_LENGTH)
	for index: int in ROWS_COUNT:
		var initial_pos: Vector3 = _challenge_rooms[index].position
		_setup_room_corridor(offset, initial_pos + offset, true, true)
	offset = Vector3(0, 0, CORRIDOR_LENGTH)
	for index: int in ROWS_COUNT:
		var initial_pos: Vector3 = _challenge_rooms[index + 6].position
		_setup_room_corridor(offset, initial_pos + offset, true, true)
	offset = Vector3(-CORRIDOR_LENGTH, 0, 0)
	for index: int in COLUMNS_COUNT:
		var initial_pos: Vector3 = _challenge_rooms[index * ROWS_COUNT].position
		_setup_room_corridor(offset, initial_pos + offset, false, true)
	offset = Vector3(CORRIDOR_LENGTH, 0, 0)
	for index: int in COLUMNS_COUNT:
		var initial_pos: Vector3 = _challenge_rooms[index * ROWS_COUNT + 2].position
		_setup_room_corridor(offset, initial_pos + offset, false, true)


func _setup_internal_corridors() -> void:
	var offset: Vector3 = Vector3(0, 0, -CORRIDOR_LENGTH)
	for index: int in ROWS_COUNT:
		var initial_pos: Vector3 = _challenge_rooms[index + 3].position
		_setup_room_corridor(offset, initial_pos + offset, true, false)
	offset = Vector3(0, 0, CORRIDOR_LENGTH)
	for index: int in ROWS_COUNT:
		var initial_pos: Vector3 = _challenge_rooms[index + 3].position
		_setup_room_corridor(offset, initial_pos + offset, true, false)
	offset = Vector3(CORRIDOR_LENGTH, 0, 0)
	for index: int in COLUMNS_COUNT:
		var initial_pos: Vector3 = _challenge_rooms[index * ROWS_COUNT].position
		_setup_room_corridor(offset, initial_pos + offset, false, false)
	offset = Vector3(CORRIDOR_LENGTH, 0, 0)
	for index: int in COLUMNS_COUNT:
		var initial_pos: Vector3 = _challenge_rooms[index * ROWS_COUNT + 1].position
		_setup_room_corridor(offset, initial_pos + offset, false, false)


func _setup_room_corridor(
		linked_offset: Vector3, center_position: Vector3,
		is_vertical: bool = false, is_margin_corridor: bool = false) -> Corridor:
	var corridor: Corridor = CORRIDOR.instantiate()
	_corridors.append(corridor)
	corridors_root.add_child(corridor)
	corridor.position = center_position
	corridor.rotation_degrees.y = 90.0 if is_vertical else 0.0
	if is_margin_corridor:
		_margin_corridors.append(corridor)
		_margin_corridor_link_offset.append(linked_offset)
	elif not is_margin_corridor:
		corridor.unobstruct()
	return corridor


func _setup_start_safe_room() -> void:
	var room: SafeRoom = START_SAFE_ROOM.instantiate()
	var corridor: Corridor = _margin_corridors[_start_room_corridor_index]
	var room_offset: Vector3 = (
			_margin_corridor_link_offset[_start_room_corridor_index])
	corridor.unobstruct()
	safe_rooms_root.add_child(room)
	room.rotation_degrees.y = corridor.rotation_degrees.y
	room.position = corridor.position + room_offset


func _setup_treasure_safe_room() -> void:
	var room: SafeRoom = TREASURE_FULL_SAFE_ROOM.instantiate()
	var corridor: Corridor = _margin_corridors[_treasure_room_corridor_index]
	var room_offset: Vector3 = (
			_margin_corridor_link_offset[_treasure_room_corridor_index])
	corridor.unobstruct()
	safe_rooms_root.add_child(room)
	room.rotation_degrees.y = corridor.rotation_degrees.y
	room.position = corridor.position + room_offset


func _update_transparent_wall_effect_target() -> void:
	if not player or not transparent_wall_effect or not camera_3d_walls:
		return
	var wall_material: ShaderMaterial = transparent_wall_effect.material
	wall_material.set_shader_parameter(
			&"Target_Pos_PX",
			camera_3d_walls.unproject_position(player.global_position)
			+ PLAYER_UNPROJECTED_OFFSET)
