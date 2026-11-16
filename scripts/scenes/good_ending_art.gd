extends Control

# Good Ending Art: Aren & Lyra reunited at sunrise
# Uses official sprite models from Model/

var time: float = 0.0

const LYRA_TEX = preload("res://Model/Lyra/Idle/south/frame_000.png")
const AREN_IDLE_TEX = preload("res://Model/Aren/Sprites/IDLE/idle_right.png")

func _process(delta: float) -> void:
	time += delta
	queue_redraw()

func _draw() -> void:
	var w = size.x
	var h = size.y
	if w <= 0 or h <= 0:
		return
		
	# Dawn sky gradient (Golden orange into soft pastel azure)
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.12, 0.22, 0.38))
	draw_circle(Vector2(w * 0.5, h * 0.7), 280.0, Color(0.9, 0.55, 0.25, 0.35))
	draw_circle(Vector2(w * 0.5, h * 0.7), 160.0, Color(1.0, 0.85, 0.45, 0.55))
	
	# Distant Mountain Ridges
	var mt1 = PackedVector2Array([
		Vector2(0, h),
		Vector2(0, h * 0.55),
		Vector2(w * 0.35, h * 0.42),
		Vector2(w * 0.75, h * 0.52),
		Vector2(w, h * 0.45),
		Vector2(w, h)
	])
	draw_polygon(mt1, PackedColorArray([Color(0.2, 0.16, 0.28)]))
	
	# Foreground Cliff
	var cliff = PackedVector2Array([
		Vector2(0, h),
		Vector2(0, h * 0.75),
		Vector2(w * 0.6, h * 0.68),
		Vector2(w, h * 0.78),
		Vector2(w, h)
	])
	draw_polygon(cliff, PackedColorArray([Color(0.08, 0.1, 0.14)]))
	
	# Aren & Lyra standing together holding hands facing the sunrise
	var center = Vector2(w * 0.48, h * 0.68)
	
	if AREN_IDLE_TEX:
		var aren_rect = Rect2(center.x - 70, center.y - 80, 96, 80)
		draw_texture_rect_region(AREN_IDLE_TEX, aren_rect, Rect2(0, 0, 96, 80))
		
	if LYRA_TEX:
		var lyra_rect = Rect2(center.x + 10, center.y - 90, 96, 96)
		draw_texture_rect(LYRA_TEX, lyra_rect, false)
	
	# Glowing celestial bond between their hands
	var sparkle = sin(time * 5.0) * 4.0 + 8.0
	draw_circle(center + Vector2(15, -45), sparkle, Color(0.6, 0.9, 1.0, 0.7))
