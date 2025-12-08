extends StateMachine


@onready var normal = %Normal
@onready var locked = %Locked


func _ready():
	states_map = {
		"normal": normal,
		"locked": locked,
	}
