class_name MainCharacter
extends Node

# Cambiado a la ruta exacta donde están tus caras
const RUTA_ASSETS = "res://Assets/AssetsCaras/"

enum ActionType { }

@export var lifepoints: int
@export var actions: Array = []

var action: ActionType

# AGREGADO: Esta función nativa de Godot se ejecuta sola al iniciar la escena
func _ready() -> void:
	generar_personaje_aleatorio()

func decidir_accion() -> void:
	pass

func ejecutar_accion():
	pass

func generar_personaje_aleatorio() -> void:
	# 1. Definimos las listas según la nomenclatura exacta de tus archivos
	var opciones_numeros = ["1", "2", "3", "4", "5", "6"]
	var opciones_colores = ["Azul", "Rojo", "Verde"] # Añade más si tienes amarillo, etc.

	# 2. Elegimos al azar para cada una de las 3 caras
	var num_sup = opciones_numeros.pick_random()
	var col_sup = opciones_colores.pick_random()
	
	var num_der = opciones_numeros.pick_random()
	var col_der = opciones_colores.pick_random()
	
	var num_izq = opciones_numeros.pick_random()
	var col_izq = opciones_colores.pick_random()

	# 3. CORRECCIÓN DE RUTAS: Coincidiendo exactamente con tus archivos PNG
	var ruta_n_superior  = RUTA_ASSETS + num_sup + "Superior.png"      # Ej: 6Superior.png
	var ruta_c_superior  = RUTA_ASSETS + col_sup + "Arriba.png"        # Ej: AzulArriba.png
	
	var ruta_n_derecha   = RUTA_ASSETS + num_der + "Derecha.png"       # Ej: 5Derecha.png
	var ruta_c_derecha   = RUTA_ASSETS + col_der + "Derecha.png"       # Ej: RojoDerecha.png
	
	var ruta_n_izquierda = RUTA_ASSETS + num_izq + "Izquierda.png"     # Ej: 5Izquierda.png
	var ruta_c_izquierda = RUTA_ASSETS + col_izq + "Izquierda.png"     # Ej: RojoIzquierda.png

	# 4. Cargamos la primera imagen para averiguar el tamaño base
	var img_molde = load(ruta_c_superior).get_image()
	var tamano_personaje = img_molde.get_size()
	var rect_completo = Rect2i(Vector2i.ZERO, tamano_personaje)

	# 5. Creamos el lienzo final vacío y transparente
	var resultado_final = Image.create_empty(tamano_personaje.x, tamano_personaje.y, false, Image.FORMAT_RGBA8)

	# 6. ORDEN DE PINTADO: Izquierda -> Derecha -> Superior (Color primero, luego Número)
	
	# --- Cara Izquierda ---
	resultado_final.blit_rect(load(ruta_c_izquierda).get_image(), rect_completo, Vector2i.ZERO)
	resultado_final.blit_rect(load(ruta_n_izquierda).get_image(), rect_completo, Vector2i.ZERO)

	# --- Cara Derecha ---
	resultado_final.blit_rect(load(ruta_c_derecha).get_image(), rect_completo, Vector2i.ZERO)
	resultado_final.blit_rect(load(ruta_n_derecha).get_image(), rect_completo, Vector2i.ZERO)

	# --- Cara Superior ---
	resultado_final.blit_rect(load(ruta_c_superior).get_image(), rect_completo, Vector2i.ZERO)
	resultado_final.blit_rect(load(ruta_n_superior).get_image(), rect_completo, Vector2i.ZERO)

	# 7. Convertimos el resultado de memoria en una textura visible
	var textura_final = ImageTexture.create_from_image(resultado_final)
	
	# CORRECCIÓN DE NODO: Como este script hereda de 'Node', buscamos al hijo Sprite para asignarle la textura
	var sprite_hijo = get_node_or_null("Sprite2D")
	if sprite_hijo and sprite_hijo is Sprite2D:
		sprite_hijo.texture = textura_final
		print("¡Personaje compuesto aleatoriamente generado con éxito!")
	else:
		push_error("No se encontró el nodo hijo Sprite2D llamado 'SpriteMainCharacter'")
