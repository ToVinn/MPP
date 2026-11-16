extends Node2D

# Atmospheric Animated Wall Torch with Dynamic Fire Flicker
# Uses official sprite sheet: Model/Kuil Kuno/KNOWLEDGE TEMPLE/Structures & Details/Torch Sheet.png (6 frames of 64x64)

const TORCH_SHEET = preload("res://Model/Kuil Kuno/KNOWLEDGE TEMPLE/Structures & Details/Torch Sheet.png")

var anim_timer: float = 0.0
var light_node: PointLight2D

func _ready() -> void:
	z_index = 0
	
	# Create dynamic flickering PointLight2D
	light_node = PointLight2D.new()
	light_node.texture = GameManager.create_light_texture(128)
	light_node.texture_scale = 1.6
	light_node.color = Color(1.0, 0.65, 0.28, 1.0)
	light_node.energy = 1.1
	light_node.position = Vector2(0, -16)
	add_child(light_node)

func _process(delta: float) -> void:
	anim_timer += delta
	
	# Realistic organic torchlight flicker
	if light_node:
		var flicker = sin(anim_timer * 14.0) * 0.08 + cos(anim_timer * 23.0) * 0.06
		light_node.energy = 1.05 + flicker
		light_node.texture_scale = 1.55 + flicker * 0.4
		
	queue_redraw()

func _draw() -> void:
	if not TORCH_SHEET:
		return
	var frame = int(anim_timer * 8.0) % 6
	var src_rect = Rect2(frame * 64, 0, 64, 64)
	var dest_rect = Rect2(-32, -54, 64, 64)
	draw_texture_rect_region(TORCH_SHEET, dest_rect, src_rect)

