class_name MainCharacterView
extends Node2D

const NUMBERS_PATH = "res://Assets/AssetsMainCharacter/"
const COLORS_PATH = "res://Assets/AssetsMainCharacter/"
const CONTOUR_PATH = "res://Assets/AssetsMainCharacter/SpriteMainCharacterContorno.png"

enum Direction {
	DERECHA,
	IZQUIERDA,
	ARRIBA
}

const DIRECTION_NAMES = {
	Direction.DERECHA: "Derecha",
	Direction.IZQUIERDA: "Izquierda",
	Direction.ARRIBA: "Arriba"
}

const NUMBERS = [1,2,3,4,5,6]
const COLORS = ["Rojo","Azul","Verde","Incoloro"]

@onready var number_sprite_arriba:Sprite2D = %NumberSpriteArriba
@onready var color_sprite_arriba:Sprite2D = %ColorSpriteArriba

@onready var number_sprite_derecha:Sprite2D = %NumberSpriteDerecha
@onready var color_sprite_derecha:Sprite2D = %ColorSpriteDerecha

@onready var number_sprite_izquierda:Sprite2D = %NumberSpriteIzquierda
@onready var color_sprite_izquierda:Sprite2D = %ColorSpriteIzquierda

@onready var contour_sprite:AnimatedSprite2D = %ContourSprite

@export var offset_arriba := Vector2(0,-11)
@export var offset_derecha := Vector2(8,0)
@export var offset_izquierda := Vector2(-7,0)
@export var offset_contorno := Vector2(0,-4)

@export var character_scale := 1.0

var current_numbers = {
	Direction.ARRIBA:1,
	Direction.DERECHA:1,
	Direction.IZQUIERDA:1
}

var current_colors = {
	Direction.ARRIBA:"Rojo",
	Direction.DERECHA:"Rojo",
	Direction.IZQUIERDA:"Rojo"
}

func _ready():
	print("🔵 MainCharacterView _ready() llamado")
	print("📍 Global position:", global_position)
	print("👁 Visible:", visible)

	_setup_zindex()
	_position_faces()
	_load_contour()
	randomize_character()

	print("🟢 MainCharacterView inicializado completamente")


func _setup_zindex():
	print("🔧 Configurando Z Index")

	color_sprite_arriba.z_index = 0
	color_sprite_derecha.z_index = 0
	color_sprite_izquierda.z_index = 0

	number_sprite_arriba.z_index = 1
	number_sprite_derecha.z_index = 1
	number_sprite_izquierda.z_index = 1

	contour_sprite.z_index = 2

	print("Z-index color=0, number=1, contour=2")


func _position_faces():
	print("📐 Posicionando sprites")

	var scale = Vector2.ONE * character_scale

	number_sprite_arriba.scale = scale
	color_sprite_arriba.scale = scale

	number_sprite_derecha.scale = scale
	color_sprite_derecha.scale = scale

	number_sprite_izquierda.scale = scale
	color_sprite_izquierda.scale = scale

	contour_sprite.scale = scale

	print("Scale aplicado:", scale)

	number_sprite_arriba.position = offset_arriba
	color_sprite_arriba.position = offset_arriba

	number_sprite_derecha.position = offset_derecha
	color_sprite_derecha.position = offset_derecha

	number_sprite_izquierda.position = offset_izquierda
	color_sprite_izquierda.position = offset_izquierda

	contour_sprite.position = offset_contorno

	print("Offsets aplicados:",
		offset_arriba,
		offset_derecha,
		offset_izquierda,
		offset_contorno
	)


func _load_contour():
	print("🖼 Cargando contorno...")

	if ResourceLoader.exists(CONTOUR_PATH):
		contour_sprite.play("default")

		print("✅ Contorno cargado como animación")
	else:
		print("❌ No existe textura contorno:", CONTOUR_PATH)

func randomize_character():
	print("🎲 Randomizando personaje")

	for dir in Direction.values():
		set_face(
			dir,
			NUMBERS.pick_random(),
			COLORS.pick_random()
		)

	print("🎲 Randomización completada")


func set_face(direction:Direction, number:int, color:String):

	print("🎯 set_face()",
		DIRECTION_NAMES[direction],
		"number:", number,
		"color:", color
	)

	current_numbers[direction] = number
	current_colors[direction] = color

	var number_sprite = _get_number_sprite(direction)
	var color_sprite = _get_color_sprite(direction)

	if number_sprite == null or color_sprite == null:
		print("❌ ERROR: Sprite null para dirección:", direction)
		return

	var number_path = "%s%d%s.png" % [
		NUMBERS_PATH,
		number,
		DIRECTION_NAMES[direction]
	]

	var color_path = "%s%s%s.png" % [
		COLORS_PATH,
		color,
		DIRECTION_NAMES[direction]
	]

	print("📂 number_path:", number_path)
	print("📂 color_path:", color_path)

	if ResourceLoader.exists(number_path):
		number_sprite.texture = load(number_path)
		print("✅ Número cargado")
	else:
		print("❌ No existe número:", number_path)

	if ResourceLoader.exists(color_path):
		color_sprite.texture = load(color_path)
		print("✅ Color cargado")
	else:
		print("❌ No existe color:", color_path)


func _get_number_sprite(direction):
	match direction:
		Direction.ARRIBA:
			return number_sprite_arriba
		Direction.DERECHA:
			return number_sprite_derecha
		Direction.IZQUIERDA:
			return number_sprite_izquierda
	return null


func _get_color_sprite(direction):
	match direction:
		Direction.ARRIBA:
			return color_sprite_arriba
		Direction.DERECHA:
			return color_sprite_derecha
		Direction.IZQUIERDA:
			return color_sprite_izquierda
	return null


func get_face(direction:Direction)->Dictionary:
	return {
		"number": current_numbers[direction],
		"color": current_colors[direction]
	}
