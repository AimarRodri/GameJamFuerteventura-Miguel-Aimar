extends Node

var level := 0

@export var enemy_scene: PackedScene

@onready var ui = $Control
@onready var enemies = $Enemies
@onready var table = $Table


# =====================================================
# ENEMIGOS DE CADA NIVEL
# =====================================================

var level_data = {
	1: [
		{
			"izq": 1,
			"der": 0,
			"hp": 6,
			"tipo_izq": Enemy.ActionType.BLOCK,
			"tipo_der": Enemy.ActionType.NONE
		}
	],

	2: [
		{
			"izq": 1,
			"der": 2,
			"hp": 6,
			"tipo_izq": Enemy.ActionType.HEAL,
			"tipo_der": Enemy.ActionType.ATTACK
		}
	],

	3: [
		{
			"izq": 2,
			"der": 1,
			"hp": 10,
			"tipo_izq": Enemy.ActionType.ATTACK,
			"tipo_der": Enemy.ActionType.BLOCK
		}
	]
}


func _ready():
	print("🎮 Game _ready() llamado")
	ui.next_level_requested.connect(_on_next_level)
	
	# Verificar que enemy_scene no sea null
	if not enemy_scene:
		push_error("❌ enemy_scene es NULL - Asigna la escena en el inspector")
		return
	
	print("✅ enemy_scene cargada correctamente")
	
	# Comenzar directamente en el nivel 1
	_on_next_level()


func _on_next_level():
	level += 1
	print("\n📊 ===== NIVEL", level, " =====")

	# Mover únicamente el fondo 150 px hacia la izquierda
	if level > 1:
		table.position.x -= 150

	if level > level_data.size():
		print("🏆 GANASTE el juego!")
		return

	clear_enemies()
	spawn_level(level)


# =====================================================
# SPAWN
# =====================================================

func spawn_level(lvl: int):
	print("🔄 Spawneando nivel:", lvl)
	
	if not level_data.has(lvl):
		push_error("❌ No existe configuración para el nivel %d" % lvl)
		return

	var enemy_index := 0

	for enemy_data in level_data[lvl]:
		enemy_index += 1
		print("\n📦 Creando enemigo #", enemy_index)
		
		# Mostrar datos del enemigo
		print("   ├── Valor izquierdo:", enemy_data["izq"])
		print("   ├── Valor derecho:", enemy_data["der"])
		print("   ├── HP:", enemy_data["hp"])
		print("   ├── Tipo izquierdo:", enemy_data["tipo_izq"])
		print("   └── Tipo derecho:", enemy_data["tipo_der"])

		var enemy := enemy_scene.instantiate() as DominoEnemy
		
		if not enemy:
			push_error("❌ Falló al instanciar enemigo")
			continue

		enemy.init(
			enemy_data["izq"],
			enemy_data["der"],
			enemy_data["hp"],
			enemy_data["tipo_izq"],
			enemy_data["tipo_der"],
			lvl  # <--- PASAR EL TIPO DE ENEMIGO (1, 2 o 3)
		)

		# Posicionar enemigos en fila (opcional)
		var pos_x = -120 + (enemy_index - 1)
		var pos_y = 4.0
		enemy.global_position = Vector2(pos_x, pos_y)
		
		print("📍 Enemigo #", enemy_index, " posicionado en: (", pos_x, ", ", pos_y, ")")
		print("🎨 Tipo de enemigo (imagen): Enemy", lvl, ".png")

		enemies.add_child(enemy)
		print("👥 Total enemigos en escena:", enemies.get_child_count())


# =====================================================
# LIMPIAR NIVEL
# =====================================================

func clear_enemies():
	var count = enemies.get_child_count()
	if count > 0:
		print("🧹 Limpiando", count, " enemigos...")
		
		for enemy in enemies.get_children():
			print("   └── Eliminando:", enemy.name)
			enemy.queue_free()
	else:
		print("🧹 No hay enemigos que limpiar")
