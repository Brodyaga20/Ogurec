extends Common_Enemy



var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")



func set_variables():
	no_gravity = false
	falling_speed = 1
	pass

func _process(delta):
	AI()
	gravity_influence()
	pass

