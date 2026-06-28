class_name MainCharacter
extends Node2D

# Cambiado a la ruta exacta donde están tus caras
const NUMBERS_PATH = "res://Assets/AssetsMainCharacter/"
const COLORS_PATH = "res://Assets/AssetsMainCharacter/"
const CONTOUR_PATH = "res://assets/AssetsMainCharacter/SpriteMainCharacterContorno.png"

enum Direction {DERECHA, IZQUIERDA, ARRIBA}
const DIRECTION_NAMES = {
	Direction.DERECHA: "Derecha",
	Direction.IZQUIERDA: "Izquierda",
	Direction.ARRIBA: "Arriba"
}

# Números y colores disponibles
const NUMBERS = [1, 2, 3, 4, 5, 6]
const COLORS = ["Rojo", "Azul", "Verde", "Incoloro"]

# Referencias a los sprites hijos
@export var number_sprite_arriba: Sprite2D
@export var color_sprite_arriba: Sprite2D
@export var number_sprite_derecha: Sprite2D
@export var color_sprite_derecha: Sprite2D
@export var number_sprite_izquierda: Sprite2D
@export var color_sprite_izquierda: Sprite2D
@export var contour_sprite: Sprite2D

# Variables para almacenar la combinación actual
var current_numbers: Dictionary = {
	Direction.ARRIBA: 1,
	Direction.DERECHA: 1,
	Direction.IZQUIERDA: 1
}
var current_colors: Dictionary = {
	Direction.ARRIBA: "Rojo",
	Direction.DERECHA: "Rojo",
	Direction.IZQUIERDA: "Rojo"
}

# Configuración de offsets para cada cara
@export var offset_arriba: Vector2 = Vector2(0, -11)
@export var offset_derecha: Vector2 = Vector2(8, 0)
@export var offset_izquierda: Vector2 = Vector2(-7, 0)
@export var offset_contorno: Vector2 = Vector2(0, -4)
@export var character_scale: float = 1.0

enum ActionType { }

@export var lifepoints: int
@export var actions: Array = []

var action: ActionType

func _ready() -> void:
	print("=== INICIALIZANDO MAINCHARACTER ===")
	
	# Verificar que los sprites estén asignados
	if not _all_sprites_assigned():
		push_error("MainCharacter: Faltan sprites por asignar en el inspector")
		return
	
	# Configurar orden de capas
	_setup_z_index()
	
	# Posicionar las caras con offsets
	_position_faces()
	
	# Cargar contorno
	load_contour()
	
	# Generar primera combinación aleatoria
	randomize_character()
	
	print("=== MAINCHARACTER INICIALIZADO ===")

func _all_sprites_assigned() -> bool:
	var missing = []
	if not number_sprite_arriba: missing.append("number_sprite_arriba")
	if not color_sprite_arriba: missing.append("color_sprite_arriba")
	if not number_sprite_derecha: missing.append("number_sprite_derecha")
	if not color_sprite_derecha: missing.append("color_sprite_derecha")
	if not number_sprite_izquierda: missing.append("number_sprite_izquierda")
	if not color_sprite_izquierda: missing.append("color_sprite_izquierda")
	if not contour_sprite: missing.append("contour_sprite")
	
	if missing.size() > 0:
		print("ERROR: Sprites faltantes: ", missing)
		return false
	return true

func _setup_z_index():
	# COLORES en capa 0 (abajo)
	color_sprite_arriba.z_index = 0
	color_sprite_derecha.z_index = 0
	color_sprite_izquierda.z_index = 0
	
	# NÚMEROS en capa 1 (encima de los colores)
	number_sprite_arriba.z_index = 1
	number_sprite_derecha.z_index = 1
	number_sprite_izquierda.z_index = 1
	
	# CONTORNO en capa 2 (por encima de todo)
	contour_sprite.z_index = 2
	
	print("Z-Index configurado: Colores=0, Números=1, Contorno=2")

func _position_faces():
	# Escalar todos los sprites
	var scale = Vector2(character_scale, character_scale)
	number_sprite_arriba.scale = scale
	color_sprite_arriba.scale = scale
	number_sprite_derecha.scale = scale
	color_sprite_derecha.scale = scale
	number_sprite_izquierda.scale = scale
	color_sprite_izquierda.scale = scale
	contour_sprite.scale = scale
	
	# Aplicar offsets a cada cara
	# Cara ARRIBA - se mueve hacia arriba
	number_sprite_arriba.position = offset_arriba
	color_sprite_arriba.position = offset_arriba
	
	# Cara DERECHA - se mueve hacia la derecha
	number_sprite_derecha.position = offset_derecha
	color_sprite_derecha.position = offset_derecha
	
	# Cara IZQUIERDA - se mueve hacia la izquierda
	number_sprite_izquierda.position = offset_izquierda
	color_sprite_izquierda.position = offset_izquierda
	
	# Contorno en el centro (o donde se especifique)
	contour_sprite.position = offset_contorno
	
	print("Caras posicionadas con offsets:")
	print("  ARRIBA: ", offset_arriba)
	print("  DERECHA: ", offset_derecha)
	print("  IZQUIERDA: ", offset_izquierda)
	print("  CONTORNO: ", offset_contorno)

func load_contour():
	print("=== CARGANDO CONTORNO ===")
	if ResourceLoader.exists(CONTOUR_PATH):
		var texture = load(CONTOUR_PATH)
		if texture:
			contour_sprite.texture = texture
			print("Contorno cargado correctamente. Tamaño: ", texture.get_size())
			contour_sprite.visible = true
		else:
			push_error("No se pudo cargar la textura del contorno")
	else:
		push_error("No existe el archivo: ", CONTOUR_PATH)

func generate_random_combination():
	print("=== GENERANDO COMBINACIÓN ALEATORIA ===")
	for direction in Direction.values():
		var random_number = NUMBERS[randi() % NUMBERS.size()]
		var random_color = COLORS[randi() % COLORS.size()]
		set_face_combination(direction, random_number, random_color)
	print("Personaje generado completamente")

func set_face_combination(direction: Direction, number: int, color: String):
	# Guardar valores
	current_numbers[direction] = number
	current_colors[direction] = color
	
	# Obtener los sprites correspondientes
	var number_sprite = _get_number_sprite(direction)
	var color_sprite = _get_color_sprite(direction)
	
	if not number_sprite or not color_sprite:
		push_error("Sprite no encontrado para dirección: ", DIRECTION_NAMES[direction])
		return
	
	# Cargar textura del número
	var number_texture_path = "%s%d%s.png" % [NUMBERS_PATH, number, DIRECTION_NAMES[direction]]
	if ResourceLoader.exists(number_texture_path):
		var texture = load(number_texture_path)
		if texture:
			number_sprite.texture = texture
			number_sprite.visible = true
			print("✓ Número cargado: ", number_texture_path)
		else:
			push_error("✗ Error al cargar textura: ", number_texture_path)
			number_sprite.visible = false
	else:
		push_error("✗ No existe archivo: ", number_texture_path)
		number_sprite.visible = false
	
	# Cargar textura del color
	var color_texture_path = "%s%s%s.png" % [COLORS_PATH, color, DIRECTION_NAMES[direction]]
	if ResourceLoader.exists(color_texture_path):
		var texture = load(color_texture_path)
		if texture:
			color_sprite.texture = texture
			color_sprite.visible = true
			print("✓ Color cargado: ", color_texture_path)
		else:
			push_error("✗ Error al cargar textura: ", color_texture_path)
			color_sprite.visible = false
	else:
		push_error("✗ No existe archivo: ", color_texture_path)
		color_sprite.visible = false

func _get_number_sprite(direction: Direction) -> Sprite2D:
	match direction:
		Direction.ARRIBA:
			return number_sprite_arriba
		Direction.DERECHA:
			return number_sprite_derecha
		Direction.IZQUIERDA:
			return number_sprite_izquierda
	return null

func _get_color_sprite(direction: Direction) -> Sprite2D:
	match direction:
		Direction.ARRIBA:
			return color_sprite_arriba
		Direction.DERECHA:
			return color_sprite_derecha
		Direction.IZQUIERDA:
			return color_sprite_izquierda
	return null

func randomize_character():
	generate_random_combination()

# Funciones para cambiar caras individualmente
func set_arriba(number: int = -1, color: String = ""):
	if number == -1:
		number = NUMBERS[randi() % NUMBERS.size()]
	if color == "":
		color = COLORS[randi() % COLORS.size()]
	set_face_combination(Direction.ARRIBA, number, color)

func set_derecha(number: int = -1, color: String = ""):
	if number == -1:
		number = NUMBERS[randi() % NUMBERS.size()]
	if color == "":
		color = COLORS[randi() % COLORS.size()]
	set_face_combination(Direction.DERECHA, number, color)

func set_izquierda(number: int = -1, color: String = ""):
	if number == -1:
		number = NUMBERS[randi() % NUMBERS.size()]
	if color == "":
		color = COLORS[randi() % COLORS.size()]
	set_face_combination(Direction.IZQUIERDA, number, color)

func get_face_combination(direction: Direction) -> Dictionary:
	return {
		"number": current_numbers[direction],
		"color": current_colors[direction],
		"direction": DIRECTION_NAMES[direction]
	}

func get_all_combinations() -> Dictionary:
	return {
		"arriba": get_face_combination(Direction.ARRIBA),
		"derecha": get_face_combination(Direction.DERECHA),
		"izquierda": get_face_combination(Direction.IZQUIERDA)
	}

# Funciones para ajustar offsets individualmente
func set_offset_arriba(offset: Vector2):
	offset_arriba = offset
	_position_faces()

func set_offset_derecha(offset: Vector2):
	offset_derecha = offset
	_position_faces()

func set_offset_izquierda(offset: Vector2):
	offset_izquierda = offset
	_position_faces()

func set_offset_contorno(offset: Vector2):
	offset_contorno = offset
	_position_faces()

func set_character_scale(scale: float):
	character_scale = scale
	_position_faces()

func decidir_accion() -> void:
	pass

func ejecutar_accion():
	pass

# Depuración con teclas
func _process(delta):
	if Input.is_key_pressed(KEY_R):
		randomize_character()
		print("Personaje regenerado: ", get_all_combinations())
	
	if Input.is_key_pressed(KEY_F1):
		debug_print_all()
	
	if Input.is_key_pressed(KEY_F2):
		load_contour()
	
	# Teclas para ajustar offsets en tiempo real
	if Input.is_key_pressed(KEY_UP):
		offset_arriba.y -= 5
		_position_faces()
		print("Offset ARRIBA: ", offset_arriba)
		await get_tree().create_timer(0.1).timeout
	
	if Input.is_key_pressed(KEY_DOWN):
		offset_arriba.y += 5
		_position_faces()
		print("Offset ARRIBA: ", offset_arriba)
		await get_tree().create_timer(0.1).timeout
	
	if Input.is_key_pressed(KEY_LEFT):
		offset_izquierda.x -= 5
		_position_faces()
		print("Offset IZQUIERDA: ", offset_izquierda)
		await get_tree().create_timer(0.1).timeout
	
	if Input.is_key_pressed(KEY_RIGHT):
		offset_derecha.x += 5
		_position_faces()
		print("Offset DERECHA: ", offset_derecha)
		await get_tree().create_timer(0.1).timeout

func debug_print_all():
	print("=== DEBUG COMPLETO ===")
	print("Escala: ", character_scale)
	print("Offsets:")
	print("  ARRIBA: ", offset_arriba)
	print("  DERECHA: ", offset_derecha)
	print("  IZQUIERDA: ", offset_izquierda)
	print("  CONTORNO: ", offset_contorno)
	print("Contorno visible: ", contour_sprite.visible)
	print("Contorno textura: ", contour_sprite.texture != null)
	if contour_sprite.texture:
		print("Tamaño contorno: ", contour_sprite.texture.get_size())
	
	for direction in Direction.values():
		print("--- ", DIRECTION_NAMES[direction], " ---")
		var num_sprite = _get_number_sprite(direction)
		var col_sprite = _get_color_sprite(direction)
		print("Número visible: ", num_sprite.visible)
		print("Número textura: ", num_sprite.texture != null)
		print("Número posición: ", num_sprite.position)
		if num_sprite.texture:
			print("Tamaño número: ", num_sprite.texture.get_size())
		print("Color visible: ", col_sprite.visible)
		print("Color textura: ", col_sprite.texture != null)
		print("Color posición: ", col_sprite.position)
		if col_sprite.texture:
			print("Tamaño color: ", col_sprite.texture.get_size())
		print("Número actual: ", current_numbers[direction])
		print("Color actual: ", current_colors[direction])
	print("=== FIN DEBUG ===")
