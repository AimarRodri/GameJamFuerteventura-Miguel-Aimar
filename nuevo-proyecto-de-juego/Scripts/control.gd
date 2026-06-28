extends Control

signal next_level_requested

@onready var menu := $TextureRect/MenuCharacter
@onready var next_button := $TextureButton

func _ready():

	next_button.next_level_requested.connect(_on_next_button)

	menu.button_pressed.connect(_on_menu_button)

func _on_next_button():

	next_level_requested.emit()

func _on_menu_button(index:int):

	print("Botón", index)
