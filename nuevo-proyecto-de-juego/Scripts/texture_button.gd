extends TextureButton

signal next_level_requested

func _ready():

	if texture_normal:

		var mask = BitMap.new()

		mask.create_from_image_alpha(
			texture_normal.get_image(),
			0.5
		)

		texture_click_mask = mask

	pressed.connect(_on_pressed)

func _on_pressed():

	next_level_requested.emit()
