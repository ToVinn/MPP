extends StaticBody2D

# Ancient Cavern Waterfall Statue
# Uses official sprite sheet: Model/Kuil Kuno/The Myth of Pixel_Water Temple 1.05/Statue with jar/statue with jar and waterfall loop .png (8 frames of 88x192)

const STATUE_SHEET = preload("res://Model/Kuil Kuno/The Myth of Pixel_Water Temple 1.05/Statue with jar/statue with jar and waterfall loop .png")

var anim_timer: float = 0.0
var light_node: PointLight2D

func _ready() -> void:
	z_index = 0
	collision_layer = 1
	collision_mask = 0
	
	# Solid base collision
	var col = CollisionShape2D.new()
	var box = RectangleShape2D.new()
	box.size = Vector2(70, 30)
	col.shape = box
	col.position = Vector2(0, -15)
	add_child(col)
	
	# Water glow light
	light_node = PointLight2D.new()
	light_node.texture = GameManager.create_light_texture(128)
	light_node.texture_scale = 1.8
	light_node.color = Color(0.25, 0.7, 1.0, 1.0)
	light_node.energy = 0.95
	light_node.position = Vector2(0, -30)
	add_child(light_node)

func _process(delta: float) -> void:
	anim_timer += delta
	if light_node:
		var wave = sin(anim_timer * 4.0) * 0.1
		light_node.energy = 0.95 + wave
	queue_redraw()

func _draw() -> void:
	# Ground water ripples
	draw_set_transform(Vector2(0, 0), 0.0, Vector2(1.0, 0.4))
	draw_circle(Vector2.ZERO, 38.0, Color(0.1, 0.35, 0.6, 0.4))
	draw_set_transform(Vector2.ZERO)
	
	if not STATUE_SHEET:
		return
		
	var frame = int(anim_timer * 10.0) % 8
	var src_rect = Rect2(frame * 88, 0, 88, 192)
	var dest_rect = Rect2(-44, -180, 88, 192)
	draw_texture_rect_region(STATUE_SHEET, dest_rect, src_rect)

