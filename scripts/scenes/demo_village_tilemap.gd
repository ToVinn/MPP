extends Node2D
## Scene demo tilemap — tekan [Esc] untuk kembali ke Title Screen.

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		GameManager.change_scene("res://scenes/title_screen.tscn", 0.5)
