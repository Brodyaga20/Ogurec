extends Node2D
var speed = 1.3
var min_camera_working_distance = 10
var camera_acceleration_distance = 60
var max_camera_speed = 2
var camera_acceleration = 0.005
var min_camera_speed = 1.3
var shadow_reduction = 1
var timer = 0
var time_speed = 0.1

func _ready():
	$ParallaxBackground/Camera2D.position.x = PlayerInfo.player_position.x


func _process(delta):
	timer += PI * delta/10 * time_speed
	if timer >= PI * 2:
		timer = 0
	if abs($ParallaxBackground/Camera2D.position.x - PlayerInfo.player_position.x) >= min_camera_working_distance:
		
		if $ParallaxBackground/Camera2D.position.x - PlayerInfo.player_position.x > 0:
			$ParallaxBackground/Camera2D.position.x -= speed
			
		
			if $ParallaxBackground/Camera2D.position.x - PlayerInfo.player_position.x > camera_acceleration_distance:
				if speed < max_camera_speed:
					speed += camera_acceleration
			else:
				if speed > min_camera_speed:
					speed -= camera_acceleration * 2
		
		if $ParallaxBackground/Camera2D.position.x - PlayerInfo.player_position.x < 0:
			$ParallaxBackground/Camera2D.position.x += speed
			
			if $ParallaxBackground/Camera2D.position.x - PlayerInfo.player_position.x < -camera_acceleration_distance:
				if speed < max_camera_speed:
					speed += camera_acceleration
			else:
				if speed > min_camera_speed:
					speed -= camera_acceleration * 2
					
	if Input.is_action_just_pressed("Return"):
		get_tree().change_scene_to_file("res://Scenes/menu.tscn")
		GlobalSettings.choosen_save = 0
	
	if sin(timer) > 0:
		shadow_reduction = abs(sin(timer + PI/2))
		
		$ParallaxBackground/Sky/Sun.frame = 0
		if timer > PI/2:
			%Darkness.color.a += delta/4
	else:
		$ParallaxBackground/Sky/Sun.frame = 1
		if timer > 3 * PI/2:
			%Darkness.color.a -= delta/4
		
	$ParallaxBackground/BackGround/Shadows2.scale.y = shadow_reduction
	$ParallaxBackground/BackGround/Shadows2.position.y = 200 + 25 * shadow_reduction
	
	$ParallaxBackground/Sky/Sun.position.y -= delta * 60 * time_speed
	if $ParallaxBackground/Sky/Sun.position.y <= -100:
		$ParallaxBackground/Sky/Sun.position.y = 500
	
	
