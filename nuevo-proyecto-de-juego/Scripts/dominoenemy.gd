class_name DominoEnemy
extends Enemy

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D  # ✅ Esto funciona en _ready()
@onready var health_label: Label = $Label

var frames: SpriteFrames
var lado_izquierdo: int
var lado_derecho: int
var tipo_izquierdo: ActionType
var tipo_derecho: ActionType
var enemy_type: int = 1


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

func actualizar_barra_vida():
	health_label.text = "%d/%d" % [hitpoints, max_hitpoints]
