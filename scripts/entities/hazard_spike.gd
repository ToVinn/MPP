extends Area2D

# Periodic Spike Trap
# Alternates between safe (retracted) and dangerous (extended).
# Player takes damage if walking on extended spikes unless jumping.

@export var cycle_period: float = 3.2
@export var extended_duration: float = 1.3
@export var time_offset: float = 0.0

var current_time: float = 0.0
var is_extended: bool = false
var is_warning: bool = false

func _ready() -> void:
	z_index = -2
	collision_layer = 0
	collision_mask = 2 # Player
	current_time = time_offset
	
	var col = CollisionShape2D.new()
	var box = RectangleShape2D.new()
	box.size = Vector2(48, 48)
	col.shape = box
	add_child(col)
	
	body_entered.connect(_on_body_entered)

func _process(delta: float) -> void:
	current_time += delta
	var cycle = fmod(current_time, cycle_period)
	
	is_warning = (cycle >= cycle_period - extended_duration - 0.5 and cycle < cycle_period - extended_duration)
	is_extended = (cycle >= cycle_period - extended_duration)
	
	if is_extended:
		var bodies = get_overlapping_bodies()
		for b in bodies:
			_damage_body(b)
			
	queue_redraw()

func _on_body_entered(body: Node2D) -> void:
	if is_extended:
		_damage_body(body)

func _damage_body(body: Node2D) -> void:
	if body.is_in_group("player"):
		if "is_airborne" in body and body.is_airborne:
			return # Safe while jumping over spikes
		if body.has_method("take_damage"):
			var kb = (body.global_position - global_position).normalized()
			body.take_damage(1, kb)

func _draw() -> void:
	var r = Rect2(-24, -24, 48, 48)
	
	# Trap base grate
	draw_rect(r, Color(0.15, 0.16, 0.18))
	draw_rect(r, Color(0.3, 0.32, 0.36), false, 2.0)
	
	# Spike holes
	var holes = [
		Vector2(-12, -12), Vector2(12, -12),
		Vector2(0, 0),
		Vector2(-12, 12), Vector2(12, 12)
	]
	for h in holes:
		draw_circle(h, 4.0, Color(0.05, 0.05, 0.06))
	
	# Warning glow
	if is_warning:
		var flash = sin(current_time * 20.0) * 0.3 + 0.4
		draw_rect(r, Color(0.9, 0.3, 0.1, flash), false, 3.0)
	
	# Extended spikes
	if is_extended:
		for h in holes:
			var pts = PackedVector2Array([
				h + Vector2(-4, 4),
				h + Vector2(0, -10),
				h + Vector2(4, 4)
			])
			draw_polygon(pts, PackedColorArray([Color(0.8, 0.82, 0.88)]))
			draw_polyline(pts, Color(1.0, 0.2, 0.2), 1.0)

