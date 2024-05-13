extends CharacterBody2D
const TEXTURE_PATH := "res://Resources/Textures/Characters/Playable/Ogurec/" #Часть пути для текстур, дополняется ниже, когда понадобится


var speed := 200 #Скорость персонажа
var state := "" #Состояние персонажа - идёт там он или стоит типа
var time_to_end_attack := 0 #Таймер до окончания анимации атаки и возможности начала следующей
var time_for_attack := 60 #Сколько времени тратится на цикл атаки с данным оружием
var attack_direction := 0 #Направление атаки
var max_jump := 2 #Сколько максимум прыжков можно сделать, типа 2 - у персонажа есть двойной прыжок, 3 - тройной и т. д.
var jump := 0 #Сколько конкретно сейчас раз ещё может прыгнуть персонаж
var jump_force := -220
var jump_end := true
var last_direction := 0 #В какую сторону последний раз был повёрнут персонаж при движении
var damage := 5 #Урон персонажа в рукопашном бою
var in_move := "Stop"
var max_HP := 4
var HP := 4
var immune_seconds := 0.5

var damageable := true


#Одежда/тип конечностей и т.д.
var eyes_type := "Simple_Glasses"
var body_type := "Simple"
var hands_type := "Simple"
var weapon_type := "Empty"
var hands_weapon_type := hands_type + "_" + weapon_type
var legs_type := "Simple"



func file_name_sprite_ogurec(part, type, orig_state):
	return (TEXTURE_PATH + part + "/" + type + "/" + orig_state + "/" + "Texture.png")

func direction():
	return (int(Input.is_action_pressed("Right")) - int(Input.is_action_pressed("Left")))

func get_weapon(type, time):
	weapon_type = type
	time_for_attack = time

func flip_definition(purpose):
	$Body1.flip_h = (purpose < 0)
	$FrontHand.flip_h = (purpose < 0)
	$BackHand.flip_h = (purpose < 0)
	$Legs.flip_h = (purpose < 0)

func get_player_damage(damage, type, enemyName):
	var timer_immune := Timer.new()
	timer_immune.wait_time = immune_seconds * damage
	timer_immune.timeout.connect(_timer_immune_ends.bind(timer_immune))
	
	if damageable:
		HP -= damage
		add_child(timer_immune)
		timer_immune.start()
		damageable = false

func _timer_immune_ends(timer_immune):
	damageable = true
	timer_immune.queue_free()


func _process(delta):
	if HP <= 0:
		self.queue_free()
	if !is_on_floor():
		jump = min(jump, max_jump - 1)
	
	PlayerInfo.player_position = position
	
	if Input.is_action_pressed("Right") or Input.is_action_pressed("Left"):
		last_direction = direction()
	
	
	#прыжок восстанавливается, когда персонаж на полу
	if is_on_floor():
		jump = max_jump
	
	if direction() != 0:
		in_move = "Move"
	else:
		in_move = "Stop"
	
	#определяем, в каком состоянии сейчас персонаж
	if (time_to_end_attack > 0):
		state = "Attack" # Если атака в движении отличается от атаки на месте, то это состояние поможет
	else:
		if direction() != 0:
			state = "Move" # Персонаж движется ИЛИ ты нажимаешь кнопки движения, ДАЖЕ упираясь в стену
		else:
			state = "Stop" # Персонаж стоит
	
	$AnimationPlayer.play(state)
	$Legs/AhimationLegs.play(in_move)
	
	
	
	#Программа создаёт путь файла, основываясь на состоянии персонажа и типе конечностей и подгружает файл оттуда в текстуру, используя функцию, которая написана выше, на строке 22
	$Body1.texture = ResourceLoader.load(file_name_sprite_ogurec("Body", body_type, state))
	$FrontHand.texture = ResourceLoader.load(file_name_sprite_ogurec("Hands/FrontHand", hands_weapon_type, state))
	$BackHand.texture = ResourceLoader.load(file_name_sprite_ogurec("Hands/BackHand", hands_weapon_type, state))
	$Legs.texture = ResourceLoader.load(file_name_sprite_ogurec("Legs", legs_type, in_move))
	
	#region MATCH_STATE
	#Как должен выглядеть спрайт при различных состояниях персонажа - (легаси, потом исправлю)
	match state:
		"Move":
			flip_definition(direction())
		"Attack":
			flip_definition(attack_direction)
	#endregion
	
	
	if time_to_end_attack > 0:
		time_to_end_attack -= 144 * delta
	
	#endregion
	
	if (Input.is_action_just_pressed("Click") and state != "Stop" and time_to_end_attack == 0):
		attack_direction = direction()
		time_to_end_attack = time_for_attack
	
	if Input.is_action_just_pressed("Click") and state == "Stop":
		attack_direction = last_direction
		time_to_end_attack = time_for_attack
	
	
	if attack_direction > 0:
		if time_to_end_attack != 0:
			$Attack/RightHitBox.position.y = 0
	else:
		if time_to_end_attack != 0:
			$Attack/LeftHitBox.position.y = 0
	if time_to_end_attack == 0:
		$Attack/RightHitBox.position.y = -400
		$Attack/LeftHitBox.position.y = -400
	
	
	
	
	if Input.is_action_pressed("Jump") and !jump_end:
		velocity.y = jump_force
	
	if Input.is_action_just_pressed("Jump") && jump == max_jump:
		var timer_jump := Timer.new()
		timer_jump.wait_time = 0.35
		timer_jump.timeout.connect(_timer_jump_ends.bind(timer_jump))
		jump -= 1
		velocity.y = jump_force * 0.8
		jump_end = false
		add_child(timer_jump)
		timer_jump.start()
		
	
	elif Input.is_action_just_pressed("Jump") && jump > 0:
		velocity.y = (jump_force * (jump + 1.5) * 1.3) / max_jump
		jump -= 1
	
	if Input.is_action_just_released("Jump"):
		jump_end = true
	
	velocity.x = direction() * speed
	if jump_end:
		velocity.y += 980 * delta
	move_and_slide()
	

func _timer_jump_ends(timer_jump):
	jump_end = true
	timer_jump.queue_free()



func _on_attack_area_entered(area):
	if area.get_parent().has_method("get_damage"):
		area.get_parent().get_damage(position - area.position - Vector2(0, 100), damage)
	pass # Replace with function body.

