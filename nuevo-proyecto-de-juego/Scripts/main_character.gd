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

@export var actions:Array = []

var action:Dictionary = {}
var action_index:int = -1


func elegir_accion(index:int) -> bool:
	if index < 0 or index >= actions.size():
		return false

	action_index = index
	action = actions[index]

	action_selected.emit(index)
	return true


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


func recibir_danio(value:int):
	hitpoints = max(hitpoints - value, 0)
	hitpoints_changed.emit(hitpoints, max_hitpoints)


func curar(value:int):
	hitpoints = min(hitpoints + value, max_hitpoints)
	hitpoints_changed.emit(hitpoints, max_hitpoints)


func is_alive() -> bool:
	return hitpoints > 0


func reset():
	hitpoints = max_hitpoints
	action.clear()
	action_index = -1
	hitpoints_changed.emit(hitpoints, max_hitpoints)
