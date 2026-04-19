extends Node3D


const PLAYER_UNPROJECTED_OFFSET: Vector2 = Vector2(0.0, -20.0)


@onready var transparent_wall_effect: ColorRect = get_node("%TransparentWallEffect")
@onready var player: Player = get_node("%Player")
@onready var camera_3d_walls: Camera3D = get_node("%Camera3DWalls")


func _ready() -> void:
	pass


func _process(_delta: float) -> void:
	pass


func _physics_process(_delta: float) -> void:
	_update_transparent_wall_effect_target()


func _update_transparent_wall_effect_target() -> void:
	if not player or not transparent_wall_effect or not camera_3d_walls:
		return
	var wall_material: ShaderMaterial = transparent_wall_effect.material
	wall_material.set_shader_parameter(
			&"Target_Pos_PX",
			camera_3d_walls.unproject_position(player.global_position)
				+ PLAYER_UNPROJECTED_OFFSET)
