extends SpriteOscillator

const minus_texture:Texture = preload("res://assets/minus.png")
const plus_texture:Texture = preload("res://assets/plus.png")


func _ready():
	owner.power_up_changed.connect(_on_power_up_changed)
	
func _on_power_up_changed() -> void:
	match(owner.amount):
		1:
			texture = plus_texture
		-1:
			texture = minus_texture
