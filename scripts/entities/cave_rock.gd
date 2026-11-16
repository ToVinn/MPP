extends StaticBody2D

# Solid Cavern Rock & Stalagmite Obstacle
# Blocks player and monster movement with accurate collision and ground shadow

@export_range(1, 3) var rock_type: int = 1
@export var rock_scale: Vector2 = Vector2(1.5, 1.5)

const WOODS_TEX = preload("res://Model/Hutan/free_pixel_16_woods.png")

var src_rect: Rect2
var sprite_w: float = 32.0
var sprite_h: float = 32.0

func _ready() -> void:
	z_index = 0
	collision_layer = 1
	collision_mask = 0
	
	match rock_type:
		1:
			src_rect = Rect2(64, 96, 32, 32)
			sprite_w = 32.0
			sprite_h = 32.0
		2:
			src_rect = Rect2(96, 96, 32, 32)
			sprite_w = 32.0
			sprite_h = 32.0
		3:
			src_rect = Rect2(16, 96, 48, 48)
			sprite_w = 48.0
			sprite_h = 48.0
		_:
			src_rect = Rect2(64, 96, 32, 32)
			sprite_w = 32.0
			sprite_h = 32.0
		
	var col = CollisionShape2D.new()
	var circle = CircleShape2D.new()
	circle.radius = 16.0 * rock_scale.x
	col.shape = circle
	col.position = Vector2(0, -6 * rock_scale.y)
	add_child(col)

func _draw() -> void:
	# Ground contact shadow
	draw_set_transform(Vector2(0, 0), 0.0, Vector2(1.0, 0.45))
	draw_circle(Vector2.ZERO, 20.0 * rock_scale.x, Color(0.01, 0.02, 0.03, 0.45))
	draw_set_transform(Vector2.ZERO)
	
	if WOODS_TEX:
		var w = sprite_w * rock_scale.x
		var h = sprite_h * rock_scale.y
		var dest = Rect2(-w / 2.0, -h + (6.0 * rock_scale.y), w, h)
		draw_texture_rect_region(WOODS_TEX, dest, src_rect)
