@tool
class_name PlayerUI extends Control

@onready var crosshair: Control = %Crosshair


func _draw() -> void:
	await crosshair.draw
	_draw_crosshair()


func _draw_crosshair() -> void:
	crosshair.draw_circle(Vector2.ZERO, 1.0, Color.WHITE)
	#crosshair.draw_line(Vector2(8, 0), Vector2(16, 0), Color.WHITE, 2.0)
	#crosshair.draw_line(Vector2(-8, 0), Vector2(-16, 0), Color.WHITE, 2.0)
	#crosshair.draw_line(Vector2(0, 8), Vector2(0, 16), Color.WHITE, 2.0)
	#crosshair.draw_line(Vector2(0, -8), Vector2(0, -16), Color.WHITE, 2.0)
