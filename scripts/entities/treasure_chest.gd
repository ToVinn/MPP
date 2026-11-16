extends Area2D

# Ancient Treasure Chest
# Interactive chest that awards Vitality Elixir (heals Aren) and Astra lore

signal chest_opened

@export var chest_id: String = "chest_1"
@export var reward_heal: int = 2
@export var lore_message: String = "★ Memperoleh Elixir Vitalitas! Memulihkan 2 Hati Darah!"

var is_opened: bool = false
var anim_pulse: float = 0.0

func _ready() -> void:
	z_index = 0
	add_to_group("interactable")
	collision_layer = 4
	collision_mask = 0

func _process(delta: float) -> void:
	if not is_opened:
		anim_pulse += delta
		queue_redraw()

func get_prompt() -> String:
	return "[E] Buka Peti Kuno" if not is_opened else ""

func interact(player: Node) -> void:
	if is_opened:
		return
		
	is_opened = true
	SoundManager.play_puzzle_success()
	
	# Heal player
	if player and "current_hp" in player and "max_hp" in player:
		player.current_hp = mini(player.max_hp, player.current_hp + reward_heal)
		if player.has_signal("health_changed"):
			player.health_changed.emit(player.current_hp, player.max_hp)
	
	# Notify HUD
	var hud = get_tree().get_first_node_in_group("hud")
	if not hud:
		var huds = get_tree().root.find_children("HUD", "CanvasLayer", true, false)
		if not huds.is_empty():
			hud = huds[0]
	if hud and hud.has_method("show_notification"):
		hud.show_notification(lore_message)
		
	chest_opened.emit()
	queue_redraw()

func _draw() -> void:
	# Ground shadow
	draw_set_transform(Vector2(0, 0), 0.0, Vector2(1.0, 0.45))
	draw_circle(Vector2.ZERO, 22.0, Color(0.01, 0.02, 0.03, 0.4))
	draw_set_transform(Vector2.ZERO)
	
	# Chest Base Box
	var base_r = Rect2(-18, -24, 36, 24)
	draw_rect(base_r, Color(0.32, 0.22, 0.12)) # Dark wood
	draw_rect(base_r, Color(0.75, 0.6, 0.25), false, 2.0) # Gold trim
	
	if not is_opened:
		# Closed Lid
		var lid_r = Rect2(-20, -34, 40, 12)
		draw_rect(lid_r, Color(0.42, 0.28, 0.16))
		draw_rect(lid_r, Color(0.85, 0.7, 0.3), false, 2.0)
		
		# Golden Keyhole Lock
		draw_circle(Vector2(0, -18), 3.5, Color(1.0, 0.85, 0.35))
		
		# Subtle treasure shimmer glow
		var pulse = sin(anim_pulse * 4.0) * 0.15 + 0.2
		draw_circle(Vector2(0, -22), 16.0, Color(1.0, 0.85, 0.3, pulse))
	else:
		# Open Lid tilted back
		var lid_r = Rect2(-20, -42, 40, 10)
		draw_rect(lid_r, Color(0.35, 0.22, 0.12))
		draw_rect(lid_r, Color(0.75, 0.6, 0.25), false, 2.0)
		
		# Golden interior glow radiating treasure light
		draw_rect(Rect2(-14, -22, 28, 12), Color(1.0, 0.9, 0.4, 0.85))
		draw_circle(Vector2(0, -20), 12.0, Color(1.0, 0.85, 0.2, 0.4))

