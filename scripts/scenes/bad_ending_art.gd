extends Control

# Bad Ending Art: Aren alone in silent temple
# Uses official sprite model from Model/

const AREN_IDLE_TEX = preload("res://Model/Aren/Sprites/IDLE/idle_right.png")

func _draw() -> void:
	var w = size.x
	var h = size.y
	if w <= 0 or h <= 0:
		return
		
	# Dark, desaturated monochrome temple background
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.03, 0.03, 0.05))
	
	# Broken dark pillars
	draw_rect(Rect2(w * 0.15, h * 0.3, 30, h * 0.6), Color(0.08, 0.08, 0.1))
	draw_rect(Rect2(w * 0.82, h * 0.25, 30, h * 0.65), Color(0.08, 0.08, 0.1))
	
	# Ground
	draw_rect(Rect2(0, h * 0.75, w, h * 0.25), Color(0.05, 0.05, 0.07))
	
	# Extinguished, cracked dark crystal on altar
	var cx = w * 0.65
	var cy = h * 0.75
	draw_rect(Rect2(cx - 50, cy - 30, 100, 30), Color(0.1, 0.1, 0.12))
	var crystal_pts = PackedVector2Array([
		Vector2(cx, cy - 160),
		Vector2(cx + 35, cy - 90),
		Vector2(cx + 20, cy - 30),
		Vector2(cx - 20, cy - 30),
		Vector2(cx - 35, cy - 90)
	])
	draw_polygon(crystal_pts, PackedColorArray([Color(0.12, 0.13, 0.15)]))
	draw_line(Vector2(cx - 10, cy - 130), Vector2(cx + 15, cy - 80), Color(0.6, 0.65, 0.7), 2.0)
	draw_line(Vector2(cx + 15, cy - 80), Vector2(cx - 5, cy - 40), Color(0.6, 0.65, 0.7), 2.0)
	
	# Aren standing alone facing down/right, desaturated
	if AREN_IDLE_TEX:
		var aren_rect = Rect2(w * 0.38 - 48, h * 0.75 - 75, 96, 80)
		draw_texture_rect_region(AREN_IDLE_TEX, aren_rect, Rect2(0, 0, 96, 80), Color(0.7, 0.7, 0.75))
