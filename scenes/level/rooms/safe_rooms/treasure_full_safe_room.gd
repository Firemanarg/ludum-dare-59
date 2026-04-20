extends SafeRoom

# ------------------------------------------------------------------------------

@onready var corridor: Corridor = get_node("%Corridor")

# ------------------------------------------------------------------------------

func _ready() -> void:
	corridor.unobstruct()


func _process(_delta: float) -> void:
	pass


func _physics_process(_delta: float) -> void:
	pass

# ------------------------------------------------------------------------------
