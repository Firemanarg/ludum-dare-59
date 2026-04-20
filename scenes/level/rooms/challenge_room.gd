class_name ChallengeRoom
extends Room

# ------------------------------------------------------------------------------

@onready var door_key: Node3D = get_node("%DoorKey")

# ------------------------------------------------------------------------------

func _ready() -> void:
	pass


func _process(_delta: float) -> void:
	pass


func _physics_process(_delta: float) -> void:
	pass

# ------------------------------------------------------------------------------

func remove_key() -> void:
	door_key.queue_free()
