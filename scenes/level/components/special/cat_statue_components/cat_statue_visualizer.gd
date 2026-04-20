class_name CatStatueVisualizer
extends Node3D

# ------------------------------------------------------------------------------

@export_range(0.0, 10.0, 0.1, "or_greater") var pre_delay: float = 0.0
@export_range(0.0, 10.0, 0.1, "or_greater") var post_delay: float = 0.0
@export_range(0.0, 10.0, 0.1, "or_greater") var turn_duration: float = 0.0

# ------------------------------------------------------------------------------

func _ready() -> void:
	pass


func _process(_delta: float) -> void:
	pass


func _physics_process(_delta: float) -> void:
	pass

# ------------------------------------------------------------------------------
