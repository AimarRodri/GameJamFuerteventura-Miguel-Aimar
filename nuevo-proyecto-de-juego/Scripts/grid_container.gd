extends GridContainer

func _ready() -> void:
	# 1. Obtenemos todos los hijos del GridContainer
	var botones = get_children()
	
	# 2. Recorremos los botones usando su índice (de 0 a 5)
	for i in range(botones.size()):
		var boton = botones[i]
		
		if boton is Button:
			# El número a imprimir será el índice + 1 (para que vaya del 1 al 6)
			var numero_boton = i + 1
			
			# Conectamos la pulsación del botón a nuestra función personalizada
			# Usamos .bind() para enviarle el número correcto a esa función
			boton.pressed.connect(_on_boton_pulsado.bind(numero_boton))

# 3. Esta función se ejecuta automáticamente al pulsar CUALQUIER botón
func _on_boton_pulsado(numero: int) -> void:
	print("Has pulsado el botón número: ", numero)
