class_name Common_Enemy extends CharacterBody2D
#это файл класса обычных врагов. Все обычные враги пользуются этим скриптом, а после могут обрастать новыми функциями, менять значения переменных и т.д

#эти переменные нужны для того, чтобы создать скелет нашего врага. он прост
var texture = Sprite2D.new() #Спрайт нашего врага
var CollisionBox = CollisionShape2D.new() #Область для столкновений с объектами
var HurtBox_Area = Area2D.new() #Область, в которой находится хитбокс
var DamageBox = CollisionShape2D.new() #Сам хитбокс


var CollisionBox_Scale = Vector2(0, 0) #Размер области столкновений
var HurtBox_Scale = Vector2(0, 0) #Размер хитбокса

var texture_path = "" #Путь для подгрузки спрайта врага

#Эти переменные - игровые, они отвечают за игровой процесс
const IMMUNE_FRAMES = 60 #Кадры неуязвимости после получения урона
var hp = 5 #Здоровье врага в данный момент
var immune_left := 0 #Переменная-таймер, потом переделаю в норм таймер !НЕРЕАЛИЗОВАННАЯ ФУНКЦИЯ!
var knockback_multiplier := 150 #Множитель отбрасывания этого врага после удара по нему
var can_be_damaged := true #Может ли этот враг получать урон
var damage_resistance := 0 #Сколько процентов этот враг игнорирует от входящего урона
var contact_damage := 1 #Контактный урон врага !НЕРЕАЛИЗОВАННАЯ ФУНКЦИЯ!
var no_gravity = true #Подвержен ли этот враг гравитации, если да, то false
var falling_speed = 10 #Скорость падения этого врага, применяется, если no_gravity == false
var speed = 100 #Если враг имеет примитивный тип поведения типа преследования, то эта переменная отвечает за его скорость во время преследования

#Эта функция вызывается как только появляется враг и в конкретных врагах устанавливает конкретные значения переменных
func set_variables():
	pass

#Эта функция создаёт для врага простейшие узлы - соответственно спрайт, коллизию и хитбокс
func create_sceleton():
	texture.texture = ResourceLoader.load(texture_path)
	
	CollisionBox.shape = RectangleShape2D.new()
	CollisionBox.shape.size = CollisionBox_Scale
	
	DamageBox.shape = RectangleShape2D.new()
	DamageBox.shape.size = HurtBox_Scale
	
	add_child(texture)
	add_child(CollisionBox)
	HurtBox_Area.add_child(DamageBox)
	add_child(HurtBox_Area)

func _ready():
	set_variables()
	create_sceleton()
	pass

#функция получения урона лол, что тут непонятного
func get_damage(direction, damage):
		if immune_left == 0:
			velocity -= direction
			hp -= damage * (1 - damage_resistance/100)
			immune_left = IMMUNE_FRAMES


#Поведение врага
func AI():
	if hp == 0:
		queue_free()
	else:
		velocity.x = ((int(PlayerInfo.player_position.x - position.x > 0) * 2) - 1) * speed
		position.y -= 0.2 - ((PlayerInfo.player_position.y - position.y + 25) * 0.0001) * speed
	if immune_left > 0:
		immune_left -= 1
	move_and_slide()


#Функция влияния гравитации на врага
func gravity_influence():
	if !no_gravity:
		if !is_on_floor():
			velocity.y += falling_speed
	


func _process(delta):
	AI()
	gravity_influence()
	pass




 
