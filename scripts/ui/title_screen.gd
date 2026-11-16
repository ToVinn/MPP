extends Control

@onready var new_game_btn: Button = %NewGameBtn
@onready var continue_btn: Button = %ContinueBtn
@onready var controls_btn: Button = %ControlsBtn
@onready var tilemap_demo_btn: Button = %TilemapDemoBtn
@onready var quit_btn: Button = %QuitBtn
@onready var controls_popup: PanelContainer = %ControlsPopup
@onready var close_controls_btn: Button = %CloseControlsBtn

var time: float = 0.0

func _ready() -> void:
	controls_popup.visible = false
	continue_btn.disabled = not GameManager.has_save_file()
	
	new_game_btn.pressed.connect(_on_new_game_pressed)
	continue_btn.pressed.connect(_on_continue_pressed)
	controls_btn.pressed.connect(_on_controls_pressed)
	tilemap_demo_btn.pressed.connect(_on_tilemap_demo_pressed)
	quit_btn.pressed.connect(_on_quit_pressed)
	close_controls_btn.pressed.connect(func(): controls_popup.visible = false)
	
	new_game_btn.grab_focus()
	SoundManager.play_bell()

func _process(delta: float) -> void:
	time += delta
	queue_redraw()

func _on_new_game_pressed() -> void:
	SoundManager.play_select()
	GameManager.reset_game()
	GameManager.change_scene("res://scenes/ch0_prologue.tscn", 0.8)

func _on_continue_pressed() -> void:
	SoundManager.play_select()
	GameManager.load_game()

func _on_controls_pressed() -> void:
	SoundManager.play_select()
	controls_popup.visible = true

func _on_tilemap_demo_pressed() -> void:
	SoundManager.play_select()
	GameManager.change_scene("res://scenes/demo_village_tilemap.tscn", 0.5)

func _on_quit_pressed() -> void:
	get_tree().quit()

func _draw() -> void:
	var w = size.x
	var h = size.y
	if w <= 0 or h <= 0:
		return
		
	# Dark twilight cosmic gradient
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.04, 0.06, 0.12))
	
	# Twinkling celestial stars
	for i in range(40):
		var sx = fmod(i * 97.0, w)
		var sy = fmod(i * 61.0, h * 0.7)
		var tw = sin(time * 3.0 + i) * 0.5 + 0.5
		draw_circle(Vector2(sx, sy), 1.5 * tw + 1.0, Color(0.6, 0.8, 1.0, tw * 0.8))
		
	# Giant Astral Constellation Ring
	var center = Vector2(w * 0.5, h * 0.38)
	var pulse = sin(time * 1.5) * 8.0
	draw_circle(center, 140.0 + pulse, Color(0.2, 0.5, 0.9, 0.08))
	draw_arc(center, 120.0, 0, TAU, 64, Color(0.3, 0.65, 1.0, 0.35), 2.0)
	
	# Floating Astra Blue Crystal
	var cpts = PackedVector2Array([
		center + Vector2(0, -60),
		center + Vector2(25, -15),
		center + Vector2(15, 45),
		center + Vector2(-15, 45),
		center + Vector2(-25, -15)
	])
	draw_polygon(cpts, PackedColorArray([Color(0.3, 0.65, 1.0, 0.85)]))
	draw_polyline(cpts, Color(0.85, 0.95, 1.0, 0.95), 2.0)
