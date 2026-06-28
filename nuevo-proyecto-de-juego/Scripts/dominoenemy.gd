class_name DominoEnemy
extends Enemy

signal enemy_died

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D  # ✅ Esto funciona en _ready()
@onready var health_label: Label = $Label

var frames: SpriteFrames
var lado_izquierdo: int
var lado_derecho: int
var tipo_izquierdo: ActionType
var tipo_derecho: ActionType
var enemy_type: int = 1
var block := 0

func actualizar_barra_vida():
	health_label.text = "%d/%d" % [hitpoints, max_hitpoints]

func init(
	lado_izq: int,
	lado_der: int,
	hp: int = 6,
	tipo_izq: ActionType = ActionType.ATTACK,
	tipo_der: ActionType = ActionType.ATTACK,
	tipo_enemigo: int = 1
) -> void:

	lado_izquierdo = lado_izq
	lado_derecho = lado_der

	max_hitpoints = hp
	hitpoints = hp

	enemy_type = tipo_enemigo

	tipo_izquierdo = tipo_izq
	tipo_derecho = tipo_der

	_generar_acciones()

func _ready():
	frames = load("res://Assets/Enemies.tres") as SpriteFrames
	sprite.sprite_frames = frames
	_actualizar_visual()
	actualizar_barra_vida()


func _generar_acciones() -> void:
	actions.clear()

	actions.append({
		"type": tipo_izquierdo,
		"value": lado_izquierdo
	})

	actions.append({
		"type": tipo_derecho,
		"value": lado_derecho
	})


func _actualizar_visual() -> void:
	if not sprite.sprite_frames:
		push_error("❌ No hay SpriteFrames asignados")
		return

	var anim_name = "Enemy" + str(enemy_type)

	if sprite.sprite_frames.has_animation(anim_name):
		sprite.play(anim_name)
	else:
		push_error("❌ Animación no existe: " + anim_name)

func recibir_danio(value: int):

	if block > 0:
		var absorbed = min(block, value)
		block -= absorbed
		value -= absorbed

	if value <= 0:
		return

	hitpoints -= value
	hitpoints = max(hitpoints, 0)

	actualizar_barra_vida()

	if hitpoints <= 0:
		_die()

func heal(value:int):
	hitpoints += value
	hitpoints = min(hitpoints, max_hitpoints)

	actualizar_barra_vida()

func add_block(value:int):
	block += value

func _die():
	print("☠ Enemigo muerto:", name)

	visible = false
	set_process(false)
	set_physics_process(false)

	enemy_died.emit()
	
func perform_turn(game):

	if hitpoints <= 0:
		return

	if actions.is_empty():
		return

	var action = actions.pick_random()

	match action.type:

		ActionType.ATTACK:
			print("👹 Enemigo ataca")
			game.take_damage(action.value)

		ActionType.HEAL:
			print("👹 Enemigo cura", action.value)
			heal(action.value)

		ActionType.BLOCK:
			print("👹 Enemigo bloquea", action.value)
			add_block(action.value)

		ActionType.NONE:
			pass
