extends Common_Enemy



var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")




func set_variables():
	CollisionBox_Scale = Vector2(0, 0)
	HurtBox_Scale = Vector2(0, 0)
	texture_path = "res://Resources/Textures/Engine icons/Common_enemy.png"
	speed = 75
	no_gravity = true

func _process(delta):
	AI()
	gravity_influence()


