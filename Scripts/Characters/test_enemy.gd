extends CharacterBody2D
class_name Common_Enemy

const IMMUNE_FRAMES = 60
var hp = 5
var immune_left := 0
var knockback_multiplier := 150
var can_be_damaged := true
var damage_resistance := 0
var contact_damage := 1

func _ready():
	pass


	# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	velocity.x *= 0.99
	velocity.y *= 0.99
	if hp == 0:
		queue_free()
	else:
		position.x -= 0.2 - ((Global.player_position.x - position.x + 13) * 0.01)
		position.y -= 0.2 - ((Global.player_position.y - position.y + 25) * 0.01)
	if immune_left > 0:
		immune_left -= 1
	move_and_slide()
	



func _on_hurtbox_area_entered(area):
	print(hp)
	if immune_left == 0:
		if area.name == "LeftHurtBox":
			velocity.x -= knockback_multiplier
		if area.name == "RightHurtBox":
			velocity.x += knockback_multiplier
		hp -= 1
		immune_left = IMMUNE_FRAMES 
