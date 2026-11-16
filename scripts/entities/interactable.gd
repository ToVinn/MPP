extends Area2D

# Universal Interactable node for Echoes of Astra
# Triggers dialogues, inspections, puzzles, or transitions using official sprite models

signal interacted(player: Node)

@export var prompt_text: String = "[E] Periksa"
@export var is_one_shot: bool = false
@export var visual_type: String = "crystal" # "crystal", "altar", "npc_eldrin", "npc_knight", "door", "paper", "relief", "none"
@export var dialogue_sequence: Array = [] # List of {"speaker": "Aren", "text": "..."}

const ELDER_TEX = preload("res://Model/elder/StewV_Fantasy_Characters_01.png")
const ALTAR_SHEET = preload("res://Model/Kuil Kuno/KNOWLEDGE TEMPLE/Structures & Details/Hand-shaped Altar Sheet.png")

var knight_frames: Array = []
var is_interacted: bool = false
var pulse_time: float = 0.0
var light_node: PointLight2D

func _load_tex_safe(res_path: String) -> Texture2D:
	if ResourceLoader.exists(res_path):
		var res = load(res_path)
		if res is Texture2D:
			return res
	var global_path = ProjectSettings.globalize_path(res_path)
	if FileAccess.file_exists(global_path) or FileAccess.file_exists(res_path):
		var img = Image.new()
		if img.load(global_path) == OK:
			return ImageTexture.create_from_image(img)
	return null

func _ready() -> void:
	z_index = 0
	add_to_group("interactable")
	collision_layer = 4
	collision_mask = 0
	
	if visual_type == "npc_knight":
		for i in range(1, 16):
			var tex = _load_tex_safe("res://Model/Knight/Idle/" + str(i) + ".png")
			if tex:
				knight_frames.append(tex)
				
	# Add point light to glowing altars and crystals
	if visual_type in ["altar", "crystal"]:
		light_node = PointLight2D.new()
		light_node.texture = GameManager.create_light_texture(128)
		light_node.texture_scale = 1.9 if visual_type == "altar" else 1.2
		light_node.color = Color(0.3, 0.75, 1.0, 1.0)
		light_node.energy = 1.1 if visual_type == "altar" else 0.8
		light_node.position = Vector2(0, -45 if visual_type == "altar" else -12)
		add_child(light_node)

func _process(delta: float) -> void:
	if visual_type != "none":
		pulse_time += delta
		if light_node:
			var wave = sin(pulse_time * 3.5) * 0.12
			light_node.energy = (1.1 if visual_type == "altar" else 0.8) + wave
		queue_redraw()

func get_prompt() -> String:
	return prompt_text

func interact(player: Node) -> void:
	if is_one_shot and is_interacted:
		return
	
	is_interacted = true
	interacted.emit(player)
	
	if not dialogue_sequence.is_empty():
		DialogueManager.start_dialogue(dialogue_sequence)

func _draw() -> void:
	match visual_type:
		"crystal":
			_draw_crystal()
		"altar":
			_draw_altar()
		"paper":
			_draw_paper()
		"door":
			_draw_door()
		"relief":
			_draw_relief()
		"npc_eldrin":
			_draw_eldrin()
		"npc_knight":
			_draw_hollow_knight()
		_:
			pass

func _draw_crystal() -> void:
	var pulse = sin(pulse_time * 4.0) * 3.0
	# Ground shadow
	draw_set_transform(Vector2(0, 0), 0.0, Vector2(1.0, 0.45))
	draw_circle(Vector2.ZERO, 14.0, Color(0.01, 0.02, 0.03, 0.4))
	draw_set_transform(Vector2.ZERO)

	# Outer starlight aura
	draw_circle(Vector2(0, -14), 22.0 + pulse, Color(0.2, 0.6, 1.0, 0.22))
	draw_circle(Vector2(0, -14), 14.0, Color(0.4, 0.8, 1.0, 0.35))
	
	# Multifaceted Gemstone
	var bob = sin(pulse_time * 3.0) * 3.0
	var c_y = -16.0 + bob
	var pts_outer = PackedVector2Array([
		Vector2(0, c_y - 18),
		Vector2(11, c_y - 4),
		Vector2(7, c_y + 12),
		Vector2(-7, c_y + 12),
		Vector2(-11, c_y - 4)
	])
	draw_polygon(pts_outer, PackedColorArray([Color(0.25, 0.65, 0.95, 0.95)]))
	
	# Facet shading
	var pts_inner = PackedVector2Array([
		Vector2(0, c_y - 18),
		Vector2(7, c_y - 4),
		Vector2(0, c_y + 12),
		Vector2(-7, c_y - 4)
	])
	draw_polygon(pts_inner, PackedColorArray([Color(0.55, 0.85, 1.0, 0.95)]))
	draw_polyline(pts_outer, Color(0.9, 0.98, 1.0, 1.0), 1.5)
	
	# Specular sparkle star
	var spk = sin(pulse_time * 6.0) * 0.5 + 0.5
	if spk > 0.4:
		draw_line(Vector2(2, c_y - 10), Vector2(6, c_y - 10), Color(1, 1, 1, spk), 1.5)
		draw_line(Vector2(4, c_y - 12), Vector2(4, c_y - 8), Color(1, 1, 1, spk), 1.5)

func _draw_altar() -> void:
	# Grand Knowledge Temple Hand Altar (Animated 13-frame spritesheet)
	# Sheet is 1014x112, 13 frames of 78x112
	draw_set_transform(Vector2(0, 0), 0.0, Vector2(1.0, 0.45))
	draw_circle(Vector2.ZERO, 38.0, Color(0.01, 0.02, 0.04, 0.6))
	draw_set_transform(Vector2.ZERO)

	if ALTAR_SHEET:
		var frame = int(pulse_time * 6.0) % 13
		var src_rect = Rect2(frame * 78, 0, 78, 112)
		var dest_rect = Rect2(-39, -100, 78, 112)
		draw_texture_rect_region(ALTAR_SHEET, dest_rect, src_rect)

	# Hovering Astra Memory Relic floating in the hand's grasp
	var bob = sin(pulse_time * 2.5) * 5.0
	var r_pos = Vector2(0, -96 + bob)
	
	# Sacred starlight aura
	var r_pulse = sin(pulse_time * 4.0) * 6.0
	draw_circle(r_pos, 28.0 + r_pulse, Color(0.2, 0.6, 1.0, 0.28))
	draw_circle(r_pos, 16.0, Color(0.5, 0.85, 1.0, 0.45))

	# Crystal Shard Relic
	var c_pts = PackedVector2Array([
		r_pos + Vector2(0, -18),
		r_pos + Vector2(10, -3),
		r_pos + Vector2(0, 16),
		r_pos + Vector2(-10, -3)
	])
	draw_polygon(c_pts, PackedColorArray([Color(0.4, 0.8, 1.0, 0.95)]))
	draw_polyline(c_pts, Color(0.9, 0.98, 1.0, 1.0), 2.0)

	# Orbiting Starlight Runes
	var rot = pulse_time * 2.0
	for i in range(3):
		var ang = rot + (TAU / 3.0) * i
		var orbit_p = r_pos + Vector2(cos(ang) * 22.0, sin(ang) * 9.0)
		draw_circle(orbit_p, 3.0, Color(0.85, 0.95, 1.0, 0.9))

func _draw_paper() -> void:
	var pts = PackedVector2Array([
		Vector2(-10, -12),
		Vector2(10, -12),
		Vector2(10, 12),
		Vector2(-10, 12)
	])
	draw_polygon(pts, PackedColorArray([Color(0.95, 0.9, 0.75, 0.9)]))
	draw_line(Vector2(-6, -6), Vector2(6, -6), Color(0.4, 0.35, 0.3), 1.0)
	draw_line(Vector2(-6, 0), Vector2(6, 0), Color(0.4, 0.35, 0.3), 1.0)
	draw_line(Vector2(-6, 6), Vector2(4, 6), Color(0.4, 0.35, 0.3), 1.0)

func _draw_door() -> void:
	# Ancient Stone Archway with glowing runes
	draw_set_transform(Vector2(0, 0), 0.0, Vector2(1.0, 0.4))
	draw_circle(Vector2.ZERO, 36.0, Color(0.01, 0.02, 0.04, 0.5))
	draw_set_transform(Vector2.ZERO)

	# Stone frame
	draw_rect(Rect2(-32, -72, 64, 72), Color(0.18, 0.22, 0.30))
	draw_rect(Rect2(-24, -64, 48, 64), Color(0.06, 0.08, 0.12)) # Dark doorway
	
	# Stone arch lintel
	draw_rect(Rect2(-36, -80, 72, 12), Color(0.25, 0.30, 0.40))
	
	# Rune glow in portal
	var pulse = sin(pulse_time * 3.0) * 0.25 + 0.75
	draw_circle(Vector2(0, -32), 16.0, Color(0.2, 0.6, 1.0, pulse * 0.4))
	draw_circle(Vector2(0, -32), 7.0, Color(0.6, 0.9, 1.0, pulse * 0.9))

func _draw_relief() -> void:
	draw_rect(Rect2(-28, -36, 56, 36), Color(0.18, 0.2, 0.24))
	draw_line(Vector2(-20, -18), Vector2(20, -18), Color(0.4, 0.7, 0.9, 0.7), 2.0)
	draw_circle(Vector2(0, -18), 7.0, Color(0.4, 0.8, 1.0, 0.8))

func _draw_eldrin() -> void:
	if ELDER_TEX:
		var frame = int(pulse_time * 4.0) % 4
		var src_rect = Rect2(frame * 48, 48, 48, 48)
		var dest_rect = Rect2(-30, -60, 60, 60)
		draw_texture_rect_region(ELDER_TEX, dest_rect, src_rect)

func _draw_hollow_knight() -> void:
	var scale_factor = 0.32
	var dest_w = 512.0 * scale_factor
	var dest_h = 512.0 * scale_factor
	var dest_x = -252.0 * scale_factor
	var dest_y = -378.0 * scale_factor
	var dest_rect = Rect2(dest_x, dest_y, dest_w, dest_h)
	
	# Ground contact shadow directly under feet
	draw_set_transform(Vector2(0, 0), 0.0, Vector2(1.0, 0.45))
	draw_circle(Vector2.ZERO, 32.0, Color(0.02, 0.02, 0.04, 0.5))
	draw_set_transform(Vector2.ZERO)
	
	# Spectral crimson guardian aura
	var pulse = sin(pulse_time * 3.5) * 6.0
	draw_circle(Vector2(0, -38), 36.0 + pulse, Color(0.7, 0.15, 0.25, 0.28))
	draw_arc(Vector2(0, -38), 42.0 + pulse, 0, TAU, 32, Color(0.9, 0.3, 0.3, 0.4), 1.5)
	
	if not knight_frames.is_empty():
		var idx = int(pulse_time * 8.0) % knight_frames.size()
		var tex = knight_frames[idx]
		draw_texture_rect(tex, dest_rect, false)
