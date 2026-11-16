extends Control

# Memory Flashback Art Renderer
# Visualizes past events using official Aren & Lyra models with cinematic indie RPG art style

var memory_id: int = 1
var anim_phase: float = 0.0

const LYRA_TEX = preload("res://Model/Lyra/Idle/south/frame_000.png")
const AREN_IDLE_TEX = preload("res://Model/Aren/Sprites/IDLE/idle_right.png")
const ALTAR_TEX = preload("res://Model/Kuil Kuno/KNOWLEDGE TEMPLE/Structures & Details/Empty Hand-shaped Altar.png")

func _process(delta: float) -> void:
	if is_visible_in_tree():
		anim_phase += delta
		queue_redraw()

func _draw() -> void:
	var w = size.x
	var h = size.y
	if w <= 0 or h <= 0:
		return
	
	# Dreamy celestial vignette backdrop
	var bg_color = Color(0.03, 0.05, 0.10, 0.82)
	draw_rect(Rect2(Vector2.ZERO, size), bg_color)
	
	match memory_id:
		1:
			_draw_memory_1(w, h)
		2:
			_draw_memory_2(w, h)
		3:
			_draw_memory_3(w, h)
		_:
			_draw_memory_1(w, h)

func _draw_memory_1(w: float, h: float) -> void:
	# Memory 1: Young Aren & Lyra discovering the Sacred Crystal in Gua Kristal
	var center = Vector2(w * 0.5, h * 0.52)
	
	# Ancient Stone Altar Dais in background
	if ALTAR_TEX:
		var altar_rect = Rect2(center.x - 50, center.y - 40, 100, 140)
		draw_texture_rect(ALTAR_TEX, altar_rect, false)

	# Ethereal Celestial Crystal Glow
	var glow_size = 120.0 + sin(anim_phase * 2.2) * 12.0
	draw_circle(center - Vector2(0, 50), glow_size, Color(0.1, 0.45, 0.9, 0.16))
	draw_circle(center - Vector2(0, 50), glow_size * 0.55, Color(0.3, 0.75, 1.0, 0.28))

	# Multifaceted Hovering Crystal Shard
	var bob = sin(anim_phase * 2.5) * 6.0
	var c_pos = center - Vector2(0, 55 + bob)
	
	# Outer crystal silhouette
	var pts_outer = PackedVector2Array([
		c_pos + Vector2(0, -65),
		c_pos + Vector2(30, -10),
		c_pos + Vector2(18, 48),
		c_pos + Vector2(-18, 48),
		c_pos + Vector2(-30, -10)
	])
	draw_polygon(pts_outer, PackedColorArray([Color(0.2, 0.55, 0.88, 0.95)]))

	# Inner crystal facets with specular gradient
	var pts_facet_left = PackedVector2Array([
		c_pos + Vector2(0, -65),
		c_pos + Vector2(-30, -10),
		c_pos + Vector2(-18, 48),
		c_pos + Vector2(0, 20)
	])
	draw_polygon(pts_facet_left, PackedColorArray([Color(0.15, 0.42, 0.75, 0.95)]))

	var pts_facet_center = PackedVector2Array([
		c_pos + Vector2(0, -65),
		c_pos + Vector2(18, -10),
		c_pos + Vector2(0, 48),
		c_pos + Vector2(-12, -10)
	])
	draw_polygon(pts_facet_center, PackedColorArray([Color(0.45, 0.85, 1.0, 0.95)]))
	draw_polyline(pts_outer, Color(0.9, 0.98, 1.0, 0.95), 2.0)

	# Orbiting starlight motes
	for i in range(5):
		var ang = anim_phase * 1.8 + (TAU / 5.0) * i
		var mote = c_pos + Vector2(cos(ang) * 55.0, sin(ang) * 22.0)
		draw_circle(mote, 3.5, Color(0.8, 0.95, 1.0, 0.85))

	# Aren (left side)
	if AREN_IDLE_TEX:
		var aren_rect = Rect2(center.x - 170, center.y - 10, 110, 92)
		draw_texture_rect_region(AREN_IDLE_TEX, aren_rect, Rect2(0, 0, 96, 80))
		
	# Lyra (right side)
	if LYRA_TEX:
		var lyra_rect = Rect2(center.x + 65, center.y - 20, 105, 105)
		draw_texture_rect(LYRA_TEX, lyra_rect, false)

	# Reaching light ray between them
	draw_line(center + Vector2(-70, 20), center + Vector2(65, 20), Color(0.6, 0.88, 1.0, 0.4), 2.0)

func _draw_memory_2(w: float, h: float) -> void:
	# Memory 2: Aren and Lyra on the hill under darkening twilight
	var center = Vector2(w * 0.5, h * 0.5)
	
	# Twilight sky gradient with swirling rift
	var rift_glow = sin(anim_phase * 1.5) * 20.0
	draw_circle(Vector2(w * 0.5, h * 0.25), 120.0 + rift_glow, Color(0.5, 0.2, 0.7, 0.2))
	draw_circle(Vector2(w * 0.5, h * 0.25), 60.0, Color(0.8, 0.6, 1.0, 0.4))
	
	# Hill silhouette
	var hill_pts = PackedVector2Array([
		Vector2(0, h),
		Vector2(0, h * 0.75),
		Vector2(w * 0.5, h * 0.65),
		Vector2(w, h * 0.8),
		Vector2(w, h)
	])
	draw_polygon(hill_pts, PackedColorArray([Color(0.05, 0.1, 0.12, 1.0)]))
	
	# Aren and Lyra on the hill crest making their promise
	var crest = Vector2(w * 0.5, h * 0.65)
	if AREN_IDLE_TEX:
		var aren_rect = Rect2(crest.x - 85, crest.y - 70, 96, 80)
		draw_texture_rect_region(AREN_IDLE_TEX, aren_rect, Rect2(0, 0, 96, 80))
		
	if LYRA_TEX:
		var lyra_rect = Rect2(crest.x + 10, crest.y - 80, 90, 90)
		draw_texture_rect(LYRA_TEX, lyra_rect, false)
		
	draw_line(crest + Vector2(-10, -35), crest + Vector2(25, -35), Color(0.8, 0.95, 1.0, 0.8), 2.5)

func _draw_memory_3(w: float, h: float) -> void:
	# Memory 3: Silent Eclipse event in the Ancient Temple
	var center = Vector2(w * 0.5, h * 0.5)
	
	# Temple pillars in silhouette
	draw_rect(Rect2(w * 0.18, h * 0.2, 40, h * 0.6), Color(0.08, 0.06, 0.14))
	draw_rect(Rect2(w * 0.78, h * 0.2, 40, h * 0.6), Color(0.08, 0.06, 0.14))

	# Silent Eclipse Crimson Rift
	var eclipse_pulse = sin(anim_phase * 2.0) * 15.0
	draw_circle(center - Vector2(0, 60), 90.0 + eclipse_pulse, Color(0.7, 0.15, 0.25, 0.35))
	draw_circle(center - Vector2(0, 60), 60.0, Color(0.08, 0.04, 0.12, 0.95))
	draw_arc(center - Vector2(0, 60), 62.0, 0, TAU, 36, Color(1.0, 0.35, 0.45, 0.9), 3.0)

	# Lyra being drawn toward the rift
	if LYRA_TEX:
		var lyra_rect = Rect2(center.x - 45, center.y - 40, 90, 90)
		draw_texture_rect(LYRA_TEX, lyra_rect, false)

	# Aren reaching out helplessly
	if AREN_IDLE_TEX:
		var aren_rect = Rect2(center.x - 170, center.y + 10, 96, 80)
		draw_texture_rect_region(AREN_IDLE_TEX, aren_rect, Rect2(0, 0, 96, 80))
