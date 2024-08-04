@tool
class_name PlayerUI extends Control

@onready var crosshair: Control = %Crosshair


func _draw() -> void:
	await crosshair.draw
	_draw_crosshair()


## Use this method if you want to draw a custom crosshair. Remove if you want to use a custom image for the crosshair
func _draw_crosshair() -> void:
	crosshair.draw_circle(Vector2.ZERO, 1.0, Color.WHITE)
