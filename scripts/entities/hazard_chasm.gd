extends Area2D

# Chasm / Void Pit Obstacle
# Tests player's parkour jumping ability:
# Player must leap across using [Space / Jump]. Walking into it causes a fall and reset.

@export var chasm_size: Vector2 = Vector2(120, 80)
@export var pushback_offset: Vector2 = Vector2(-40, 0)

var anim_pulse: float = 0.0

func _ready() -> void:
	z_index = -5 # Under entities
	collision_layer = 0
	collision_mask = 2 # Player
	
	var col = CollisionShape2D.new()
	var box = RectangleShape2D.new()
	box.size = chasm_size
	col.shape = box
	add_child(col)
	
	body_entered.connect(_on_body_entered)

func _process(delta: float) -> void:
	anim_pulse += delta
	queue_redraw()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		# Check if player is airborne (jumping)
		if "is_airborne" in body and body.is_airborne:
			# Successfully leaped over chasm!
			return
		
		# Player fell into chasm!
		if body.has_method("take_damage"):
			var safe_pos = global_position + pushback_offset
			body.take_damage(1, (safe_pos - global_position).normalized())
			body.global_position = safe_pos

func _draw() -> void:
	var rect = Rect2(-chasm_size.x / 2.0, -chasm_size.y / 2.0, chasm_size.x, chasm_size.y)
	
	# Deep dark void abyss
	draw_rect(rect, Color(0.02, 0.03, 0.05, 1.0))
	
	# Inner deep shadows
	var inner_rect = rect.grow(-4.0)
	draw_rect(inner_rect, Color(0.0, 0.0, 0.0, 1.0))
	
	# Cracked abyss rim
	draw_rect(rect, Color(0.18, 0.22, 0.28, 0.8), false, 2.5)
	
	# Ethereal mist shimmer in the depths
	var pulse = sin(anim_pulse * 3.0) * 0.15 + 0.3
	draw_circle(Vector2.ZERO, chasm_size.y * 0.25, Color(0.1, 0.3, 0.5, pulse * 0.4))

