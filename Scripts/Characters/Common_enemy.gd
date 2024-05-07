extends CharacterBody2D
class_name Common_Enemy

const IMMUNE_FRAMES = 60
var hp = 5
var immune_left := 0
var knockback_multiplier := 150
var can_be_damaged := true
var damage_resistance := 0
var contact_damage := 1
var falling_speed = 10
var no_gravity = true

func set_variables():
	pass

func _ready():
	set_variables()
	pass

func get_damage(direction):
		if immune_left == 0:
			velocity -= direction
			hp -= 1
			immune_left = IMMUNE_FRAMES

func AI():
	velocity.x *= 0.99
	velocity.y *= 0.99
	if hp == 0:
		queue_free()
	else:
		position.x -= 0.2 - ((PlayerInfo.player_position.x - position.x + 13) * 0.01)
		position.y -= 0.2 - ((PlayerInfo.player_position.y - position.y + 25) * 0.01)
	if immune_left > 0:
		immune_left -= 1
	move_and_slide()



func gravity_influence():
	if !no_gravity:
		if !is_on_floor():
			velocity.y += falling_speed
	

	# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	AI()
	gravity_influence()
	pass




 
