extends Area2D

# Pressure Plate Puzzle Switch
# Activates when player stands on it, deactivates when stepping off

signal plate_activated
signal plate_deactivated

@export var plate_id: String = "plate_1"
@export var is_permanent: bool = false # Stays pressed once activated

var is_pressed: bool = false

func _ready() -> void:
	z_index = -3
	collision_layer = 0
	collision_mask = 2 # Player
	
	var col = CollisionShape2D.new()
	var box = RectangleShape2D.new()
	box.size = Vector2(40, 40)
	col.shape = box
	add_child(col)
	
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and not is_pressed:
		is_pressed = true
		SoundManager.play_step_puzzle()
		plate_activated.emit()
		queue_redraw()

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player") and is_pressed and not is_permanent:
		is_pressed = false
		plate_deactivated.emit()
		queue_redraw()

func _draw() -> void:
	var r = Rect2(-20, -20, 40, 40)
	
	# Outer stone rim
	draw_rect(r, Color(0.2, 0.22, 0.25))
	draw_rect(r, Color(0.35, 0.38, 0.42), false, 2.0)
	
	# Plate core (depressed when pressed)
	var inner_r = r.grow(-4.0) if not is_pressed else r.grow(-7.0)
	var core_color = Color(0.3, 0.7, 1.0, 0.85) if is_pressed else Color(0.28, 0.3, 0.34)
	draw_rect(inner_r, core_color)
	
	if is_pressed:
		draw_rect(inner_r, Color(0.8, 0.95, 1.0, 0.9), false, 1.5)

