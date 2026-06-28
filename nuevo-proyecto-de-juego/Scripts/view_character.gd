class_name MainCharacterView
extends Node2D

signal request_update_ui

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

@export var character_model: MainCharacter

@export var offset_arriba := Vector2(0,-11)
@export var offset_derecha := Vector2(8,0)
@export var offset_izquierda := Vector2(-7,0)
@export var offset_contorno := Vector2(0,-4)

@export var character_scale := 1.0


func _ready():
	_setup_zindex()
	_position_faces()
	_load_contour()

	initialize_character()

# ---------------- CARAS ----------------

func initialize_character():
	set_face(Direction.ARRIBA, 3, "Rojo")
	set_face(Direction.DERECHA, 2, "Verde")
	set_face(Direction.IZQUIERDA, 1, "Incoloro")


func set_face(direction:Direction, number:int, color:String):

	var number_sprite = _get_number_sprite(direction)
	var color_sprite = _get_color_sprite(direction)

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

	if ResourceLoader.exists(number_path):
		number_sprite.texture = load(number_path)

	if ResourceLoader.exists(color_path):
		color_sprite.texture = load(color_path)


# ---------------- HELPERS ----------------

func _get_number_sprite(direction):
	match direction:
		Direction.ARRIBA: return number_sprite_arriba
		Direction.DERECHA: return number_sprite_derecha
		Direction.IZQUIERDA: return number_sprite_izquierda

func _get_color_sprite(direction):
	match direction:
		Direction.ARRIBA: return color_sprite_arriba
		Direction.DERECHA: return color_sprite_derecha
		Direction.IZQUIERDA: return color_sprite_izquierda


# ---------------- SETUP ----------------

func _setup_zindex():
	number_sprite_arriba.z_index = 1
	number_sprite_derecha.z_index = 1
	number_sprite_izquierda.z_index = 1

	color_sprite_arriba.z_index = 0
	color_sprite_derecha.z_index = 0
	color_sprite_izquierda.z_index = 0

	contour_sprite.z_index = 2


func _position_faces():
	var scale = Vector2.ONE * character_scale

	number_sprite_arriba.scale = scale
	number_sprite_derecha.scale = scale
	number_sprite_izquierda.scale = scale

	color_sprite_arriba.scale = scale
	color_sprite_derecha.scale = scale
	color_sprite_izquierda.scale = scale

	contour_sprite.scale = scale

	number_sprite_arriba.position = offset_arriba
	color_sprite_arriba.position = offset_arriba

	number_sprite_derecha.position = offset_derecha
	color_sprite_derecha.position = offset_derecha

	number_sprite_izquierda.position = offset_izquierda
	color_sprite_izquierda.position = offset_izquierda

	contour_sprite.position = offset_contorno


func _load_contour():
	if ResourceLoader.exists(CONTOUR_PATH):
		contour_sprite.play("default")
