extends Node

var level := 0
var won := false

# =========================
# VIDA
# =========================
var max_hp := 12
var hp := 12

@export var enemy_scene: PackedScene

@onready var ui = $Control
@onready var enemies = $Enemies
@onready var table = $Table
@onready var character = $MainCharacter/ViewCharacter

# SOLO LABEL (IMPORTANTE)
@onready var health_label: Label = $Control/Label


# =====================================================
# ENEMIGOS
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
	print("🎮 Game ready")

	ui.next_level_requested.connect(_on_next_level)

	await get_tree().process_frame

	print("📍 HEALTH LABEL LOCAL:", health_label.position)
	print("🌍 HEALTH LABEL GLOBAL:", health_label.global_position)
	print("👁 HEALTH LABEL VISIBLE:", health_label.visible)
	print("🧱 HEALTH LABEL PARENT:", health_label.get_parent().name)
	print("🎨 HEALTH LABEL MODULATE:", health_label.modulate)
	print("📏 HEALTH LABEL SCALE:", health_label.scale)
	print("📌 HEALTH LABEL TEXT INIT:", health_label.text)

	_update_hp_ui()

	if not enemy_scene:
		push_error("❌ enemy_scene NULL")
		return

	_on_next_level()
	table.position.x += 150
# =========================
# VIDA (SOLO LABEL)
# =========================

func _update_hp_ui():
	health_label.text = "%d/%d" % [hp, max_hp]


func take_damage(amount: int):
	hp -= amount
	hp = max(hp, 0)

	_update_hp_ui()

	if hp <= 0:
		_game_over()


func heal(amount: int):
	hp += amount
	hp = min(hp, max_hp)

	_update_hp_ui()


func _game_over():
	print("💀 GAME OVER")


# =====================================================
# NIVEL SYSTEM (SIN CAMBIOS)
# =====================================================

func _on_next_level():
	if !won:
		print("\n📊 ===== NIVEL", level, " =====")

		if level < 3:
			table.position.x -= 150
			level += 1

			if level == 2:
				character.set_face(
					MainCharacterView.Direction.IZQUIERDA,
					1,
					"Azul"
				)
		else:
			print("🏆 GANASTE")
			return

		clear_enemies()
		spawn_level(level)


func spawn_level(lvl: int):
	print("🔄 Spawneando:", lvl)

	if not level_data.has(lvl):
		return

	var enemy_index := 0

	for enemy_data in level_data[lvl]:
		enemy_index += 1

		var enemy := enemy_scene.instantiate() as DominoEnemy

		enemy.init(
			enemy_data["izq"],
			enemy_data["der"],
			enemy_data["hp"],
			enemy_data["tipo_izq"],
			enemy_data["tipo_der"],
			lvl
		)

		enemy.global_position = Vector2(-120 + enemy_index, 4)

		enemies.add_child(enemy)


func clear_enemies():
	for e in enemies.get_children():
		e.queue_free()
