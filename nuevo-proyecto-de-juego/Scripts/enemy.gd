class_name Enemy
extends Node

# Tipos de acción disponibles
enum ActionType {
	ATTACK,
	BLOCK,
	HEAL
}

# Atributos base
@export var hitpoints: int
@export var actions: Array = []  # Array de diccionarios con {type: ActionType, value: int}

# Variable para guardar la acción elegida en el turno
var action: Dictionary  # {type: ActionType, value: int}
var action_index: int = -1

# Función para decidir la acción al azar
func decidir_accion() -> Dictionary:
	if actions.size() == 0:
		push_error("No hay acciones disponibles para este enemigo")
		return {"type": ActionType.ATTACK, "value": 1}
	
	action_index = randi() % actions.size()
	action = actions[action_index]
	return action

# Función para ejecutar la acción (debe ser sobrescrita por los hijos)
func ejecutar_accion() -> void:
	push_warning("ejecutar_accion() debe ser sobrescrita por la clase hija")

# Función para obtener la descripción de la acción actual
func get_accion_descripcion() -> String:
	if not action:
		return "Sin acción"
	
	var type_name = ActionType.keys()[action["type"]]
	return "%s %d" % [type_name, action["value"]]

# Función para obtener el valor de la acción actual
func get_accion_valor() -> int:
	if not action:
		return 0
	return action["value"]

# Función para obtener el tipo de la acción actual
func get_accion_tipo() -> ActionType:
	if not action:
		return ActionType.ATTACK
	return action["type"]

# Función para verificar si el enemigo está vivo
func is_alive() -> bool:
	return hitpoints > 0

# Función para recibir daño
func recibir_danio(cantidad: int) -> void:
	hitpoints -= cantidad
	if hitpoints < 0:
		hitpoints = 0
	print("Enemigo recibe %d de daño. HP restante: %d" % [cantidad, hitpoints])
