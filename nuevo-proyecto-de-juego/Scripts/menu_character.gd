class_name MenuCharacter
extends GridContainer

signal button_pressed(index: int)

var button_actions: Dictionary = {}
var button_descriptions: Dictionary = {}

# Rutas de los assets
const MENU_PATH = "res://Assets/AssetsMenu/"

# Números y colores disponibles
const NUMBERS = [1, 2, 3, 4, 5, 6]

# Array de botones detectados automáticamente
var buttons: Array = []

# Variables para almacenar la configuración actual de cada botón
var current_numbers: Array = [3, 2, 1, 1, 2, 3]
var current_colors: Array = ["Rojo", "Rojo", "Rojo", "Rojo", "Rojo", "Rojo"]

# Configuración visual
@export var button_scale: float = 1.0

# OFFSETS INDIVIDUALES para cada dirección
@export var offset_x_left: float = 17   # Desplazamiento en X para la izquierda
@export var offset_x_right: float = 17  # Desplazamiento en X para la derecha
@export var offset_y_up: float = 17     # Desplazamiento en Y para arriba
@export var offset_y_down: float = 17   # Desplazamiento en Y para abajo

func _ready() -> void:
	print("=== INICIALIZANDO MENUCHARACTER ===")
	
	# Detectar automáticamente los botones hijos
	_detect_buttons()
	
	if buttons.size() == 0:
		push_error("MenuCharacter: No se encontraron botones hijos.")
		return
	
	print("Se encontraron %d botones" % buttons.size())
	
	# Configurar los botones
	_setup_existing_sprites()
	
	# Cargar las texturas iniciales
	load_all_textures()
	
	print("=== MENUCHARACTER INICIALIZADO ===")
	for i in range(buttons.size()):
		button_actions[i] = Callable()
		button_descriptions[i] = ""

func _detect_buttons():
	# Buscar todos los TextureButton que sean hijos directos
	for child in get_children():
		if child is TextureButton:
			buttons.append(child)
			print("Botón detectado: ", child.name)

func _setup_existing_sprites():
	# Para cada botón, buscar sus hijos Sprite2D
	for i in range(buttons.size()):
		var button = buttons[i]
		var color_sprite: Sprite2D = null
		var number_sprite: Sprite2D = null
		
		# Buscar sprites hijos
		for child in button.get_children():
			if child is Sprite2D:
				if "Color" in child.name:
					color_sprite = child
				elif "Number" in child.name or "Numero" in child.name:
					number_sprite = child
		
		# Si no se encontraron, crearlos
		if not color_sprite:
			color_sprite = Sprite2D.new()
			color_sprite.name = "ColorSprite_%d" % (i + 1)
			color_sprite.z_index = 0  # Capa inferior (color)
			button.add_child(color_sprite)
			print("Creado ColorSprite para botón %d" % (i + 1))
		
		if not number_sprite:
			number_sprite = Sprite2D.new()
			number_sprite.name = "NumberSprite_%d" % (i + 1)
			number_sprite.z_index = 1  # Capa superior (número)
			button.add_child(number_sprite)
			print("Creado NumberSprite para botón %d" % (i + 1))
		
		# Configurar escala
		color_sprite.scale = Vector2(button_scale, button_scale)
		number_sprite.scale = Vector2(button_scale, button_scale)
		
		# APLICAR OFFSETS SEGÚN LA POSICIÓN DEL BOTÓN
		var offset = _get_offset_for_button(i)
		color_sprite.position = offset
		number_sprite.position = offset
		
		# Configurar el botón para que sea transparente
		button.texture_normal = null
		button.texture_pressed = null
		button.texture_hover = null
		button.texture_disabled = null
		
		# Conectar señal
		var callable = _on_button_pressed.bind(i)

		if not button.pressed.is_connected(callable):
			button.pressed.connect(callable)
	
func _get_offset_for_button(index: int) -> Vector2:
	# Determinar la posición del botón en la cuadrícula
	var cols = columns if columns > 0 else 3  # Si columns es 0, usar 3 por defecto
	var row = index / cols
	var col = index % cols
	
	# Calcular offsets basados en la posición
	var offset_x: float = 0
	var offset_y: float = 0
	
	# Offset en X: izquierda o derecha
	if col == 0:
		# Primera columna (izquierda)
		offset_x = offset_x_left
	elif col == cols - 1:
		# Última columna (derecha)
		offset_x = offset_x_right
	else:
		# Columnas del medio (promedio)
		offset_x = (offset_x_left + offset_x_right) / 2
	
	# Offset en Y: arriba o abajo
	var total_rows = ceil(buttons.size() / float(cols))
	if row == 0:
		# Primera fila (arriba)
		offset_y = offset_y_up
	elif row == total_rows - 1:
		# Última fila (abajo)
		offset_y = offset_y_down
	else:
		# Filas del medio (promedio)
		offset_y = (offset_y_up + offset_y_down) / 2
	
	return Vector2(offset_x, offset_y)

func load_all_textures():

	for i in range(buttons.size()):
		set_button_combination(
			i,
			current_numbers[i]
		)
func set_button_combination(index: int, number: int):
	if index < 0 or index >= buttons.size():
		return
	
	var button = buttons[index]
	var color_sprite: Sprite2D = null
	var number_sprite: Sprite2D = null
	
	# Buscar sprites hijos
	for child in button.get_children():
		if child is Sprite2D:
			if "Color" in child.name:
				color_sprite = child
			elif "Number" in child.name or "Numero" in child.name:
				number_sprite = child
	
	if not color_sprite or not number_sprite:
		return
	
	# Guardar valores
	if index < current_numbers.size():
		current_numbers[index] = number
	
	# Cargar texturas con los nombres CORRECTOS
	# Números: "1 Menu.png", "2 Menu.png", etc.
	var number_texture_path = "%s%dMenu.png" % [MENU_PATH, number]
	# Colores: "MenuRojo.png", "MenuAzul.png", etc.
	var color_texture_path = "%sMenu%s.png" % [MENU_PATH]
	
	# Cargar número
	if ResourceLoader.exists(number_texture_path):
		var texture = load(number_texture_path)
		if texture:
			number_sprite.texture = texture
			number_sprite.visible = true
			print("✓ %dMenu.png cargado para botón %d" % [number, index + 1])
		else:
			number_sprite.visible = false
			push_error("✗ Error al cargar textura: ", number_texture_path)
	else:
		number_sprite.visible = false
		push_error("✗ No existe archivo: ", number_texture_path)
	
	# Cargar color
	if ResourceLoader.exists(color_texture_path):
		var texture = load(color_texture_path)
		if texture:
			color_sprite.texture = texture
			color_sprite.visible = true
			print("✓ Menu%s.png cargado para botón %d" % [index + 1])
		else:
			color_sprite.visible = false
			push_error("✗ Error al cargar textura: ", color_texture_path)
	else:
		color_sprite.visible = false
		push_error("✗ No existe archivo: ", color_texture_path)

# Función para actualizar offsets después de cambiar valores
func update_offsets():
	for i in range(buttons.size()):
		var button = buttons[i]
		var color_sprite: Sprite2D = null
		var number_sprite: Sprite2D = null
		
		for child in button.get_children():
			if child is Sprite2D:
				if "Color" in child.name:
					color_sprite = child
				elif "Number" in child.name or "Numero" in child.name:
					number_sprite = child
		
		if color_sprite and number_sprite:
			var offset = _get_offset_for_button(i)
			color_sprite.position = offset
			number_sprite.position = offset

# Función para randomizar todos los botones
func randomize_all_buttons():
	print("=== RANDOMIZANDO TODOS LOS BOTONES ===")
	
	for i in range(buttons.size()):
		var random_number = NUMBERS[randi() % NUMBERS.size()]
		set_button_combination(i, random_number)
	print("Todos los botones randomizados")

# Función para randomizar un botón específico
func randomize_button(index: int):
	if index < 0 or index >= buttons.size():
		return
	
	var random_number = NUMBERS[randi() % NUMBERS.size()]
	set_button_combination(index, random_number)
	print("Botón %d randomizado" % (index + 1))

# Función para obtener la combinación de un botón
func get_button_combination(index: int) -> Dictionary:
	if index < 0 or index >= buttons.size():
		return {}
	return {
		"number": current_numbers[index],
		"description": button_descriptions[index]
	}

# Función para obtener todas las combinaciones
func get_all_combinations() -> Array:
	var result = []
	for i in range(buttons.size()):
		result.append(get_button_combination(i))
	return result

func _on_button_pressed(index: int):

	print("=== BOTÓN %d PRESIONADO ===" % (index + 1))

	button_pressed.emit(index)

	if button_actions.has(index):
		var action: Callable = button_actions[index]

		if action.is_valid():
			action.call()

func set_button_action(index:int, action:Callable):

	if index < 0 or index >= buttons.size():
		return

	button_actions[index] = action


func clear_button_action(index:int):

	if button_actions.has(index):
		button_actions[index] = Callable()


func configure_button(
	index:int,
	number:int,
	color:String,
	action:Callable = Callable()
):

	set_button_combination(index, number)

	if action.is_valid():
		set_button_action(index, action)


func set_button_description(index:int, description:String):

	button_descriptions[index] = description


func get_button_description(index:int)->String:

	if button_descriptions.has(index):
		return button_descriptions[index]

	return ""
	
func get_button(index:int) -> TextureButton:

	if index < 0 or index >= buttons.size():
		return null

	return buttons[index]

func clear_all_actions():

	for i in range(buttons.size()):
		button_actions[i] = Callable()
