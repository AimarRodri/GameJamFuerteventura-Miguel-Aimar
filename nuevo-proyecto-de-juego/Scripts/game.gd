extends Node

var level := 0
var won := false

# =========================
# VIDA JUGADOR
# =========================
var max_hp := 12
var hp := 12
var block := 0

@export var enemy_scene: PackedScene

@onready var ui = $Control
@onready var enemies = $Enemies
@onready var table = $Table
@onready var character = $MainCharacter/ViewCharacter

@onready var health_label: Label = $Control/Label
@onready var next_button := $Control/TextureButton


# =========================
# ENEMIGOS
# =========================
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


# =========================
# INIT
# =========================
func _ready():
	print("🎮 Game ready")

	ui.next_level_requested.connect(_on_next_level)
	ui.action_requested.connect(_on_action_requested)

	next_button.disabled = true

	_update_hp_ui()

	if not enemy_scene:
		push_error("❌ enemy_scene NULL")
		return

	_on_next_level()
	table.position.x += 150


# =========================
# VIDA PLAYER
# =========================
func _update_hp_ui():
	health_label.text = "%d/%d" % [hp, max_hp]


func take_damage(amount: int):

	if block > 0:
		var absorbed = min(block, amount)
		block -= absorbed
		amount -= absorbed

	if amount <= 0:
		return

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


# =========================
# LEVEL SYSTEM
# =========================
func _on_next_level():
	if won:
		return

	print("\n📊 ===== NIVEL", level, " =====")
	
	block = 0

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
		won = true
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

		# 💥 SOLO conectamos muerte
		if enemy.has_signal("enemy_died"):
			enemy.enemy_died.connect(_on_enemy_died)

		enemy.global_position = Vector2(-120 + enemy_index, 4)

		enemies.add_child(enemy)

func clear_enemies():
	for e in enemies.get_children():
		e.queue_free()


# =========================
# ENEMIGOS MUERTOS
# =========================
func _on_enemy_died():
	print("☠ Enemigo eliminado")

	call_deferred("_check_level_clear")

func _check_level_clear():
	_unlock_next_level()

func _unlock_next_level():
	print("➡ Nivel completado")

	next_button.disabled = false
	next_button.visible = true

# =========================
# ACCIONES
# =========================
func _on_action_requested(index: int):

	if !_action_unlocked(index):
		_show_action_locked(index)
		return

	print("Acción recibida:", index)

	match index:
		0:
			_action_0()
		1:
			_action_1()
		2:
			_action_2()
		3:
			_action_3()
		4:
			_action_4()
		5:
			_action_5()
		_:
			print("⚠ Acción no válida:", index)


func _get_first_enemy():
	for child in enemies.get_children():
		if child is Enemy and child.is_alive():
			return child
	return null


# =========================
# ACCIÓN 0 (ATAQUE)
# =========================
func _action_0():
	print("⚔ Ataque básico")

	var target = _get_first_enemy()

	if target == null:
		print("⚠ No hay enemigos")
		return

	target.recibir_danio(3)
	
	# Si ha muerto, no juega
	if !is_instance_valid(target) or !target.is_alive():
		return

	_enemy_turn()


func _action_1():
	print("💚 Curar 2 PV")
	heal(2)

func _action_2():
	print("🛡 Bloqueo +1")
	block += 1
	
func _action_3():
	print("💚 Curar 1 PV")
	heal(1)

func _action_4():
	print("⚔ Ataque ligero")

	var target = _get_first_enemy()

	if target == null:
		print("⚠ No hay enemigos")
		return

	target.recibir_danio(2)
	
	# Si ha muerto, no juega
	if !is_instance_valid(target) or !target.is_alive():
		return

	_enemy_turn()
		
func _action_5(): print("Acción 5")

func _enemy_turn():

	var enemy = _get_first_enemy()

	if enemy == null:
		return

	enemy.perform_turn(self)

func _action_unlocked(index: int) -> bool:
	match level:
		1:
			return index <= 1      # Solo acciones 0 y 1
		2:
			return index <= 2      # Solo acciones 0,1,2
		3:
			return index <= 4      # Solo acciones 0,1,2,3,4
		_:
			return true
			
func _show_action_locked(index: int):
	print("🔒 Acción ", index, " bloqueada en el nivel ", level)
