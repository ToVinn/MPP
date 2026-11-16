@tool
extends Node2D
## TilemapBuilder v2 — ASCII layout menjadi TileMapLayer untuk Echoes of Astra.
##
## Peningkatan v2:
##   - Filter NEAREST (pixel art tajam, tidak blur)
##   - Auto-variasi: tiap tile diberi flip H/V acak + tint halus supaya tidak
##     terlihat seperti wallpaper yang di-copy-paste
##   - Air autotile SHORE: pinggir kolam otomatis diberi bibir rumput,
##     tekstur air menyambung mulus antar tile
##   - Tile dekorasi: E = rumput + jamur, R = rumput + batu
##
## Legenda (1 karakter = 1 tile 64x64 px):
##   .  rumput         d  jalan tanah (tint coklat halus biar beda dari rumput)
##   c  cobble desa    s  lantai gua    b  jembatan
##   p  paver kuil     t  bintang kuil  f  pagar (solid, tidak di-flip)
##   W  air (solid, autotile pinggir)   E  rumput+jamur    R  rumput+batu
##
## Rumah & pohon tetap prefab di bawah node YSort (konsisten dengan scene lain).

const TILE_SIZE := 64
const LAYER_Z_INDEX := -10
const WATER_SHORE := 12 # lebar bibir rumput di pinggir air
const WATER_TINT := Color(0.62, 0.86, 1.08) # tonjolkan biru air
const WHITE := Color(1.0, 1.0, 1.0)

const TILE_DEFS := {
	".": {
		"path": "res://assets/textures/forest_grass.png",
		"tints": [Color(1.0, 1.0, 1.0), Color(1.0, 0.97, 0.87), Color(0.92, 0.99, 0.87)],
	},
	"d": {
		"path": "res://assets/textures/forest_dirt_path.png",
		"tints": [Color(1.0, 1.0, 1.0), Color(1.02, 0.92, 0.76)],
	},
	"c": {
		"path": "res://assets/textures/village_cobble.png",
		"tints": [Color(1.0, 1.0, 1.0), Color(0.93, 0.95, 1.0)],
	},
	"s": {"path": "res://assets/textures/cave_floor_stone.png"},
	"b": {"path": "res://assets/textures/cave_stone_bridge.png"},
	"p": {"path": "res://assets/textures/temple_floor_paver.png"},
	"t": {"path": "res://assets/textures/temple_floor_star.png"},
	"f": {"path": "res://assets/textures/village_fence.png", "collision": true, "flips": false},
	"E": {
		"path": "res://assets/textures/forest_grass.png",
		"overlay": "res://assets/textures/prop_mushrooms.png",
		"overlay_offset": Vector2i(18, 22),
	},
	"R": {
		"path": "res://assets/textures/forest_grass.png",
		"overlay": "res://assets/textures/prop_rock_1.png",
		"overlay_offset": Vector2i(13, 15),
	},
	"W": {
		"path": "res://assets/textures/cave_water_pool.png",
		"collision": true,
		"water": true,
	},
}

@export var ground_layout: PackedStringArray = []

var _tile_set: TileSet
var _layer: TileMapLayer
var _grass_image: Image
var _water_image: Image
var _water_sources := {} # (mask, qx, qy) -> source_id
var _last_signature := ""


func _ready() -> void:
	_rebuild(_signature())


func _process(_delta: float) -> void:
	# Live-rebuild di editor saat layout diubah lewat Inspector.
	if not Engine.is_editor_hint():
		return
	var sig := _signature()
	if sig != _last_signature:
		_rebuild(sig)


func _signature() -> String:
	return "|".join(ground_layout)


func _rebuild(sig: String) -> void:
	_last_signature = sig
	_clear_layers()
	_water_sources = {}
	_load_base_images()

	_tile_set = TileSet.new()
	_tile_set.tile_size = Vector2i(TILE_SIZE, TILE_SIZE)
	_tile_set.add_physics_layer(0)
	_tile_set.set_physics_layer_collision_layer(0, 1)
	_tile_set.set_physics_layer_collision_mask(0, 0)

	var mapping := _create_ground_sources()
	_create_layer()
	_paint(mapping)


func _clear_layers() -> void:
	for child in get_children():
		if child is TileMapLayer:
			remove_child(child)
			child.free()


func _load_base_images() -> void:
	var grass_tex := load("res://assets/textures/forest_grass.png")
	var water_tex := load("res://assets/textures/cave_water_pool.png")
	_grass_image = _to_rgba8(_texture_image(grass_tex))
	_water_image = _to_rgba8(_texture_image(water_tex))


func _texture_image(tex: Texture2D) -> Image:
	var img := tex.get_image()
	return img


func _to_rgba8(img: Image) -> Image:
	if img.get_format() != Image.FORMAT_RGBA8:
		img.convert(Image.FORMAT_RGBA8)
	return img


func _create_ground_sources() -> Dictionary:
	var mapping := {}
	var next_id := 0
	for ch: String in TILE_DEFS:
		var def: Dictionary = TILE_DEFS[ch]
		if bool(def.get("water", false)):
			continue # air dibuat terpisah saat painting (butuh info tetangga)
		var tex := load(def.path)
		if tex == null or not (tex is Texture2D):
			push_warning("TilemapBuilder: tekstur tidak ditemukan -> %s (tile '%s' dilewati)" % [def.path, ch])
			continue

		if def.has("overlay"):
			tex = _compose_prop_tile(tex, def)

		var src := TileSetAtlasSource.new()
		src.texture = tex
		src.texture_region_size = Vector2i(TILE_SIZE, TILE_SIZE)
		_tile_set.add_source(src, next_id)
		src.create_tile(Vector2i.ZERO)
		_add_collision_if_needed(src, def)
		var alts := _create_alt_tiles(src, def)

		mapping[ch] = {"source_id": next_id, "alts": alts}
		next_id += 1
	return mapping


func _compose_prop_tile(base_tex: Texture2D, def: Dictionary) -> ImageTexture:
	# Ground + properti kecil (jamur/batu) digabung jadi 1 tile.
	var base := _to_rgba8(_texture_image(base_tex)).duplicate()
	var overlay_tex := load(def["overlay"])
	var ov := _to_rgba8(_texture_image(overlay_tex)).duplicate()
	base.blend_rect(ov, Rect2i(Vector2i.ZERO, ov.get_size()), def.get("overlay_offset", Vector2i.ZERO))
	return ImageTexture.create_from_image(base)


func _add_collision_if_needed(src: TileSetAtlasSource, def: Dictionary) -> void:
	if not bool(def.get("collision", false)):
		return
	var td := src.get_tile_data(Vector2i.ZERO, 0)
	td.add_collision_polygon(0)
	td.set_collision_polygon_points(0, 0, PackedVector2Array([
		Vector2(1, 1),
		Vector2(TILE_SIZE - 1, 1),
		Vector2(TILE_SIZE - 1, TILE_SIZE - 1),
		Vector2(1, TILE_SIZE - 1),
	]))


func _create_alt_tiles(src: TileSetAtlasSource, def: Dictionary) -> Array:
	# Base tile (id 0) + kombinasi flip H/V x tint -> variasi alami.
	var alts := [0]
	var flips_allowed: bool = bool(def.get("flips", true))
	var tints: Array = def.get("tints", [WHITE])
	var flip_modes := [0] if not flips_allowed else [0, 1, 2, 3]
	for fi: int in flip_modes:
		for tint: Color in tints:
			if fi == 0 and tint == WHITE:
				continue # sama dengan base
			var alt_id := src.create_alternative_tile(Vector2i.ZERO)
			var td := src.get_tile_data(Vector2i.ZERO, alt_id)
			td.flip_h = fi % 2 == 1
			td.flip_v = fi >= 2
			td.modulate = tint
			alts.append(alt_id)
	return alts


func _create_layer() -> void:
	_layer = TileMapLayer.new()
	_layer.name = "GroundLayer"
	_layer.z_index = LAYER_Z_INDEX
	_layer.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST # pixel art tajam
	_layer.tile_set = _tile_set # layer & mask collision diatur lewat TileSet
	add_child(_layer, true) # internal: tidak ikut tersimpan ke .tscn


func _paint(mapping: Dictionary) -> void:
	if ground_layout.is_empty():
		return
	var painted := 0
	var warned := {}
	for row: int in ground_layout.size():
		var line: String = ground_layout[row]
		for col: int in line.length():
			var ch := line[col]
			if ch == "W" and mapping_has_water():
				_paint_water(col, row)
				painted += 1
				continue
			if not mapping.has(ch):
				if not warned.has(ch):
					warned[ch] = true
					push_warning("TilemapBuilder: karakter '%s' tidak dikenal (baris %d)" % [ch, row])
				continue
			var info: Dictionary = mapping[ch]
			var alts: Array = info["alts"]
			var alt: int = alts[_variant_index(col, row) % alts.size()]
			_layer.set_cell(Vector2i(col, row), info["source_id"], Vector2i.ZERO, alt)
			painted += 1
	print("TilemapBuilder: %d tile terpasang (%d baris)" % [painted, ground_layout.size()])


func mapping_has_water() -> bool:
	return _grass_image != null and _water_image != null


func _paint_water(col: int, row: int) -> void:
	# Bitmask pinggir: 1=atas, 2=kanan, 4=bawah, 8=kiri (pinggir = sisi non-air)
	var up := not _is_water(col, row - 1)
	var right := not _is_water(col + 1, row)
	var down := not _is_water(col, row + 1)
	var left := not _is_water(col - 1, row)
	var mask := (1 if up else 0) + (2 if right else 0) + (4 if down else 0) + (8 if left else 0)
	var qx := col % 2 # koheren kuartir tekstur -> air menyambung antar tile
	var qy := row % 2
	var key := "%d_%d_%d" % [mask, qx, qy]
	if not _water_sources.has(key):
		_water_sources[key] = _build_water_source(mask, qx, qy)
	_layer.set_cell(Vector2i(col, row), _water_sources[key], Vector2i.ZERO, 0)


func _is_water(col: int, row: int) -> bool:
	if row < 0 or row >= ground_layout.size():
		return false
	var line: String = ground_layout[row]
	if col < 0 or col >= line.length():
		return false
	return line[col] == "W"


func _build_water_source(mask: int, qx: int, qy: int) -> int:
	# Komposit: dasar rumput + area air yang 'menyusut' dari sisi yang
	# berbatasan dengan daratan -> bibir pantai otomatis tanpa aset baru.
	var img := _grass_image.duplicate()
	var x0 := WATER_SHORE if (mask & 8) else 0
	var y0 := WATER_SHORE if (mask & 1) else 0
	var x1 := TILE_SIZE - (WATER_SHORE if (mask & 2) else 0)
	var y1 := TILE_SIZE - (WATER_SHORE if (mask & 4) else 0)
	var src_off := Vector2i(qx * TILE_SIZE + x0, qy * TILE_SIZE + y0)
	var size_w := Vector2i(x1 - x0, y1 - y0)
	img.blit_rect(_water_image, Rect2i(src_off, size_w), Vector2i(x0, y0))

	var tex := ImageTexture.create_from_image(img)
	var src := TileSetAtlasSource.new()
	src.texture = tex
	src.texture_region_size = Vector2i(TILE_SIZE, TILE_SIZE)
	var source_id := _tile_set.get_next_source_id()
	_tile_set.add_source(src, source_id)
	src.create_tile(Vector2i.ZERO)
	var td := src.get_tile_data(Vector2i.ZERO, 0)
	td.add_collision_polygon(0)
	td.set_collision_polygon_points(0, 0, PackedVector2Array([
		Vector2(1, 1),
		Vector2(TILE_SIZE - 1, 1),
		Vector2(TILE_SIZE - 1, TILE_SIZE - 1),
		Vector2(1, TILE_SIZE - 1),
	]))
	td.modulate = WATER_TINT
	return source_id


func _variant_index(col: int, row: int) -> int:
	# Hash deterministik supaya variasi tersebar alami tapi konsisten.
	return abs(col * 31 + row * 17 + (col * row) % 5)


## Ukuran peta dalam piksel (untuk dinding batas / kamera).
func get_map_pixel_size() -> Vector2i:
	var cols := 0
	for line: String in ground_layout:
		cols = maxi(cols, line.length())
	return Vector2i(cols * TILE_SIZE, ground_layout.size() * TILE_SIZE)
