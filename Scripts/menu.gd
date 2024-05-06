#Адекватным программистам не смотреть
extends Node2D
var button = "no" #На какой кнопке сейчас мышь
var page = "start" #На какой странице меню сейчас игра
var previous_page = page #Переменная для возвращения с настроек на предыдущую страницу
var audionode #Переменная 1 для настройки громкости - Нода AllAudio
var audiochildnode #Переменная 2 для настройки громкости - Сами ноды Аудио
var timer_to_show_settings = 0.0 #Переменная, отвечающая за время появления настроек
var alpha_settings = 1 #Прозрачность настроек
var settings_appearance_speed = 16 #Скорость появления настроек (Не увеличивать выше 20, потом исправлю мб)
var changevolume = 4 #Скорость изменения громкости
var minvolume = GlobalSettings.volume - changevolume * 4 #Децибелы при громкости 10 в игре
var maxvolume = GlobalSettings.volume + changevolume * 5 #Децибелы при громкости 1 в игре
var absolutezerovol = -80 #Децибелы при громкости 0 в игре
var background = "wood" #Фон сейчас
var returnbackground = false #Возвращается ли фон после прокрутки прямо сейчас
var tosound = 0
var timer_to_select = 1 #Таймер, в течение которого невозможно выбрать слот сохранения сразу после перехода на страницу выбора слотов
var scrolling = false #Воспроизводится ли прямо сейчас скролл мышкой 



func _ready():
	go_to_start_page()
	audionode = get_child(5)
	pass


func _process(delta):
	#Каждый 6 раз при кручении колёсика будет звук:
	if tosound == 6:
		tosound = 0
	#Таймер
	if timer_to_select > 0:
		timer_to_select -= 1
	#Возвращение (Esc) 
	if Input.is_action_just_pressed("Return"):
		if page == "save":
			go_to_start_page()
		elif page == "settings":
			hide_settings()
		elif page == "start":
			get_tree().quit()
		
	
	#Полноэкранный/Оконный режим (F11)
	if Input.is_action_pressed("FullScreen"):
		if (DisplayServer.window_get_mode() != 3):
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	
	#При возвращении на стартовую страницу возвращается фон на место
	if returnbackground:
		if $BackGround.position.y < 150:
			$BackGround.position.y += 10
			$StartPage.position.y = $BackGround.position.y - 150
			$SettingsButton.position.y = $BackGround.position.y - 270
			$SavePage/Buttons.position.y = -63
			$SavePage/Scroll.position.y = -14
			tosound += 1
			if tosound == 3:
				if background == "wood":
					$AllAudio/WoodCreak.playing = true
				else:
					$AllAudio/IronClang.playing = true
		else:
			returnbackground = false
			
	
		
	
	#Синхронизация громкости с глобальной громкостью
	for i in range(audionode.get_child_count()):
		audiochildnode = audionode.get_child(i)
		audiochildnode.volume_db = GlobalSettings.volume
		pass
	
	#Появление/Исчезание настроек
	if timer_to_show_settings > 1 && timer_to_show_settings != 20:
		alpha_settings = float(timer_to_show_settings)/255
		$MenuSettings/DarkBack.color = Color(0, 0, 0, 1 - alpha_settings)
		timer_to_show_settings -= settings_appearance_speed * delta * 60
	elif timer_to_show_settings <= 10 && page == "settings":
		$MenuSettings/InvisibleSettings.visible = true
		timer_to_show_settings = 20
	elif timer_to_show_settings <= -20 && page != "settings":
		alpha_settings = float(timer_to_show_settings)/255
		$MenuSettings/DarkBack.color = Color(0, 0, 0, -alpha_settings)
		timer_to_show_settings += settings_appearance_speed * delta * 60
		
	#ПРОКРУТКА МЫШЬЮ
	if scrolling:
		$SavePage/Scroll.position.y = get_viewport().get_mouse_position().y - 128
		$SavePage/Scroll.position.y = clamp($SavePage/Scroll.position.y, -14, 106)
		$BackGround.position.y = ($SavePage/Scroll.position.y + 14) * -2.5 + 150
		$SavePage/Buttons.position.y = $BackGround.position.y - 213
	if Input.is_action_just_released("Click"):
		scrolling = false
	
	#Левая кнопка мыши
	if Input.is_action_just_pressed("Click"):
		#кнопочки
		if page == "start":
			if button == "exit":
				get_tree().quit()
			elif button == "settings":
				show_settings()
			elif button == "play":
				go_to_save_page()
				
		#в настройках
		elif page == "settings":
			
			if button == "return":
				hide_settings()
				
			#настройки громкости
			if button == "minusvolume":
				if GlobalSettings.volume > minvolume:
					GlobalSettings.volume -= changevolume
					$MenuSettings/InvisibleSettings/Volume/Count.frame -= 1
					$AllAudio/ChangeVolume.playing = true
				elif GlobalSettings.volume == minvolume:
					GlobalSettings.volume = absolutezerovol
					$MenuSettings/InvisibleSettings/Volume/Count.frame -= 1
					$AllAudio/ChangeVolume.playing = true
					$MenuSettings/InvisibleSettings/Volume/Arrow/ArrowPlateLeft.frame = 0
			if button == "plusvolume":
				if GlobalSettings.volume == absolutezerovol:
					GlobalSettings.volume = minvolume
					$MenuSettings/InvisibleSettings/Volume/Count.frame += 1
					$AllAudio/ChangeVolume.playing = true
				elif GlobalSettings.volume < maxvolume - changevolume:
					GlobalSettings.volume += changevolume
					$MenuSettings/InvisibleSettings/Volume/Count.frame += 1
					$AllAudio/ChangeVolume.playing = true
				elif GlobalSettings.volume == maxvolume - changevolume:
					GlobalSettings.volume += changevolume
					$MenuSettings/InvisibleSettings/Volume/Count.frame += 1
					$AllAudio/ChangeVolume.playing = true
					$MenuSettings/InvisibleSettings/Volume/Arrow/ArrowPlateRight.frame = 0
				
			if button == "changeback":
				$AllAudio/ChangeVolume.playing = true
				if $BackGround.frame == 0:
					$BackGround.frame = 1
					$MenuSettings/InvisibleSettings/BackGround/BackGroundCount.frame = 1
					background = "steel"
				else:
					$BackGround.frame = 0
					$MenuSettings/InvisibleSettings/BackGround/BackGroundCount.frame = 0
					background = "wood"
		
		#сейв-пейдж
		elif page == "save":
			if button == "settings":
				show_settings()
				scrolling = false
			if button == "scroll" && !scrolling:
				scrolling = true


	#Туда-сюда на странице выбора сохранения
	if Input.is_action_just_pressed("WheelDown"):
		if page == "save":
			$BackGround.position.y -= 20
			$SavePage/Buttons.position.y -= 20
			$SavePage/Scroll.position.y += 8
			$BackGround.position.y = clamp($BackGround.position.y, -150, 150)
			$SavePage/Buttons.position.y = clamp($SavePage/Buttons.position.y, -363, -63)
			$SavePage/Scroll.position.y = clamp($SavePage/Scroll.position.y, -14, 106)
			tosound += 1
			if background == "wood":
				if tosound == 3:
					$AllAudio/WoodCreak.playing = true
			else:
				if tosound == 3:
					$AllAudio/IronClang.playing = true
		
	#Аналогично с колёсиком вверх
	if Input.is_action_just_pressed("WheelUp"):
		if page == "save":
			if page == "save":
				$BackGround.position.y += 20
				$SavePage/Buttons.position.y += 20
				$SavePage/Scroll.position.y -= 8
				$SavePage/Buttons.position.y = clamp($SavePage/Buttons.position.y, -363, -63)
				$SavePage/Scroll.position.y = clamp($SavePage/Scroll.position.y, -14, 106)
				$BackGround.position.y = clamp($BackGround.position.y, -150, 150)
				tosound += 1
				if background == "wood":
					if tosound == 3:
						$AllAudio/WoodCreak.playing = true
				else:
					if tosound == 3:
						$AllAudio/IronClang.playing = true
	
	
	#Кручение шестерёнки настроек
	if button == "settings":
		$SettingsButton/Sprite.rotation_degrees += 22.5
		$AllAudio/GearRotatingSound.playing = true
	else:
		$SettingsButton/Sprite.rotation_degrees = 0
		$AllAudio/GearRotatingSound.playing = false

#Переход между страницами
func show_settings():
	timer_to_show_settings = 235
	previous_page = page
	page = "settings"
	button = "no"
	$AllAudio/OpenSettings.playing = true
	pass

func hide_settings():
	timer_to_show_settings = -235
	page = previous_page
	$AllAudio/OpenSettings.playing = true
	$MenuSettings/InvisibleSettings.visible = false
	$MenuSettings/InvisibleSettings/ReturnButton/SpriteReturnButton.frame = 0
	pass

func go_to_save_page():
	timer_to_select += 1
	$StartPage.visible = false
	$SavePage.visible = true
	$SavePage/Buttons/PlayButton.frame = 0
	$SavePage/Buttons/PlayButton2.frame = 0
	page = "save"

func go_to_start_page():
	returnbackground = true
	$StartPage/Buttons/Play/SpritePlayButton.frame = 0
	$StartPage.visible = true
	$SavePage.visible = false
	$SavePage/ScrollBar.position.y = 0
	$SavePage/Scroll.position.y = -14
	page = "start"


#Buttons Area 
#Кнопки
func _on_play_button_light_area_mouse_entered():
	if page == "start":
		$StartPage/Buttons/Play/SpritePlayButton.frame = 1
		$AllAudio/PlayCreak.playing = true
		button = "play"

func _on_play_button_light_area_mouse_exited():
	if page == "start":
		$StartPage/Buttons/Play/SpritePlayButton.frame = 0
		$AllAudio/PlayCreak2.playing = true
		button = "no"


func _on_exit_button_light_area_mouse_entered():
	if page == "start":
		$StartPage/Buttons/Exit/SpriteExitButton.frame = 1
		$AllAudio/ExitCreak.playing = true
		button = "exit"
		print("yeah")
	
func _on_exit_button_light_area_mouse_exited():
	if page == "start":
		$StartPage/Buttons/Exit/SpriteExitButton.frame = 0
		$AllAudio/ExitCreak2.playing = true
		button = "no"


func _on_settings_button_rotate_area_mouse_entered():
	if page == "start" || page == "save":
		button = "settings"

func _on_settings_button_rotate_area_mouse_exited():
	if page == "start" || page == "save":
		button = "no"


func _on_return_button_light_area_mouse_entered():
	if page == "settings":
		$MenuSettings/InvisibleSettings/ReturnButton/SpriteReturnButton.frame = 1
		button = "return"

func _on_return_button_light_area_mouse_exited():
	if page == "settings":
		$MenuSettings/InvisibleSettings/ReturnButton/SpriteReturnButton.frame = 0
		button = "no"


func _on_arrow_plate_left_mouse_entered():
	if page == "settings" && GlobalSettings.volume != absolutezerovol:
		$MenuSettings/InvisibleSettings/Volume/Arrow/ArrowPlateLeft.frame = 1
		button = "minusvolume"

func _on_arrow_plate_left_mouse_exited():
	if page == "settings":
		$MenuSettings/InvisibleSettings/Volume/Arrow/ArrowPlateLeft.frame = 0
		button = "no"


func _on_arrow_plate_right_mouse_entered():
	if page == "settings" && GlobalSettings.volume != maxvolume:
		$MenuSettings/InvisibleSettings/Volume/Arrow/ArrowPlateRight.frame = 1
		button = "plusvolume"

func _on_arrow_plate_right_mouse_exited():
	if page == "settings":
		$MenuSettings/InvisibleSettings/Volume/Arrow/ArrowPlateRight.frame = 0
		button = "no"


func _on_arrow_back_ground_mouse_entered():
	if page == "settings":
		$MenuSettings/InvisibleSettings/BackGround/Arrow/ArrowPlateRight.frame = 1
		$MenuSettings/InvisibleSettings/BackGround/Arrow/ArrowPlateLeft.frame = 1
		button = "changeback"

func _on_arrow_back_ground_mouse_exited():
	if page == "settings":
		$MenuSettings/InvisibleSettings/	BackGround/Arrow/ArrowPlateRight.frame = 0
		$MenuSettings/InvisibleSettings/BackGround/Arrow/ArrowPlateLeft.frame = 0
		button = "no"


func _on_button_1_area_mouse_entered():
	if page == "save" && timer_to_select == 0:
		$SavePage/Buttons/PlayButton.frame = 1
		$AllAudio/ChooseNewGame.playing = true
		button = "game1"

func _on_button_1_area_mouse_exited():
	if page == "save":
		$SavePage/Buttons/PlayButton.frame = 0
		button = "no"


func _on_button_2_area_mouse_entered():
	if page == "save":
		$SavePage/Buttons/PlayButton2.frame = 1
		$AllAudio/ChooseNewGame.playing = true
		button = "game1"

func _on_button_2_area_mouse_exited():
	if page == "save":
		$SavePage/Buttons/PlayButton2.frame = 0
		button = "no"


func _on_scroll_area_button_mouse_entered():
	if page == "save":
		button = "scroll"

func _on_scroll_area_button_mouse_exited():
	if page == "save":
		button = "no"
