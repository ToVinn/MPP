extends StaticBody2D

# Temple Pillar with solid base collision
# Prevents walking through ancient temple columns

@export var is_broken: bool = false
@export var is_statue: bool = false
@export var pillar_scale: Vector2 = Vector2(1.2, 1.2)

@onready var sprite: Sprite2D = $Sprite2D
@onready var col_shape: CollisionShape2D = $CollisionShape2D

const COL_TEX = preload("res://Model/Kuil Kuno/KNOWLEDGE TEMPLE/Structures & Details/Column.png")
const BROKEN_TEX = preload("res://Model/Kuil Kuno/KNOWLEDGE TEMPLE/Structures & Details/Broken Column.png")
const STATUE_TEX = preload("res://Model/Kuil Kuno/KNOWLEDGE TEMPLE/Structures & Details/Giant Statue 1.png")

func _ready() -> void:
	z_index = 0
	collision_layer = 1
	collision_mask = 0
	
	if sprite:
		if is_statue:
			sprite.texture = STATUE_TEX
			sprite.position = Vector2(0, -110)
		elif is_broken:
			sprite.texture = BROKEN_TEX
			sprite.position = Vector2(0, -90)
		else:
			sprite.texture = COL_TEX
			sprite.position = Vector2(0, -90)
		sprite.scale = pillar_scale
		
	if col_shape:
		var rect = RectangleShape2D.new()
		if is_statue:
			rect.size = Vector2(80, 50)
		else:
			rect.size = Vector2(48, 36)
		col_shape.shape = rect
		col_shape.position = Vector2(0, -8)

func _draw() -> void:
	# Base contact shadow
	var s_w = 90.0 if is_statue else 56.0
	draw_rect(Rect2(-s_w * 0.5, -20, s_w, 24), Color(0.02, 0.02, 0.04, 0.4))

