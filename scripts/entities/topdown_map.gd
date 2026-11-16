extends Node2D

# Echoes of Astra - Master Top-Down Terrain Renderer
# Renders rich, seamless tiled pixel-art ground terrain (grass, dirt, cobblestone, cave stone, water, temple marble)
# All structures (houses, trees, rocks, pillars) are real Y-sorted physics objects in the scene!

@export_enum("forest_village", "crystal_cave", "ruined_village", "ancient_temple") var map_type: String = "forest_village"
@export var map_size: Vector2 = Vector2(2752, 1536)

var grass_tex: Texture2D
var dirt_tex: Texture2D
var cobble_tex: Texture2D
var cave_stone_tex: Texture2D
var cave_water_tex: Texture2D
var temple_paver_tex: Texture2D
var temple_star_tex: Texture2D

var anim_time: float = 0.0

func _ready() -> void:
	z_index = -10 # Stays strictly below all Y-sorted characters, trees, and buildings
	_load_textures()

func _load_textures() -> void:
	grass_tex = _load_texture_safe("res://assets/textures/forest_grass.png")
	dirt_tex = _load_texture_safe("res://assets/textures/forest_dirt_path.png")
	cobble_tex = _load_texture_safe("res://assets/textures/village_cobble.png")
	cave_stone_tex = _load_texture_safe("res://assets/textures/cave_floor_stone.png")
	cave_water_tex = _load_texture_safe("res://assets/textures/cave_water_pool.png")
	temple_paver_tex = _load_texture_safe("res://assets/textures/temple_floor_paver.png")
	temple_star_tex = _load_texture_safe("res://assets/textures/temple_floor_star.png")

func _load_texture_safe(res_path: String) -> Texture2D:
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

func _process(delta: float) -> void:
	anim_time += delta
	# Subtle water shimmer
	queue_redraw()

func _draw() -> void:
	match map_type:
		"forest_village":
			_draw_forest_village()
		"crystal_cave":
			_draw_crystal_cave()
		"ruined_village":
			_draw_ruined_village()
		"ancient_temple":
			_draw_ancient_temple()
		_:
			_draw_forest_village()

# 1. PROLOGUE: DESA ASTRA & THE WHISPERING FOREST
func _draw_forest_village() -> void:
	# A. Lush Forest Grass Base
	if grass_tex:
		draw_texture_rect(grass_tex, Rect2(Vector2.ZERO, map_size), true, Color(0.9, 0.95, 0.88))
	else:
		draw_rect(Rect2(Vector2.ZERO, map_size), Color(0.18, 0.28, 0.16))
		
	# B. Winding Dirt Roads
	if dirt_tex:
		# Main West-to-East Road through forest
		draw_texture_rect(dirt_tex, Rect2(100, 720, 1050, 110), true, Color(0.95, 0.9, 0.82))
		# Connecting fork to south clearing
		draw_texture_rect(dirt_tex, Rect2(280, 720, 90, 420), true, Color(0.95, 0.9, 0.82))
		# Fork to river dock
		draw_texture_rect(dirt_tex, Rect2(880, 780, 270, 320), true, Color(0.95, 0.9, 0.82))
		# Road continuing from bridge into village
		draw_texture_rect(dirt_tex, Rect2(1250, 1050, 250, 90), true, Color(0.95, 0.9, 0.82))
		# Village Eastern Road toward cave portal
		draw_texture_rect(dirt_tex, Rect2(2150, 710, 550, 100), true, Color(0.95, 0.9, 0.82))

	# C. River Canal (running vertically at x ≈ 1150 to 1250)
	var water_rect = Rect2(1150, 0, 100, map_size.y)
	if cave_water_tex:
		var wave_mod = Color(0.4, 0.7, 0.95, 0.9)
		draw_texture_rect(cave_water_tex, water_rect, true, wave_mod)
	else:
		draw_rect(water_rect, Color(0.12, 0.35, 0.58))
	# River banks / grassy borders
	draw_line(Vector2(1150, 0), Vector2(1150, map_size.y), Color(0.15, 0.22, 0.12), 4.0)
	draw_line(Vector2(1250, 0), Vector2(1250, map_size.y), Color(0.15, 0.22, 0.12), 4.0)
	
	# D. Wooden Pier / Bridge Platform across river (x: 1140 to 1260, y: 1040 to 1160)
	# (Leaves a central gap for the parkour jump chasm!)
	var wood_col = Color(0.42, 0.28, 0.18)
	var plank_col = Color(0.32, 0.20, 0.12)
	# Left pier
	draw_rect(Rect2(1130, 1045, 45, 95), wood_col)
	draw_rect(Rect2(1130, 1045, 45, 95), plank_col, false, 2.0)
	# Right pier
	draw_rect(Rect2(1225, 1045, 45, 95), wood_col)
	draw_rect(Rect2(1225, 1045, 45, 95), plank_col, false, 2.0)

	# E. Village Cobblestone Plaza & Alleys
	if cobble_tex:
		# Central square
		draw_texture_rect(cobble_tex, Rect2(1400, 480, 750, 550), true, Color(0.95, 0.95, 0.95))
		# North alleyway
		draw_texture_rect(cobble_tex, Rect2(1580, 250, 180, 250), true, Color(0.95, 0.95, 0.95))
		# South market strip
		draw_texture_rect(cobble_tex, Rect2(1520, 1010, 420, 220), true, Color(0.95, 0.95, 0.95))
	
	# F. Village Center Stone Well Platform
	draw_circle(Vector2(1780, 750), 38.0, Color(0.35, 0.38, 0.42))
	draw_circle(Vector2(1780, 750), 30.0, Color(0.1, 0.25, 0.45))
	draw_circle(Vector2(1780, 750), 38.0, Color(0.2, 0.22, 0.26), false, 3.0)

# 2. QUEST 1: GUA KRISTAL (CRYSTAL CAVE)
func _draw_crystal_cave() -> void:
	# A. Rugged Cavern Stone Floor
	if cave_stone_tex:
		draw_texture_rect(cave_stone_tex, Rect2(Vector2.ZERO, map_size), true, Color(0.65, 0.7, 0.8))
	else:
		draw_rect(Rect2(Vector2.ZERO, map_size), Color(0.08, 0.09, 0.12))

	# B. Subterranean Bioluminescent Lake & Streams
	var water_p1 = Rect2(500, 620, 480, 360)
	if cave_water_tex:
		var glow_pulse = sin(anim_time * 2.0) * 0.05
		var w_col = Color(0.3, 0.65 + glow_pulse, 0.95, 0.88)
		draw_texture_rect(cave_water_tex, water_p1, true, w_col)
		draw_texture_rect(cave_water_tex, Rect2(1400, 900, 520, 280), true, w_col)
	# Glowing water shoreline
	draw_rect(water_p1, Color(0.2, 0.7, 1.0, 0.35), false, 4.0)

	# C. Carved Stone Walkways
	if cobble_tex:
		# Entrance to north grotto
		draw_texture_rect(cobble_tex, Rect2(200, 140, 950, 130), true, Color(0.5, 0.55, 0.65, 0.85))
		# Connecting descending ramp
		draw_texture_rect(cobble_tex, Rect2(980, 240, 150, 480), true, Color(0.5, 0.55, 0.65, 0.85))
		# Southern corridor to altar
		draw_texture_rect(cobble_tex, Rect2(1050, 680, 800, 120), true, Color(0.5, 0.55, 0.65, 0.85))
		draw_texture_rect(cobble_tex, Rect2(1850, 380, 150, 420), true, Color(0.5, 0.55, 0.65, 0.85))
		draw_texture_rect(cobble_tex, Rect2(1950, 380, 650, 120), true, Color(0.5, 0.55, 0.65, 0.85))

	# D. Ancient Chasm Bridge Foundation
	draw_rect(Rect2(1700, 930, 120, 80), Color(0.25, 0.28, 0.32))
	draw_rect(Rect2(1700, 930, 120, 80), Color(0.12, 0.15, 0.18), false, 2.0)

# 3. QUEST 2: DESA YANG TERLUPAKAN (RUINED VILLAGE)
func _draw_ruined_village() -> void:
	# A. Dark Desaturated Soil with Patches of Dead Weeds
	if grass_tex:
		draw_texture_rect(grass_tex, Rect2(Vector2.ZERO, map_size), true, Color(0.38, 0.40, 0.32))
	else:
		draw_rect(Rect2(Vector2.ZERO, map_size), Color(0.12, 0.13, 0.10))

	# B. Overgrown Cracked Cobblestone Paths
	if cobble_tex:
		var c_tint = Color(0.52, 0.48, 0.44, 0.85)
		draw_texture_rect(cobble_tex, Rect2(150, 700, 2450, 120), true, c_tint)
		draw_texture_rect(cobble_tex, Rect2(650, 320, 150, 800), true, c_tint)
		draw_texture_rect(cobble_tex, Rect2(1350, 220, 200, 900), true, c_tint)
		draw_texture_rect(cobble_tex, Rect2(1950, 320, 150, 800), true, c_tint)

	# C. Desecrated Town Plaza with Dried Fountain
	draw_circle(Vector2(1450, 760), 75.0, Color(0.22, 0.20, 0.22))
	draw_circle(Vector2(1450, 760), 60.0, Color(0.12, 0.11, 0.14))
	draw_circle(Vector2(1450, 760), 75.0, Color(0.35, 0.30, 0.28), false, 3.5)

# 4. QUEST 3: KUIL ASTRA (ANCIENT TEMPLE)
func _draw_ancient_temple() -> void:
	# A. Sacred Marble Paver Base
	if temple_paver_tex:
		draw_texture_rect(temple_paver_tex, Rect2(Vector2.ZERO, map_size), true, Color(0.85, 0.88, 0.95))
	else:
		draw_rect(Rect2(Vector2.ZERO, map_size), Color(0.15, 0.16, 0.22))

	# B. Reflecting Waterways (Flanks)
	var pool_l = Rect2(350, 250, 220, 1050)
	var pool_r = Rect2(2180, 250, 220, 1050)
	if cave_water_tex:
		var p_tint = Color(0.2, 0.55, 0.85, 0.8)
		draw_texture_rect(cave_water_tex, pool_l, true, p_tint)
		draw_texture_rect(cave_water_tex, pool_r, true, p_tint)
	draw_rect(pool_l, Color(0.65, 0.75, 0.9, 0.5), false, 3.0)
	draw_rect(pool_r, Color(0.65, 0.75, 0.9, 0.5), false, 3.0)

	# C. Central Grand Nave - Tiled with Celestial Star Paver
	var nave_rect = Rect2(1100, 150, 550, 1250)
	if temple_star_tex:
		draw_texture_rect(temple_star_tex, nave_rect, true, Color(1.0, 0.98, 0.9))
	else:
		draw_rect(nave_rect, Color(0.25, 0.28, 0.38))
	
	# Ornamental Golden Inlay Lines
	draw_line(Vector2(1100, 150), Vector2(1100, 1400), Color(0.85, 0.72, 0.35), 3.0)
	draw_line(Vector2(1650, 150), Vector2(1650, 1400), Color(0.85, 0.72, 0.35), 3.0)

	# D. Boss Arena Ring & Dais
	var arena_c = Vector2(1375, 920)
	var pulse = sin(anim_time * 2.5) * 3.0
	draw_circle(arena_c, 160.0 + pulse, Color(0.3, 0.15, 0.45, 0.25))
	draw_arc(arena_c, 150.0, 0, TAU, 48, Color(0.85, 0.72, 0.35, 0.8), 2.5)
	draw_arc(arena_c, 120.0, 0, TAU, 40, Color(0.4, 0.7, 1.0, 0.5), 1.5)
	
	# E. Sacred Altar Sanctuary at North
	var altar_c = Vector2(1375, 230)
	draw_circle(altar_c, 110.0, Color(0.2, 0.45, 0.85, 0.28))
	draw_arc(altar_c, 95.0, 0, TAU, 36, Color(0.85, 0.72, 0.35, 0.9), 2.5)
