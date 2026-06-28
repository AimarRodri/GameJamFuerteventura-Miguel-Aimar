class_name Enemy
extends Node2D

# Tipos de acción disponibles
enum ActionType {
	ATTACK,
	BLOCK,
	HEAL,
	NONE
}

# Vida
@export var max_hitpoints: int = 10
var hitpoints: int

# Acciones disponibles para este enemigo
# Cada acción tiene:
# {
#    "type": ActionType,
#    "value": int
# }
@export var actions: Array[Dictionary] = []

# Acción elegida este turno
var action: Dictionary = {}
var action_index: int = -1

# Estado
var blocking: bool = false


func _ready() -> void:
	hitpoints = max_hitpoints


# =====================================================
# VIDA
# =====================================================

func is_alive() -> bool:
	return hitpoints > 0


func is_dead() -> bool:
	return hitpoints <= 0


func recibir_danio(cantidad: int) -> void:

	if blocking:
		cantidad = maxi(1, cantidad / 2)

	hitpoints -= cantidad
	hitpoints = maxi(hitpoints, 0)

	print("Enemigo recibe %d de daño. HP restante: %d" % [cantidad, hitpoints])


func curar(cantidad: int) -> void:

	hitpoints += cantidad

	if hitpoints > max_hitpoints:
		hitpoints = max_hitpoints

	print("Enemigo se cura %d. HP: %d" % [cantidad, hitpoints])


# =====================================================
# BLOQUEO
# =====================================================

func empezar_bloqueo() -> void:
	blocking = true


func terminar_bloqueo() -> void:
	blocking = false


# =====================================================
# ACCIONES
# =====================================================

func add_action(type: ActionType, value: int) -> void:

	actions.append({
		"type": type,
		"value": value
	})


func decidir_accion() -> Dictionary:

	if actions.is_empty():
		push_error("No hay acciones disponibles para este enemigo.")

		action = {
			"type": ActionType.ATTACK,
			"value": 1
		}

		return action

	action_index = randi() % actions.size()

	# Duplicamos el diccionario para no modificar el original
	action = actions[action_index].duplicate()

	return action


func ejecutar_accion() -> void:
	push_warning("ejecutar_accion() debe ser sobrescrita por la clase hija.")


# =====================================================
# GETTERS
# =====================================================

func get_action() -> Dictionary:
	return action


func get_accion_descripcion() -> String:

	if action.is_empty():
		return "Sin acción"

	return "%s %d" % [
		ActionType.keys()[action["type"]],
		action["value"]
	]


func get_accion_tipo() -> ActionType:

	if action.is_empty():
		return ActionType.ATTACK

	return action["type"]


func get_accion_valor() -> int:

	if action.is_empty():
		return 0

	return action["value"]
