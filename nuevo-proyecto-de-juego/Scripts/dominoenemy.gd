class_name DominoEnemy
extends Enemy

# Atributos específicos de ficha de dominó
var lado_izquierdo: int
var lado_derecho: int
var asset_name: String = ""  # ← NUEVO: nombre del asset para el sprite

# Constructor personalizado
func init(lado_izq: int, lado_der: int, hp: int = 10) -> void:
	lado_izquierdo = lado_izq
	lado_derecho = lado_der
	hitpoints = hp
	_generar_acciones()
	print("Ficha de dominó creada: [%d|%d] con %d HP" % [lado_izq, lado_der, hp])
# Generar acciones basadas en los números de la ficha
func _generar_acciones() -> void:
	actions.clear()
	
	# Acción 1: Usar el lado izquierdo como ataque
	var accion1 = {
		"type": ActionType.ATTACK,
		"value": lado_izquierdo
	}
	actions.append(accion1)
	
	# Acción 2: Usar el lado derecho como bloque o ataque dependiendo del valor
	var accion2: Dictionary
	if lado_derecho >= 4:
		# Si el lado derecho es alto, lo usa para bloquear
		accion2 = {
			"type": ActionType.BLOCK,
			"value": lado_derecho
		}
	else:
		# Si es bajo, lo usa para atacar
		accion2 = {
			"type": ActionType.ATTACK,
			"value": lado_derecho
		}
	actions.append(accion2)
	
	# Si ambos lados son iguales o la ficha es doble, añadir acción de curar
	if lado_izquierdo == lado_derecho:
		var accion3 = {
			"type": ActionType.HEAL,
			"value": lado_izquierdo
		}
		actions.append(accion3)
		print("Ficha doble! Acción de curación añadida")
	
	print("Acciones generadas: ", actions.size())

# Sobrescribir la ejecución de acción
func ejecutar_accion() -> void:
	if not action:
		decidir_accion()
		return
	
	match action["type"]:
		ActionType.ATTACK:
			_ejecutar_ataque()
		ActionType.BLOCK:
			_ejecutar_bloque()
		ActionType.HEAL:
			_ejecutar_curacion()
		_:
			print("Acción desconocida")

func _ejecutar_ataque() -> void:
	var danio = action["value"]
	print("Ficha [%d|%d] ATACA con fuerza %d!" % [lado_izquierdo, lado_derecho, danio])
	# Aquí iría la lógica para aplicar daño al jugador
	# GameManager.aplicar_danio_jugador(danio)

func _ejecutar_bloque() -> void:
	var defensa = action["value"]
	print("Ficha [%d|%d] se DEFIENDE con %d puntos de bloqueo!" % [lado_izquierdo, lado_derecho, defensa])
	# Aquí iría la lógica para aplicar bloqueo
	# GameManager.aplicar_bloqueo(defensa)

func _ejecutar_curacion() -> void:
	var curacion = action["value"]
	var hp_anterior = hitpoints
	hitpoints += curacion
	print("Ficha [%d|%d] se CURA %d puntos! HP: %d -> %d" % [lado_izquierdo, lado_derecho, curacion, hp_anterior, hitpoints])

# Función para obtener el color de la ficha basado en sus lados
func get_color() -> Color:
	# Color basado en la suma de los lados
	var suma = lado_izquierdo + lado_derecho
	match suma:
		2, 3, 4:
			return Color.GREEN
		5, 6, 7:
			return Color.YELLOW
		8, 9, 10:
			return Color.ORANGE
		11, 12:
			return Color.RED
		_:
			return Color.WHITE

# Función para obtener si la ficha es doble
func es_doble() -> bool:
	return lado_izquierdo == lado_derecho

# Función para obtener la suma de los lados
func get_suma() -> int:
	return lado_izquierdo + lado_derecho
