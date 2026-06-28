extends Control

signal next_level_requested
signal action_requested(index: int)

@onready var menu := $TextureRect/MenuCharacter
@onready var next_button := $TextureButton
@onready var texture_rect := $TextureRect

var grids: Array[Texture2D] = []
var current_index: int = 0


func _ready():
	# backgrounds
	grids.append(preload("res://Assets/AssetsInterface/Grid1.png"))
	grids.append(preload("res://Assets/AssetsInterface/Grid2.png"))
	grids.append(preload("res://Assets/AssetsInterface/Grid3.png"))
	grids.append(preload("res://Assets/AssetsInterface/Grid4.png"))
	texture_rect.texture = grids[current_index]

	# 🔥 SOLO NEXT LEVEL (NO TOCAR)
	next_button.pressed.connect(_on_next_button)

	# 🔥 NUEVO: acciones del personaje
	menu.button_pressed.connect(_on_menu_button)


# =========================
# NEXT LEVEL (NO CAMBIAR)
# =========================
func _on_next_button():
	if current_index == 3:
		texture_rect.texture = grids[3]
		next_level_requested.emit()
		return
	current_index = (current_index + 1) % grids.size()
	texture_rect.texture = grids[current_index]

	next_button.visible = false
	next_button.disabled = true

	next_level_requested.emit()


# =========================
# ACCIONES PERSONAJE
# =========================
func _on_menu_button(index: int):
	print("🎯 Acción del personaje:", index)

	# 🔥 AQUÍ EMITIMOS NUEVA SEÑAL
	action_requested.emit(index)
