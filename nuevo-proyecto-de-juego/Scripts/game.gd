extends Node2D

# ==================== REFERENCIAS A NODOS ====================
@onready var main_character: MainCharacter = $MainCharacter
@onready var camera: Camera2D = $Camera2D
@onready var control: Control = $Camera2D/Control
@onready var action_grid: GridContainer = $Camera2D/Control/GridContainer

# ==================== VARIABLES DE NIVEL ====================
var level: int = 0
var current_enemies: Array = []
var enemy_index: int = -1  # Índice del enemigo seleccionado

# ==================== DEFINICIÓN DE NIVELES ====================
# Cada nivel tiene un nombre y una lista de enemigos
# Cada enemigo tiene: numero (1-6) y color (Rojo, Azul, Verde, Incoloro)
var niveles: Array = [
	{
		"nombre": "Nivel 1 - Inicio",
		"enemigos": [
			{"numero": 1, "color": "Rojo"},
			{"numero": 2, "color": "Azul"}
		]
	},
	{
		"nombre": "Nivel 2 - Desafío",
		"enemigos": [
			{"numero": 3, "color": "Verde"},
			{"numero": 4, "color": "Rojo"},
			{"numero": 1, "color": "Incoloro"},
			{"numero": 5, "color": "Azul"}
		]
	},
	{
		"nombre": "Nivel 3 - Duelo Final",
		"enemigos": [
			{"numero": 2, "color": "Incoloro"},
			{"numero": 6, "color": "Rojo"},
			{"numero": 3, "color": "Azul"},
			{"numero": 5, "color": "Verde"},
			{"numero": 1, "color": "Rojo"},
			{"numero": 4, "color": "Incoloro"}
		]
	}
]

# ==================== SEÑALES ====================
signal level_changed(new_level: int)
signal enemy_selected(enemy_data: Dictionary)

# ==================== INICIALIZACIÓN ====================
func _ready() -> void:
	print("=== SISTEMA DE JUEGO INICIALIZADO ===")
	
	# Conectar los botones de acciones del GridContainer
	_connect_action_buttons()
	
	# Conectar señales del MainCharacter si existen
	if main_character:
		print("MainCharacter encontrado")
		# Si MainCharacter tiene señal de cambio de nivel, conectar
		if main_character.has_signal("level_changed"):
			main_character.level_changed.connect(_on_main_character_level_changed)
	else:
		push_error("MainCharacter no encontrado")
	
	# Cargar el nivel inicial
	cargar_nivel(0)
	
	print("=== SISTEMA DE JUEGO LISTO ===")

func _connect_action_buttons() -> void:
	if not action_grid:
		push_error("ActionGrid no encontrado")
		return
	
	print("Conectando botones de acción...")
	
	# Buscar todos los TextureButton hijos del action_grid
	var button_index: int = 0
	for child in action_grid.get_children():
		if child is TextureButton:
			# Conectar la señal de cada botón
			child.pressed.connect(_on_action_button_pressed.bind(button_index))
			print("Botón de acción %d conectado: %s" % [button_index + 1, child.name])
			button_index += 1

# ==================== FUNCIONES DE NIVEL ====================
func cargar_nivel(index: int) -> void:
	if index < 0 or index >= niveles.size():
		push_error("Nivel %d no existe" % index)
		return
	
	level = index
	var nivel = niveles[index]
	current_enemies = nivel["enemigos"]
	enemy_index = -1
	
	print("=== CARGANDO %s ===" % nivel["nombre"])
	print("Enemigos en este nivel: ", current_enemies.size())
	for i in range(current_enemies.size()):
		var enemy = current_enemies[i]
		print("  Enemigo %d: Número=%d, Color=%s" % [i+1, enemy["numero"], enemy["color"]])
	
	# Actualizar el MainCharacter con los enemigos del nivel
	_actualizar_personaje_con_enemigos()
	
	# Emitir señal de cambio de nivel
	level_changed.emit(index)
	
	# Mostrar información en UI
	_actualizar_ui_nivel()

func _actualizar_personaje_con_enemigos() -> void:
	if not main_character:
		return
	
	# Si MainCharacter tiene función para actualizar enemigos, llamarla
	if main_character.has_method("set_enemies"):
		main_character.set_enemies(current_enemies)
	else:
		print("MainCharacter no tiene método 'set_enemies' - los enemigos solo están en Game")

func _actualizar_ui_nivel() -> void:
	if not control:
		return
	
	# Buscar un Label para mostrar el nivel
	var level_label = control.get_node_or_null("LevelLabel")
	if level_label and level_label is Label:
		level_label.text = "Nivel: %d - %s" % [level + 1, niveles[level]["nombre"]]
	
	# Buscar un Label para mostrar la cantidad de enemigos
	var enemies_label = control.get_node_or_null("EnemiesLabel")
	if enemies_label and enemies_label is Label:
		enemies_label.text = "Enemigos: %d" % current_enemies.size()

# ==================== ACCIONES DE BOTONES ====================
func _on_action_button_pressed(button_index: int) -> void:
	print("=== ACCIÓN %d SELECCIONADA ===" % (button_index + 1))
	
	match button_index:
		0:
			print("⚔️ ATAQUE!")
			_ejecutar_ataque()
		1:
			print("🛡️ DEFENSA!")
			_ejecutar_defensa()
		2:
			print("✨ HABILIDAD ESPECIAL!")
			_ejecutar_habilidad()
		3:
			print("💊 CURAR!")
			_ejecutar_curar()
		4:
			print("🌀 EVASIÓN!")
			_ejecutar_evasion()
		5:
			print("💀 RENDIRSE")
			_ejecutar_rendirse()
		_:
			print("Acción desconocida")

# ==================== EJECUCIÓN DE ACCIONES ====================
func _ejecutar_ataque() -> void:
	if not current_enemies or current_enemies.size() == 0:
		print("No hay enemigos para atacar")
		return
	
	# Seleccionar un enemigo aleatorio
	var random_index = randi() % current_enemies.size()
	var enemy = current_enemies[random_index]
	print("Atacando a enemigo %d: Número=%d, Color=%s" % [random_index + 1, enemy["numero"], enemy["color"]])
	
	# Emitir señal de enemigo seleccionado
	enemy_selected.emit(enemy)
	
	# Aquí puedes añadir lógica de combate, animaciones, etc.

func _ejecutar_defensa() -> void:
	print("Defensa activada! Reduciendo daño recibido")

func _ejecutar_habilidad() -> void:
	print("Habilidad especial activada!")

func _ejecutar_curar() -> void:
	print("Curando personaje...")

func _ejecutar_evasion() -> void:
	print("Evadiendo ataque!")

func _ejecutar_rendirse() -> void:
	print("Rendirse no es una opción! ¡Sigue luchando!")

# ==================== CONTROL DE CÁMARA ====================
func _process(delta: float) -> void:
	# Control de cámara con WASD o flechas
	_handle_camera_movement(delta)
	
	# Cambio de nivel con teclas
	_handle_level_controls()

func _handle_camera_movement(delta: float) -> void:
	if not camera:
		return
	
	var speed: float = 300.0
	var move_vector: Vector2 = Vector2.ZERO
	
	if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP):
		move_vector.y -= 1
	if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN):
		move_vector.y += 1
	if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT):
		move_vector.x -= 1
	if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
		move_vector.x += 1
	
	if move_vector != Vector2.ZERO:
		move_vector = move_vector.normalized()
		camera.position += move_vector * speed * delta

func _handle_level_controls() -> void:
	# Cambiar nivel con teclas numéricas
	if Input.is_key_pressed(KEY_1):
		cargar_nivel(0)
		await get_tree().create_timer(0.3).timeout
	if Input.is_key_pressed(KEY_2):
		cargar_nivel(1)
		await get_tree().create_timer(0.3).timeout
	if Input.is_key_pressed(KEY_3):
		cargar_nivel(2)
		await get_tree().create_timer(0.3).timeout
	
	# Cambiar nivel con N y B
	if Input.is_key_pressed(KEY_N):
		var next_level = (level + 1) % niveles.size()
		cargar_nivel(next_level)
		await get_tree().create_timer(0.3).timeout
	
	if Input.is_key_pressed(KEY_B):
		var prev_level = (level - 1) % niveles.size()
		if prev_level < 0:
			prev_level = niveles.size() - 1
		cargar_nivel(prev_level)
		await get_tree().create_timer(0.3).timeout

# ==================== FUNCIONES DE UTILIDAD ====================
func get_current_enemies() -> Array:
	return current_enemies

func get_level_info() -> Dictionary:
	if level < 0 or level >= niveles.size():
		return {}
	return {
		"indice": level,
		"nombre": niveles[level]["nombre"],
		"enemigos": niveles[level]["enemigos"],
		"cantidad": niveles[level]["enemigos"].size()
	}

func get_enemy_at_index(index: int) -> Dictionary:
	if index < 0 or index >= current_enemies.size():
		return {}
	return current_enemies[index]

# ==================== SEÑALES DEL MAINCHARACTER ====================
func _on_main_character_level_changed(new_level: int) -> void:
	cargar_nivel(new_level)

# ==================== DEPURACIÓN ====================
func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_F1:
			debug_print_state()
		
		if event.pressed and event.keycode == KEY_F2:
			randomize_current_level()

func debug_print_state() -> void:
	print("=== ESTADO DEL SISTEMA ===")
	print("Nivel actual: ", level)
	var info = get_level_info()
	if not info.is_empty():
		print("Nombre: ", info["nombre"])
		print("Cantidad de enemigos: ", info["cantidad"])
	print("Enemigos actuales:")
	for i in range(current_enemies.size()):
		var enemy = current_enemies[i]
		print("  [%d] Número=%d, Color=%s" % [i, enemy["numero"], enemy["color"]])
	print("Posición de la cámara: ", camera.position if camera else "Sin cámara")
	print("=== FIN DE ESTADO ===")

func randomize_current_level() -> void:
	if not action_grid:
		return
	
	print("Randomizando enemigos del nivel actual...")
	
	# Randomizar los enemigos del nivel actual
	for i in range(current_enemies.size()):
		var random_number = randi() % 6 + 1  # 1-6
		var colors = ["Rojo", "Azul", "Verde", "Incoloro"]
		var random_color = colors[randi() % colors.size()]
		current_enemies[i] = {"numero": random_number, "color": random_color}
	
	print("Enemigos randomizados!")
	debug_print_state()
