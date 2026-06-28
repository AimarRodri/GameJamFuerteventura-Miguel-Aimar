class_name MainCharacter
extends Node

signal hitpoints_changed(current:int, maximum:int)
signal action_selected(index:int)

enum ActionType {
	ATTACK,
	BLOCK,
	HEAL
}

@export var max_hitpoints:int = 20
@export var hitpoints:int = 20

# Acciones disponibles para este combate
# Cada acción tiene:
# {
#    "type": ActionType,
#    "value": int
# }
@export var actions:Array = []

# Acción elegida este turno
var action:Dictionary = {}
var action_index:int = -1


func elegir_accion(index:int) -> bool:

	if index < 0:
		return false

	if index >= actions.size():
		return false

	action_index = index
	action = actions[index]

	action_selected.emit(index)

	return true


func ejecutar_accion() -> void:
	# CombatSystem será quien interprete la acción
	pass


func add_action(type:ActionType, value:int):

	actions.append({
		"type": type,
		"value": value
	})


func remove_action(index:int):

	if index >= 0 and index < actions.size():
		actions.remove_at(index)


func clear_actions():

	actions.clear()
	action.clear()
	action_index = -1


func get_action() -> Dictionary:
	return action


func get_action_type() -> ActionType:

	if action.is_empty():
		return ActionType.ATTACK

	return action["type"]


func get_action_value() -> int:

	if action.is_empty():
		return 0

	return action["value"]


func recibir_danio(value:int):

	hitpoints -= value

	if hitpoints < 0:
		hitpoints = 0

	hitpoints_changed.emit(hitpoints,max_hitpoints)


func curar(value:int):

	hitpoints += value

	if hitpoints > max_hitpoints:
		hitpoints = max_hitpoints

	hitpoints_changed.emit(hitpoints,max_hitpoints)


func is_alive() -> bool:
	return hitpoints > 0


func reset():

	hitpoints = max_hitpoints

	action.clear()
	action_index = -1

	hitpoints_changed.emit(hitpoints,max_hitpoints)
