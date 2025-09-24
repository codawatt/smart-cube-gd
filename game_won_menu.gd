class_name GameWonMenu
extends OverlaidMenu

signal continue_pressed

func _on_close_button_pressed():
	continue_pressed.emit()
	close()
