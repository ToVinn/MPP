extends StaticBody2D

# Universal Temple Prop & Architectural Decorator
# Places official Knowledge Temple structures: Giant Statues, Book Archives, Sarcophagi, Altars

@export_enum("giant_statue_1", "giant_statue_3", "books_scrolls", "sarcophagus", "table", "broken_column", "statue") var prop_type: String = "giant_statue_1"
@export var prop_scale: Vector2 = Vector2(1.2, 1.2)

const GIANT_STATUE_1 = preload("res://Model/Kuil Kuno/KNOWLEDGE TEMPLE/Structures & Details/Giant Statue 1.png")
const GIANT_STATUE_3 = preload("res://Model/Kuil Kuno/KNOWLEDGE TEMPLE/Structures & Details/Giant Statue 3.png")
const BOOKS_SCROLLS = preload("res://Model/Kuil Kuno/KNOWLEDGE TEMPLE/Structures & Details/Books & Scrolls.png")
const SARCOPHAGUS = preload("res://Model/Kuil Kuno/KNOWLEDGE TEMPLE/Structures & Details/Sarcophagus.png")
const TABLE = preload("res://Model/Kuil Kuno/KNOWLEDGE TEMPLE/Structures & Details/Table.png")
const BROKEN_COL = preload("res://Model/Kuil Kuno/KNOWLEDGE TEMPLE/Structures & Details/Broken Column.png")
const STATUE = preload("res://Model/Kuil Kuno/KNOWLEDGE TEMPLE/Structures & Details/Statue.png")

var tex: Texture2D
var tex_size: Vector2

func _ready() -> void:
	z_index = 0
	collision_layer = 1
	collision_mask = 0
	
	match prop_type:
		"giant_statue_1":
			tex = GIANT_STATUE_1
			tex_size = Vector2(96, 256)
		"giant_statue_3":
			tex = GIANT_STATUE_3
			tex_size = Vector2(96, 240)
		"books_scrolls":
			tex = BOOKS_SCROLLS
			tex_size = Vector2(128, 80)
		"sarcophagus":
			tex = SARCOPHAGUS
			tex_size = Vector2(80, 96)
		"table":
			tex = TABLE
			tex_size = Vector2(192, 192)
		"broken_column":
			tex = BROKEN_COL
			tex_size = Vector2(48, 128)
		"statue":
			tex = STATUE
			tex_size = Vector2(48, 80)
			
	var col = CollisionShape2D.new()
	var box = RectangleShape2D.new()
	box.size = Vector2(tex_size.x * 0.7 * prop_scale.x, 32.0 * prop_scale.y)
	col.shape = box
	col.position = Vector2(0, -16.0 * prop_scale.y)
	add_child(col)

func _draw() -> void:
	# Ground shadow
	var w = tex_size.x * prop_scale.x
	var h = tex_size.y * prop_scale.y
	
	draw_set_transform(Vector2(0, 0), 0.0, Vector2(1.0, 0.4))
	draw_circle(Vector2.ZERO, w * 0.45, Color(0.01, 0.02, 0.04, 0.45))
	draw_set_transform(Vector2.ZERO)
	
	if tex:
		var dest = Rect2(-w / 2.0, -h, w, h)
		draw_texture_rect(tex, dest, false)

