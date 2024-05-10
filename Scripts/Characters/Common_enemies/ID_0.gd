extends Common_Enemy



var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")




func set_variables():
	CollisionBox_Scale = Vector2(20, 20)
	HurtBox_Scale = Vector2(22, 22)
	texture_path = "res://Resources/Textures/Develop_things/Common_enemy.png"
	speed = 75
	no_gravity = true

func _process(delta):
	AI()
	gravity_influence()


