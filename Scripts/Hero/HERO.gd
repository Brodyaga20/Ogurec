extends CharacterBody2D
const TEXTURE_PATH := "res://Resources/Textures/Characters/Playable/Ogurec/" #Часть пути для текстур, дополняется ниже, когда понадобится


var speed := 200 #Скорость персонажа
var timer := 0 #Хз, не помню уже
var state := "" #Состояние персонажа - идёт там он или стоит типа
var time_to_end_attack := 0 #Таймер до окончания анимации атаки и возможности начала следующей
var time_for_attack := 60 #Сколько времени тратится на цикл атаки с данным оружжием
var attack_direction := 0 #Направление атаки
var max_jump := 1 #Сколько максимум прыжков можно сделать, типа 2 - у персонажа есть двойной прыжок, 3 - тройной и т. д.
var jump := 0 #Сколько конкретно сейчас раз ещё может прыгнуть персонаж
var jump_force = -220
var jump_end = true
var last_direction := 0 #В какую сторону последний раз был повёрнут персонаж при движении
var damage = 1 #Урон персонажа в рукопашном бою
var attack_frames = 4


#Одежда/тип конечностей и т.д.
var eyes_type := "Simple_Glasses"
var body_type := "Simple"
var hands_type := "Simple"
var weapon_type := "Empty"
var hands_weapon_type := hands_type + "_" + weapon_type
var legs_type := "Simple"


func file_name_sprite_ogurec(part, type):
	return (TEXTURE_PATH + part + "/" + type + "/" + state + "/" + "Texture.png")

func direction():
	return (int(Input.is_action_pressed("Right")) - int(Input.is_action_pressed("Left")))

func get_weapon(type, time):
	weapon_type = type
	attack_frames = time


func _process(delta):
	
	timer += 1
	PlayerInfo.player_position = position
	#на пока
	if Input.is_action_just_pressed("Return"):
		get_tree().quit()
		
	#прыжок восстанавливается, когда персонаж на полу
	if is_on_floor():
		jump = max_jump
		
	#определяем, в каком состоянии сейчас персонаж
	if (time_to_end_attack > 0):
		if direction() != 0:
			state = "Attack_in_move" # Если атака в движении отличается от атаки на месте, то это состояние поможет
		else:
			state = "Attack" # Просто атака
	else:
		if direction() != 0:
			state = "Move" # Персонаж движется ИЛИ ты нажимаешь кнопки движения, ДАЖЕ упираясь в стену
		else:
			state = "Stop" # Персонаж стоит
	
	$AnimationPlayer.play(state)
	
	#region SCREEN_PARAMETERS
	#Режимы: полноэкранныйй, оконный
	if Input.is_action_pressed("FullScreen"):
		if (DisplayServer.window_get_mode() != 3):
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	#endregion
	
	#Атака
	
	#Разная простая анимка, мб потом переделаю в норм вид
	
	
	
	#Программа создаёт путь файла, основываясь на состоянии персонажа и типе конечностей и подгружает файл оттуда в текстуру, используя функцию, которая написана выше, на строке 22
	$Body1.texture = ResourceLoader.load(file_name_sprite_ogurec("Body", body_type))
	$FrontHand.texture = ResourceLoader.load(file_name_sprite_ogurec("Hands/FrontHand", hands_weapon_type))
	$BackHand.texture = ResourceLoader.load(file_name_sprite_ogurec("Hands/BackHand", hands_weapon_type))
	$Legs.texture = ResourceLoader.load(file_name_sprite_ogurec("Legs", legs_type))
	
	
	#region MATCH_STATE
	#Как должен выглядеть спрайт при различных состояниях персонажа - (легаси, потом исправлю)
	match state:
		"Move":
			$Body1.flip_h = (direction() < 0)
			$FrontHand.flip_h = (direction() < 0)
			$BackHand.flip_h = (direction() < 0)
			$Legs.flip_h = (direction() < 0)
	
			
		"Attack_in_move":
			$Body1.flip_h = (attack_direction < 0)
			$FrontHand.flip_h = (attack_direction < 0)
			$BackHand.flip_h = (attack_direction < 0)
			$Legs.flip_h = (attack_direction < 0)
		"Attack":
			$Body1.flip_h = (attack_direction < 0)
			$FrontHand.flip_h = (attack_direction < 0)
			$BackHand.flip_h = (attack_direction < 0)
			$Legs.flip_h = (attack_direction < 0)
	
	#endregion
	
	#region STUPID_ANIMATIONS
	
		#анимация рук, когда персонаж стоит
	if state == "Stop":
		if timer % 40 == 20 + randi()%10:
			$FrontHand.frame = 1
			$BackHand.frame = 1
		if timer % 60 == 0:
			$FrontHand.frame = 0
			$BackHand.frame = 0
	
	
	
	
	
	
	#анимация тыщ-тыщ
	if time_to_end_attack > 0:
		if state == "Attack" or state == "Attack_in_move":
			$FrontHand.frame = (time_to_end_attack/4) % (attack_frames * 2)
			$BackHand.frame = (time_to_end_attack/4) % (attack_frames * 2)
		time_to_end_attack -= 60 * delta
	
	#endregion
	
	
	if (Input.is_action_just_pressed("Click") and state != "Stop" and time_to_end_attack == 0):
		attack_direction = direction()
		time_to_end_attack = time_for_attack
		
	#if (Input.is_action_just_pressed("Click") and state == "Stop":
		
	
	
	
	
	
	
	
	

	
	
	
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
	
	
	if Input.is_action_just_pressed("Jump") && is_on_floor():
		jump -= 1
		velocity.y = jump_force * 0.8
		jump_end = false
		$Timer.start()
	
	
	if Input.is_action_just_released("Jump"):
		jump_end = true
	
	
	
	velocity.x = direction() * speed
	if jump_end:
		velocity.y += 980 * delta
	move_and_slide()
	

func _on_timer_timeout():
	jump_end = true




func _on_attack_area_entered(area):
	if area.get_parent().has_method("get_damage"):
		area.get_parent().get_damage(position - area.position - Vector2(0, 100), damage)
	pass # Replace with function body.





