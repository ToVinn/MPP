extends StaticBody2D

# Luminescent Cave Crystal Cluster
# Natural mineral formation that illuminates the cavern with celestial bioluminescence

@export var crystal_scale: float = 1.3
@export var glow_color: Color = Color(0.3, 0.75, 1.0, 1.0)

var anim_timer: float = 0.0
var light_node: PointLight2D

func _ready() -> void:
	z_index = 0
	collision_layer = 1
	collision_mask = 0
	
	var col = CollisionShape2D.new()
	var circle = CircleShape2D.new()
	circle.radius = 14.0 * crystal_scale
	col.shape = circle
	col.position = Vector2(0, -6)
	add_child(col)
	
	light_node = PointLight2D.new()
	light_node.texture = GameManager.create_light_texture(128)
	light_node.texture_scale = 1.6 * crystal_scale
	light_node.color = glow_color
	light_node.energy = 0.95
	light_node.position = Vector2(0, -18 * crystal_scale)
	add_child(light_node)

func _process(delta: float) -> void:
	anim_timer += delta
	if light_node:
		var pulse = sin(anim_timer * 3.0) * 0.12
		light_node.energy = 0.95 + pulse
	queue_redraw()

func _draw() -> void:
	# Ground shadow
	draw_set_transform(Vector2(0, 0), 0.0, Vector2(1.0, 0.45))
	draw_circle(Vector2.ZERO, 18.0 * crystal_scale, Color(0.01, 0.02, 0.03, 0.4))
	draw_set_transform(Vector2.ZERO)
	
	var s = crystal_scale
	
	# Central tallest crystal spire
	var spire_pts = PackedVector2Array([
		Vector2(0, -38 * s),
		Vector2(8 * s, -14 * s),
		Vector2(5 * s, 2 * s),
		Vector2(-5 * s, 2 * s),
		Vector2(-8 * s, -14 * s)
	])
	draw_polygon(spire_pts, PackedColorArray([Color(0.2, 0.65, 0.95, 0.95)]))
	draw_polyline(spire_pts, Color(0.85, 0.95, 1.0, 1.0), 1.5)
	
	# Left leaning crystal shard
	var left_shard = PackedVector2Array([
		Vector2(-14 * s, -24 * s),
		Vector2(-4 * s, -6 * s),
		Vector2(-8 * s, 2 * s),
		Vector2(-16 * s, 0 * s)
	])
	draw_polygon(left_shard, PackedColorArray([Color(0.15, 0.55, 0.85, 0.9)]))
	draw_polyline(left_shard, Color(0.7, 0.9, 1.0, 0.9), 1.2)
	
	# Right leaning crystal shard
	var right_shard = PackedVector2Array([
		Vector2(14 * s, -20 * s),
		Vector2(16 * s, 0 * s),
		Vector2(8 * s, 2 * s),
		Vector2(4 * s, -6 * s)
	])
	draw_polygon(right_shard, PackedColorArray([Color(0.18, 0.58, 0.88, 0.9)]))
	draw_polyline(right_shard, Color(0.7, 0.9, 1.0, 0.9), 1.2)

