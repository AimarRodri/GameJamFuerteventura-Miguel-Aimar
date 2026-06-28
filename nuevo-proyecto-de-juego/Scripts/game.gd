extends Node2D

# ==================== REFERENCIAS A NODOS ====================
@onready var main_character: MainCharacter = $MainCharacter
@onready var camera: Camera2D = $Camera2D
@onready var control: Control = $Control
@onready var action_grid: GridContainer = $Control/TextureRect/MenuCharacter

# ==================== NODO PARA ENEMIGOS ====================
var enemies_container: Node2D  # Contenedor para los sprites de enemigos

# ==================== CONFIGURACIÓN DE POSICIONES DE ENEMIGOS ====================
@export var enemy_spacing: float = 64.0  # Espacio entre enemigos (horizontal)
@export var enemy_position_y: float = 0.0  # Posición Y de los enemigos
@export var enemy_scale: float = 1.0  # Escala de los enemigos

# Posiciones específicas para cada enemigo (se pueden configurar individualmente)
@export var enemy_positions: Array[Vector2] = []  # Si no está vacío, usa estas posiciones

# ==================== VARIABLES DE NIVEL ====================
var level: int = 0
var current_enemies: Array = []  # Array de DominoEnemy
var enemy_sprites: Array = []    # Array de Sprite2D para los enemigos
var enemy_index: int = -1

# ==================== DEFINICIÓN DE NIVELES ====================
var niveles: Array = [
	{
		"nombre": "Nivel 1 - Inicio",
		"enemigos": [
			{"lado_izq": 3, "lado_der": 2, "hp": 10, "asset": "Enemy1"}
		]
	},
	{
		"nombre": "Nivel 2 - Desafío",
		"enemigos": [
			{"lado_izq": 4, "lado_der": 5, "hp": 15, "asset": "Enemy2"},
			{"lado_izq": 2, "lado_der": 6, "hp": 12, "asset": "Enemy3"}
		]
	},
	{
		"nombre": "Nivel 3 - Duelo Final",
		"enemigos": [
			{"lado_izq": 5, "lado_der": 5, "hp": 20, "asset": "Enemy1"},
			{"lado_izq": 6, "lado_der": 4, "hp": 18, "asset": "Enemy2"},
			{"lado_izq": 3, "lado_der": 6, "hp": 16, "asset": "Enemy3"}
		]
	}
]

# ==================== SEÑALES ====================
signal level_changed(new_level: int)
signal enemy_selected(enemy_data: DominoEnemy)

# ==================== INICIALIZACIÓN ====================
func _ready() -> void:
	print("=== SISTEMA DE JUEGO INICIALIZADO ===")
	
	# Crear el contenedor de enemigos como hijo de Game
	enemies_container = Node2D.new()
	enemies_container.name = "EnemiesContainer"
	enemies_container.z_index = 10
	enemies_container.z_as_relative = false
	add_child(enemies_container)
	print("Creado EnemiesContainer con z_index=10")
	
	_connect_action_buttons()
	
	if main_character:
		print("MainCharacter encontrado")
		if main_character.has_signal("level_changed"):
			main_character.level_changed.connect(_on_main_character_level_changed)
	else:
		push_error("MainCharacter no encontrado")
	
	cargar_nivel(0)
	
	print("=== SISTEMA DE JUEGO LISTO ===")

func _connect_action_buttons() -> void:
	if not action_grid:
		push_error("ActionGrid no encontrado en la ruta: Control/TextureRect/MenuCharacter")
		return
	
	print("Conectando botones de acción...")
	
	var button_index: int = 0
	for child in action_grid.get_children():
		if child is TextureButton:
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
	
	# Limpiar enemigos anteriores
	_limpiar_enemigos()
	
	# Crear nuevos enemigos
	current_enemies = []
	for enemigo_data in nivel["enemigos"]:
		var enemy = DominoEnemy.new()
		enemy.init(
			enemigo_data["lado_izq"],
			enemigo_data["lado_der"],
			enemigo_data["hp"]
		)
		enemy.asset_name = enemigo_data["asset"]
		current_enemies.append(enemy)
	
	# Dibujar los enemigos en la escena
	_dibujar_enemigos()
	
	enemy_index = -1
	
	print("=== CARGANDO %s ===" % nivel["nombre"])
	print("Enemigos en este nivel: ", current_enemies.size())
	for i in range(current_enemies.size()):
		var enemy = current_enemies[i]
		print("  Enemigo %d: %s (Asset: %s)" % [i+1, enemy.to_string(), enemy.asset_name])
	
	_actualizar_personaje_con_enemigos()
	level_changed.emit(index)
	_actualizar_ui_nivel()

# ==================== DIBUJAR ENEMIGOS ====================
func _limpiar_enemigos() -> void:
	# Eliminar sprites anteriores
	for sprite in enemy_sprites:
		if is_instance_valid(sprite):
			sprite.queue_free()
	enemy_sprites.clear()

func _dibujar_enemigos() -> void:
	if not enemies_container:
		return
	
	for i in range(current_enemies.size()):
		var enemy = current_enemies[i]
		
		# Crear un Sprite2D para el enemigo
		var sprite = Sprite2D.new()
		sprite.name = "EnemySprite_%d" % i
		sprite.z_index = 5
		sprite.z_as_relative = false
		
		# Cargar la textura del asset
		var texture_path = "res://Assets/AssetsEnemies/%s.png" % enemy.asset_name
		if ResourceLoader.exists(texture_path):
			sprite.texture = load(texture_path)
			print("✓ Cargada textura para enemigo %d: %s" % [i+1, texture_path])
		else:
			push_error("✗ No se encontró textura: %s" % texture_path)
			# Crear un cuadrado de color como fallback
			var img = Image.create(64, 64, false, Image.FORMAT_RGBA8)
			img.fill(Color.RED)
			sprite.texture = ImageTexture.create_from_image(img)
		
		# ==================== POSICIONAR EL ENEMIGO ====================
		var pos: Vector2
		
		# Si hay posiciones personalizadas configuradas, usarlas
		if i < enemy_positions.size():
			pos = enemy_positions[i]
			print("Usando posición personalizada para enemigo %d: %s" % [i+1, pos])
		else:
			# Si no, calcular posición automática
			var total = current_enemies.size()
			var start_x = -((total - 1) * enemy_spacing) / 2
			pos = Vector2(start_x + i * enemy_spacing, enemy_position_y)
			print("Usando posición automática para enemigo %d: %s" % [i+1, pos])
		
		# Aplicar posición y escala
		sprite.position = pos
		sprite.scale = Vector2(enemy_scale, enemy_scale)
		
		# Añadir a la escena
		enemies_container.add_child(sprite)
		enemy_sprites.append(sprite)
		
		print("Enemigo %d dibujado en posición: %s (z_index=%d, escala=%s)" % [i+1, sprite.position, sprite.z_index, sprite.scale])

func _actualizar_enemigos_visuales() -> void:
	# Actualizar visualmente los enemigos (cuando cambian sus stats)
	for i in range(min(current_enemies.size(), enemy_sprites.size())):
		var enemy = current_enemies[i]
		var sprite = enemy_sprites[i]
		
		if not is_instance_valid(sprite):
			continue
		
		# Cambiar escala según HP (relativo a la escala base)
		var hp_ratio = float(enemy.hitpoints) / 20.0
		var scale_value = 0.5 + hp_ratio * 0.5
		sprite.scale = Vector2(enemy_scale * scale_value, enemy_scale * scale_value)
		
		# Cambiar color según estado
		if enemy.is_alive():
			sprite.modulate = Color.WHITE
		else:
			sprite.modulate = Color.GRAY

# ==================== FUNCIONES DE UTILIDAD ====================
func _actualizar_personaje_con_enemigos() -> void:
	if not main_character:
		return
	
	var enemies_data = []
	for enemy in current_enemies:
		enemies_data.append({
			"numero": enemy.lado_izquierdo,
			"color": _get_color_name(enemy.get_color())
		})
	
	if main_character.has_method("set_enemies"):
		main_character.set_enemies(enemies_data)

func _get_color_name(color: Color) -> String:
	if color == Color.GREEN:
		return "Verde"
	elif color == Color.YELLOW:
		return "Amarillo"
	elif color == Color.ORANGE:
		return "Naranja"
	elif color == Color.RED:
		return "Rojo"
	else:
		return "Incoloro"

func _actualizar_ui_nivel() -> void:
	if not control:
		return
	
	var level_label = control.get_node_or_null("LevelLabel")
	if level_label and level_label is Label:
		level_label.text = "Nivel: %d - %s" % [level + 1, niveles[level]["nombre"]]
	
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
	if current_enemies.size() == 0:
		print("No hay enemigos para atacar")
		return
	
	var random_index = randi() % current_enemies.size()
	var enemy: DominoEnemy = current_enemies[random_index]
	
	if not enemy.is_alive():
		print("El enemigo ya está muerto!")
		return
	
	print("Atacando a: ", enemy.to_string())
	
	var accion = enemy.decidir_accion()
	print("Enemigo usa: ", enemy.get_accion_descripcion())
	enemy.ejecutar_accion()
	
	_actualizar_enemigos_visuales()
	
	enemy_selected.emit(enemy)
	
	if not enemy.is_alive():
		print("¡Enemigo derrotado!")
		_verificar_fin_nivel()

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

func _verificar_fin_nivel() -> void:
	var vivos = 0
	for enemy in current_enemies:
		if enemy.is_alive():
			vivos += 1
	
	if vivos == 0:
		print("🎉 ¡Todos los enemigos derrotados! Nivel completado!")
		var next_level = (level + 1) % niveles.size()
		if next_level == 0:
			print("¡Has completado todos los niveles!")
		else:
			print("Cargando siguiente nivel...")
			cargar_nivel(next_level)

# ==================== CONTROL DE CÁMARA ====================
func _process(delta: float) -> void:
	_handle_camera_movement(delta)
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
	if Input.is_key_pressed(KEY_1):
		cargar_nivel(0)
		await get_tree().create_timer(0.3).timeout
	if Input.is_key_pressed(KEY_2):
		cargar_nivel(1)
		await get_tree().create_timer(0.3).timeout
	if Input.is_key_pressed(KEY_3):
		cargar_nivel(2)
		await get_tree().create_timer(0.3).timeout
	
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

func get_enemy_at_index(index: int) -> DominoEnemy:
	if index < 0 or index >= current_enemies.size():
		return null
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
		print("  [%d] %s - Vivo: %s" % [i, enemy.to_string(), enemy.is_alive()])
	print("Posición de la cámara: ", camera.position if camera else "Sin cámara")
	print("Posición de enemigos:")
	for i in range(enemy_sprites.size()):
		var sprite = enemy_sprites[i]
		if is_instance_valid(sprite):
			print("  [%d] Posición: %s, Visible: %s" % [i, sprite.position, sprite.visible])
	print("=== FIN DE ESTADO ===")

func randomize_current_level() -> void:
	print("Randomizando enemigos del nivel actual...")
	
	for enemy in current_enemies:
		enemy.lado_izquierdo = randi() % 6 + 1
		enemy.lado_derecho = randi() % 6 + 1
		enemy._generar_acciones()
	
	_dibujar_enemigos()
	_actualizar_enemigos_visuales()
	
	print("Enemigos randomizados!")
	debug_print_state()
