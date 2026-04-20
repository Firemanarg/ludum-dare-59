class_name Corridor
extends Node3D

# ------------------------------------------------------------------------------

@onready var _obstruction_layer: StaticBody3D = get_node("%ObstructionLayer")

# ------------------------------------------------------------------------------

func _ready() -> void:
	pass


func _process(_delta: float) -> void:
	pass


func _physics_process(_delta: float) -> void:
	pass

# ------------------------------------------------------------------------------

func unobstruct() -> void:
	_unobstruct()

# ------------------------------------------------------------------------------

func _unobstruct() -> void:
	_obstruction_layer.queue_free()
	_obstruction_layer = null
