extends Control

signal next_level_requested

@onready var menu := $TextureRect/MenuCharacter
@onready var next_button := $TextureButton

var page := 0

func _ready():

	next_button.next_level_requested.connect(_on_next_button)

	menu.button_pressed.connect(_on_menu_button)

func _on_next_button():

	page += 1

	if page < 3:
		$TextureRect.position.x += 151

	next_level_requested.emit()

func _on_menu_button(index:int):

	print("Botón", index)
