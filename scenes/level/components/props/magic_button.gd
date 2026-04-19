extends Node3D

# ------------------------------------------------------------------------------

var was_pressed: bool = false

@onready var unpressed_button: MeshInstance3D = get_node("%UnpressedButton")
@onready var pressed_button: MeshInstance3D = get_node("%PressedButton")

# ------------------------------------------------------------------------------

func _ready() -> void:
	unpressed_button.set_visible(true)
	pressed_button.set_visible(false)


func _process(_delta: float) -> void:
	pass


func _physics_process(_delta: float) -> void:
	pass

# ------------------------------------------------------------------------------

func press() -> void:
	_on_pressed()

# ------------------------------------------------------------------------------

func _on_pressed() -> void:
	if was_pressed:
		return
	was_pressed = true
	unpressed_button.set_visible(false)
	pressed_button.set_visible(true)
