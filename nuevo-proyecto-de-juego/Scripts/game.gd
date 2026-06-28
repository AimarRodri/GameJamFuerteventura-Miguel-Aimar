extends Node

var level := 0

@onready var ui = $Control

func _ready():

	ui.next_level_requested.connect(_on_next_level)

func _on_next_level():

	level += 1

	print("Nivel:", level)

	if level > 2:
		print("GANASTE")
