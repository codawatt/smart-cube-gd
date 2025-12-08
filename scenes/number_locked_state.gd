extends State

@onready var lock_sprite := %LockSprite

func enter():
	owner.lock()
	
