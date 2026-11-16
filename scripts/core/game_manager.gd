extends Node

# Central Game Manager for Echoes of Astra
# Manages game state, memory points, save/load, and scene transitions

const SAVE_PATH = "user://echoes_of_astra_save.json"

# Core Story State
var memory_points: int = 0
var current_chapter: String = "prologue"

# Quest Flags
var has_prologue_crystal: bool = false
var spoke_with_eldrin: bool = false

var q1_fragments_collected: int = 0
var q1_puzzle_solved: bool = false
var q1_choice: String = ""

var q2_pages_collected: int = 0
var q2_puzzle_solved: bool = false
var q2_choice: String = ""

var q3_hollow_knight_spoken: bool = false
var q3_puzzle_solved: bool = false
var q3_choice: String = ""

# Transition overlay
var transition_rect: ColorRect
var is_transitioning: bool = false

signal memory_points_changed(new_points: int)
signal chapter_changed(new_chapter: String)

static func create_light_texture(radius: int = 128) -> GradientTexture2D:
	var grad = Gradient.new()
	grad.colors = PackedColorArray([Color(1, 1, 1, 1), Color(1, 1, 1, 0.45), Color(1, 1, 1, 0)])
	grad.offsets = PackedFloat32Array([0.0, 0.45, 1.0])
	var tex = GradientTexture2D.new()
	tex.gradient = grad
	tex.fill = GradientTexture2D.FILL_RADIAL
	tex.fill_from = Vector2(0.5, 0.5)
	tex.fill_to = Vector2(1.0, 0.5)
	tex.width = radius * 2
	tex.height = radius * 2
	return tex

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_setup_inputs()
	_create_transition_overlay()

func _setup_inputs() -> void:
	if not InputMap.has_action("move_left"):
		InputMap.add_action("move_left")
		var ev_a = InputEventKey.new()
		ev_a.physical_keycode = KEY_A
		InputMap.action_add_event("move_left", ev_a)
		var ev_left = InputEventKey.new()
		ev_left.physical_keycode = KEY_LEFT
		InputMap.action_add_event("move_left", ev_left)
		
	if not InputMap.has_action("move_right"):
		InputMap.add_action("move_right")
		var ev_d = InputEventKey.new()
		ev_d.physical_keycode = KEY_D
		InputMap.action_add_event("move_right", ev_d)
		var ev_right = InputEventKey.new()
		ev_right.physical_keycode = KEY_RIGHT
		InputMap.action_add_event("move_right", ev_right)
		
	if not InputMap.has_action("move_up"):
		InputMap.add_action("move_up")
		var ev_w = InputEventKey.new()
		ev_w.physical_keycode = KEY_W
		InputMap.action_add_event("move_up", ev_w)
		var ev_up = InputEventKey.new()
		ev_up.physical_keycode = KEY_UP
		InputMap.action_add_event("move_up", ev_up)

	if not InputMap.has_action("move_down"):
		InputMap.add_action("move_down")
		var ev_s = InputEventKey.new()
		ev_s.physical_keycode = KEY_S
		InputMap.action_add_event("move_down", ev_s)
		var ev_down = InputEventKey.new()
		ev_down.physical_keycode = KEY_DOWN
		InputMap.action_add_event("move_down", ev_down)

	if not InputMap.has_action("interact"):
		InputMap.add_action("interact")
		var ev_e = InputEventKey.new()
		ev_e.physical_keycode = KEY_E
		InputMap.action_add_event("interact", ev_e)

	if not InputMap.has_action("jump"):
		InputMap.add_action("jump")
		var ev_space = InputEventKey.new()
		ev_space.physical_keycode = KEY_SPACE
		InputMap.action_add_event("jump", ev_space)
		var ev_c = InputEventKey.new()
		ev_c.physical_keycode = KEY_C
		InputMap.action_add_event("jump", ev_c)

	if not InputMap.has_action("attack"):
		InputMap.add_action("attack")
		var ev_j = InputEventKey.new()
		ev_j.physical_keycode = KEY_J
		InputMap.action_add_event("attack", ev_j)
		var ev_k = InputEventKey.new()
		ev_k.physical_keycode = KEY_K
		InputMap.action_add_event("attack", ev_k)
		var ev_click = InputEventMouseButton.new()
		ev_click.button_index = MOUSE_BUTTON_LEFT
		InputMap.action_add_event("attack", ev_click)

	if not InputMap.has_action("dash"):
		InputMap.add_action("dash")
		var ev_shift = InputEventKey.new()
		ev_shift.physical_keycode = KEY_SHIFT
		InputMap.action_add_event("dash", ev_shift)

	if not InputMap.has_action("pause_game"):
		InputMap.add_action("pause_game")
		var ev_esc = InputEventKey.new()
		ev_esc.physical_keycode = KEY_ESCAPE
		InputMap.action_add_event("pause_game", ev_esc)

func _create_transition_overlay() -> void:
	var canvas = CanvasLayer.new()
	canvas.layer = 120
	add_child(canvas)
	
	transition_rect = ColorRect.new()
	transition_rect.color = Color(0, 0, 0, 0)
	transition_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	transition_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	canvas.add_child(transition_rect)

func add_memory_point(reason: String = "") -> void:
	memory_points += 1
	memory_points_changed.emit(memory_points)
	print("[GameManager] Memory Point Added! Total: ", memory_points, " (", reason, ")")

func set_chapter(chapter_name: String) -> void:
	current_chapter = chapter_name
	chapter_changed.emit(current_chapter)

func change_scene(scene_path: String, fade_duration: float = 0.5) -> void:
	if is_transitioning:
		return
	is_transitioning = true
	transition_rect.mouse_filter = Control.MOUSE_FILTER_STOP
	
	var tween = create_tween()
	tween.tween_property(transition_rect, "color:a", 1.0, fade_duration)
	await tween.finished
	
	get_tree().change_scene_to_file(scene_path)
	
	await get_tree().process_frame
	await get_tree().create_timer(0.1).timeout
	
	var tween_in = create_tween()
	tween_in.tween_property(transition_rect, "color:a", 0.0, fade_duration)
	await tween_in.finished
	
	transition_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	is_transitioning = false

func evaluate_ending() -> void:
	print("[GameManager] Evaluating ending. Total Memory Points: ", memory_points)
	if memory_points >= 3:
		change_scene("res://scenes/endings/ending_good.tscn", 1.0)
	else:
		change_scene("res://scenes/endings/ending_bad.tscn", 1.0)

func save_game() -> bool:
	var data = {
		"memory_points": memory_points,
		"current_chapter": current_chapter,
		"has_prologue_crystal": has_prologue_crystal,
		"spoke_with_eldrin": spoke_with_eldrin,
		"q1_fragments_collected": q1_fragments_collected,
		"q1_puzzle_solved": q1_puzzle_solved,
		"q1_choice": q1_choice,
		"q2_pages_collected": q2_pages_collected,
		"q2_puzzle_solved": q2_puzzle_solved,
		"q2_choice": q2_choice,
		"q3_hollow_knight_spoken": q3_hollow_knight_spoken,
		"q3_puzzle_solved": q3_puzzle_solved,
		"q3_choice": q3_choice
	}
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		var json_string = JSON.stringify(data, "  ")
		file.store_string(json_string)
		file.close()
		print("[GameManager] Game saved successfully.")
		return true
	return false

func load_game() -> bool:
	if not FileAccess.file_exists(SAVE_PATH):
		return false
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not file:
		return false
	var content = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var error = json.parse(content)
	if error != OK:
		return false
	
	var data = json.data
	memory_points = data.get("memory_points", 0)
	current_chapter = data.get("current_chapter", "prologue")
	has_prologue_crystal = data.get("has_prologue_crystal", false)
	spoke_with_eldrin = data.get("spoke_with_eldrin", false)
	q1_fragments_collected = data.get("q1_fragments_collected", 0)
	q1_puzzle_solved = data.get("q1_puzzle_solved", false)
	q1_choice = data.get("q1_choice", "")
	q2_pages_collected = data.get("q2_pages_collected", 0)
	q2_puzzle_solved = data.get("q2_puzzle_solved", false)
	q2_choice = data.get("q2_choice", "")
	q3_hollow_knight_spoken = data.get("q3_hollow_knight_spoken", false)
	q3_puzzle_solved = data.get("q3_puzzle_solved", false)
	q3_choice = data.get("q3_choice", "")
	
	print("[GameManager] Game loaded. Chapter: ", current_chapter, ", Memory Points: ", memory_points)
	
	# Resume to corresponding chapter
	match current_chapter:
		"prologue":
			change_scene("res://scenes/ch0_prologue.tscn")
		"quest1":
			change_scene("res://scenes/quests/ch1_quest1_cave.tscn")
		"quest2":
			change_scene("res://scenes/quests/ch2_quest2_village.tscn")
		"quest3":
			change_scene("res://scenes/quests/ch3_quest3_temple.tscn")
		_:
			change_scene("res://scenes/ch0_prologue.tscn")
	return true

func has_save_file() -> bool:
	return FileAccess.file_exists(SAVE_PATH)

func reset_game() -> void:
	memory_points = 0
	current_chapter = "prologue"
	has_prologue_crystal = false
	spoke_with_eldrin = false
	q1_fragments_collected = 0
	q1_puzzle_solved = false
	q1_choice = ""
	q2_pages_collected = 0
	q2_puzzle_solved = false
	q2_choice = ""
	q3_hollow_knight_spoken = false
	q3_puzzle_solved = false
	q3_choice = ""
