extends Node

var volume = -15
var language = "Russian"
var background = "wooden"
var TIME = [0, 0]
var choosen_save:int = 0


func _process(delta):
	if choosen_save != 0:
		TIME[choosen_save - 1] += delta
	print (TIME)
	
	
	#region SCREEN_PARAMETERS
	#Режимы: полноэкранныйй, оконный
	if Input.is_action_just_pressed("FullScreen"):
		if (DisplayServer.window_get_mode() != 3):
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	#endregion

