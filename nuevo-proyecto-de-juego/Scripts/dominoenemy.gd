class_name DominoEnemy
extends Enemy

@onready var sprite: Sprite2D = $Sprite2D  # ✅ Esto funciona en _ready()

var lado_izquierdo: int
var lado_derecho: int
var tipo_izquierdo: ActionType
var tipo_derecho: ActionType
var enemy_type: int = 1


func init(lado_izq: int, lado_der: int, hp: int = 6,
		tipo_izq: ActionType = ActionType.ATTACK,
		tipo_der: ActionType = ActionType.ATTACK,
		tipo_enemigo: int = 1) -> void:

	# Solo GUARDAR datos, NO usar nodos hijos
	lado_izquierdo = lado_izq
	lado_derecho = lado_der
	max_hitpoints = hp
	hitpoints = max_hitpoints
	enemy_type = tipo_enemigo

	tipo_izquierdo = tipo_izq
	tipo_derecho = tipo_der

	_generar_acciones()
	# ❌ NO llamar a _actualizar_visual() aquí


func _ready():
	# ✅ Aquí los nodos hijos YA EXISTEN
	_actualizar_visual()


func _generar_acciones() -> void:
	actions.clear()

	actions.append({
		"type": tipo_izquierdo,
		"value": lado_izquierdo
	})

	actions.append({
		"type": tipo_derecho,
		"value": lado_derecho
	})


func _actualizar_visual() -> void:
	if not sprite:
		push_error("❌ Sprite2D no encontrado")
		return
	
	var ruta = "res://Assets/AssetsEnemies/Enemy" + str(enemy_type) + ".png"
	print("   🖼 Cargando textura: ", ruta)
	
	var textura = load(ruta)
	if textura:
		sprite.texture = textura
		print("   ✅ Textura cargada - Tamaño: ", textura.get_size())
		print("   📍 Posición final del enemigo: ", global_position)
	else:
		push_error("   ❌ No se encontró la imagen: ", ruta)
