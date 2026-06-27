class_name Enemy
extends Node  # O 'extends Resource' según lo que hayas elegido

# 1. Declaramos el tipo de acción usando un ENUM
enum ActionType { }

# Atributos base
@export var enemy_name: String
@export var hitpoints: int

# Variable para guardar la acción elegida en el turno
var action: ActionType

# Función para decidir la acción al azar (0 ó 1)
func decidir_accion() -> ActionType:
	# randi() % 2 devuelve 0 ó 1, que se corresponde exactamente con nuestro enum
	action = (randi() % 2) as ActionType
	return action
	
# Función base para ejecutar la acción (la sobrescribirán los hijos)
func ejecutar_accion():
	pass
