extends CharacterBody2D
const TEXTURE_PATH := "res://Resources/Textures/Characters/Playable/Ogurec/" #Часть пути для текстур, дополняется ниже, когда понадобится

var speed := 200 #Скорость персонажа
var timer := 0 #Хз, не помню уже
var state := "" #Состояние персонажа - идёт там он или стоит типа
var time_to_end_attack := 0 #Таймер до окончания анимации атаки и возможности начала следующей
var time_for_attack := 60 #Сколько времени тратится на цикл атаки с данным оружжием
var attack_direction := 0 #Направление атаки
var max_jump := 10 #Сколько максимум прыжков можно сделать, типа 2 - у персонажа есть двойной прыжок, 3 - тройной и т. д.
var jump := 0 #Сколько конкретно сейчас раз ещё может прыгнуть персонаж
var last_direction := 0 #В какую сторону последний раз был повёрнут персонаж при движении


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



func _process(delta):
	Global.player_position = position
	#на пока
	if Input.is_action_just_pressed("Return"):
		get_tree().quit()
		
	#прыжок восстанавливается, когда персонаж на полу
	if is_on_floor():
		jump = max_jump
		
	#определяем, в каком состоянии сейчас персонаж
	if (time_to_end_attack != 0):
		if (int(Input.is_action_pressed("Right")) - int(Input.is_action_pressed("Left"))) != 0:
			state = "Attack_in_move" # Если атака в движении отличается от атаки на месте, то это состояние поможет
		else:
			state = "Attack" # Просто атака
	else:
		if (int(Input.is_action_pressed("Right")) - int(Input.is_action_pressed("Left"))) != 0:
			state = "Move" # Персонаж движется ИЛИ ты нажимаешь кнопки движения, ДАЖЕ упираясь в стену
		else:
			state = "Stop" # Персонаж стоит
	
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
	timer += 1
	
	#анимация рук, когда персонаж стоит
	if state == "Stop":
		if timer % 40 == 20 + randi()%10:
			$Hands.frame = 1
		if timer % 60 == 0:
			$Hands.frame = 0
	
	
	#анимация ног, когда персонаж идёт
	if state != "Stop":
		if timer % 12 == 0:
			if $Legs.frame != 7:
				$Legs.frame += 1
			else:
				$Legs.frame = 0
	
	#Программа создаёт путь файла, основываясь на состоянии персонажа и типе конечностей и подгружает файл оттуда в текстуру, используя функцию, которая написана выше, на строке 22
	$Body1.texture = ResourceLoader.load(file_name_sprite_ogurec("Body", body_type))
	$Hands.texture = ResourceLoader.load(file_name_sprite_ogurec("Hands", hands_weapon_type))
	$Legs.texture = ResourceLoader.load(file_name_sprite_ogurec("Legs", legs_type))
	
	#Как должен выглядеть спрайт при различных состояниях персонажа - (легаси, потом исправлю)
	match state:
		"Move":
			$Legs.hframes = 4
			$Legs.vframes = 2
			$Hands.hframes = 2
			$Hands.vframes = 1
			$Hands.frame = 0
			$Body1.flip_h = ((int(Input.is_action_pressed("Right")) - int(Input.is_action_pressed("Left"))) < 0)
			$Hands.flip_h = ((int(Input.is_action_pressed("Right")) - int(Input.is_action_pressed("Left"))) < 0)
			$Legs.flip_h = ((int(Input.is_action_pressed("Right")) - int(Input.is_action_pressed("Left"))) < 0)
		"Stop":
			$Legs.hframes = 1
			$Legs.vframes = 1
			$Hands.hframes = 2
			$Hands.vframes = 1
			$Legs.frame = 0

			
		"Attack_in_move":
			$Hands.hframes = 2
			$Hands.vframes = 4
			$Body1.flip_h = (attack_direction < 0)
			$Hands.flip_h = (attack_direction < 0)
			$Legs.flip_h = (attack_direction < 0)
			$Legs.hframes = 4
			$Legs.vframes = 2
		"Attack":
			$Hands.hframes = 2
			$Hands.vframes = 4
			$Body1.flip_h = (attack_direction < 0)
			$Hands.flip_h = (attack_direction < 0)
			$Legs.flip_h = (attack_direction < 0)
			$Legs.hframes = 4
			$Legs.vframes = 2
			
	
	if time_to_end_attack > 0:
		if state == "Attack" or state == "Attack_in_move":
			$Hands.frame = (time_to_end_attack/4) % 8
		time_to_end_attack -= 1


	
	if (Input.is_action_just_pressed("Click") and state != "Stop" and time_to_end_attack == 0):
		attack_direction = (int(Input.is_action_pressed("Right")) - int(Input.is_action_pressed("Left")))
		time_to_end_attack = time_for_attack
		
	#if (Input.is_action_just_pressed("Click") and state == "Stop":
		
	
	
	
	if Input.is_action_just_pressed("Jump") && jump > 0:
		jump -= 1
		velocity.y = -450
	
	velocity.x = direction() * speed
	
	#if Input.is_action_pressed()
	

	if attack_direction > 0:
		if time_to_end_attack != 0:
			$Attack/RightHurtBox.position.y = 0
	else:
		if time_to_end_attack != 0:
			$Attack/LeftHurtBox.position.y = 0
	if time_to_end_attack == 0:
		$Attack/RightHurtBox.position.y = -400
		$Attack/LeftHurtBox.position.y = -400
	
	velocity.y += 980 * delta
	move_and_slide()




func _on_right_hurt_box_area_entered(area):
	print(area.name)
