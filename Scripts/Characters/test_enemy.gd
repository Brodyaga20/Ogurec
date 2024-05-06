extends CharacterBody2D
var hp = 5
const IMMUNE_FRAMES = 60
var immune_left := 0
var knockback_multiplier := 150

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	velocity.x *= 0.999
	velocity.y *= 0.999
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
