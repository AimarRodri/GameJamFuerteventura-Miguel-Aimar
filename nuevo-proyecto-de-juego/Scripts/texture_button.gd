extends TextureButton

func _ready() -> void:
	# 1. Comprobamos si el botón tiene una textura asignada en 'Normal'
	if texture_normal:
		# 2. Creamos un nuevo recurso BitMap en memoria
		var mascara = BitMap.new()
		
		# 3. Extraemos los datos de la imagen y generamos la máscara según el canal Alfa (transparencia)
		mascara.create_from_image_alpha(texture_normal.get_image(), 0.5)
		
		# 4. Asignamos la máscara recién creada al botón
		texture_click_mask = mascara
		
		print("¡Máscara de colisión por código generada con éxito para la flecha!")

	# CORRECCIÓN: Conectamos la señal de este propio botón (self) de forma limpia
	self.pressed.connect(_on_flecha_pulsada)


# 6. Esta función se ejecuta automáticamente cuando haces clic en la flecha
func _on_flecha_pulsada() -> void:
	print("¡Has pulsado la flecha! Pasando al siguiente nivel...")
	
	# Obtenemos el padre del padre (el abuelo del botón)
	var nodo_superior = get_parent().get_parent()
	
	if nodo_superior:
		# Imprimimos el nombre del nodo y su clase para asegurarnos
		print("--- COMPROBACIÓN ---")
		print("Nombre del nodo superior: ", nodo_superior.name)
		print("Tipo de nodo superior: ", nodo_superior.get_class())
		print("---------------------")
		
		# Opción A: Si el nodo superior se desplaza hacia la derecha (eje X)
		self.get_parent().get_parent().get_parent().level += 1
		if self.get_parent().get_parent().get_parent().level > 2:
				print("GANASTE")
		else:
			nodo_superior.position.x += 151
		
		print("Nodo superior movido a la posición: ", nodo_superior.position)
	else:
		push_error("No se pudo acceder al padre del padre de este botón.")
