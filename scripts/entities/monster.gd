extends CharacterBody2D

# Echoes of Astra - Themed Monster System
# Features 3 distinct, beautiful stylized monster archetypes matching each chapter:
# 1. "crystal_golem"  - Bioluminescent crystal elemental (Quest 1: Gua Kristal)
# 2. "shadow_spectre" - Corrupted phantom wisp of the Silent Eclipse (Quest 2: Desa yang Terlupakan)
# 3. "astral_sentinel"- Sacred celestial construct (Quest 3: Kuil Astra)

enum State { IDLE, PATROL, CHASE, ATTACK, HURT, DEAD }

@export_enum("crystal_golem", "shadow_spectre", "astral_sentinel") var monster_type: String = "crystal_golem"
@export var max_hp: int = 3
@export var speed: float = 95.0
@export var chase_speed: float = 145.0
@export var detection_range: float = 220.0
@export var attack_range: float = 52.0
@export var attack_damage: int = 1
@export var patrol_radius: float = 130.0
@export var attack_cooldown_time: float = 1.3

signal monster_died(monster: Node)

var hp: int = 3
var state: State = State.IDLE
var player_ref: CharacterBody2D = null
var home_position: Vector2 = Vector2.ZERO
var patrol_target: Vector2 = Vector2.ZERO
var idle_timer: float = 0.0
var attack_cooldown: float = 0.0
var hurt_timer: float = 0.0
var death_timer: float = 0.0
var anim_time: float = 0.0
var flash_timer: float = 0.0
var facing_left: bool = false
var lunge_vector: Vector2 = Vector2.ZERO

static var sphere_tex_1: Texture2D = null
static var sphere_tex_2: Texture2D = null
static var sphere_tex_3: Texture2D = null

static func _load_tex_safe(res_path: String) -> Texture2D:
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
	collision_layer = 8  # Monster layer
	collision_mask = 1   # Collide with world boundaries
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
	hp = max_hp
	home_position = global_position
	
	if sphere_tex_1 == null:
		sphere_tex_1 = _load_tex_safe("res://Model/Kuil Kuno/KNOWLEDGE TEMPLE/Structures & Details/Brain Sphere 1 Sheet.png")
	if sphere_tex_2 == null:
		sphere_tex_2 = _load_tex_safe("res://Model/Kuil Kuno/KNOWLEDGE TEMPLE/Structures & Details/Brain Sphere 2 Sheet.png")
	if sphere_tex_3 == null:
		sphere_tex_3 = _load_tex_safe("res://Model/Kuil Kuno/KNOWLEDGE TEMPLE/Structures & Details/Brain Sphere 3 Sheet.png")
	
	add_to_group("monsters")
	
	# Setup collision shape
	if not has_node("CollisionShape2D"):
		var col = CollisionShape2D.new()
		col.name = "CollisionShape2D"
		var circle = CircleShape2D.new()
		circle.radius = 16.0
		col.shape = circle
		col.position = Vector2(0, -6)
		add_child(col)
		
	# Setup hurtbox area for player sword attacks
	if not has_node("Hurtbox"):
		var hbox = Area2D.new()
		hbox.name = "Hurtbox"
		hbox.collision_layer = 16
		hbox.collision_mask = 0
		hbox.add_to_group("monster_hurtbox")
		var hshape = CollisionShape2D.new()
		var hcircle = CircleShape2D.new()
		hcircle.radius = 26.0
		hshape.shape = hcircle
		hshape.position = Vector2(0, -18)
		hbox.add_child(hshape)
		add_child(hbox)
		
	_pick_patrol_target()

func _physics_process(delta: float) -> void:
	anim_time += delta
	
	if flash_timer > 0:
		flash_timer -= delta
	
	if attack_cooldown > 0:
		attack_cooldown -= delta
	
	# Locate player reference
	if not is_instance_valid(player_ref):
		var players = get_tree().get_nodes_in_group("player")
		if not players.is_empty():
			player_ref = players[0]
	
	match state:
		State.IDLE:
			_process_idle(delta)
		State.PATROL:
			_process_patrol(delta)
		State.CHASE:
			_process_chase(delta)
		State.ATTACK:
			_process_attack(delta)
		State.HURT:
			_process_hurt(delta)
		State.DEAD:
			_process_dead(delta)
	
	if state != State.DEAD:
		move_and_slide()
	
	queue_redraw()

func _process_idle(delta: float) -> void:
	velocity = velocity.move_toward(Vector2.ZERO, speed * delta * 5.0)
	idle_timer -= delta
	
	if _can_see_player():
		state = State.CHASE
		return
	
	if idle_timer <= 0:
		state = State.PATROL
		_pick_patrol_target()

func _process_patrol(delta: float) -> void:
	var dir = (patrol_target - global_position).normalized()
	velocity = dir * (speed * 0.65)
	facing_left = dir.x < 0
	
	if _can_see_player():
		state = State.CHASE
		return
	
	if global_position.distance_to(patrol_target) < 24.0:
		state = State.IDLE
		idle_timer = randf_range(1.5, 3.0)

func _process_chase(delta: float) -> void:
	if not is_instance_valid(player_ref):
		state = State.PATROL
		_pick_patrol_target()
		return
	
	var dist = global_position.distance_to(player_ref.global_position)
	var dir = (player_ref.global_position - global_position).normalized()
	facing_left = dir.x < 0
	
	if dist > detection_range * 1.6:
		state = State.PATROL
		_pick_patrol_target()
		return
	
	if dist <= attack_range and attack_cooldown <= 0:
		state = State.ATTACK
		lunge_vector = dir * 180.0
		velocity = lunge_vector
		anim_time = 0.0
		return
	
	velocity = dir * chase_speed

func _process_attack(delta: float) -> void:
	# Lunge forward during initial attack burst
	velocity = velocity.move_toward(Vector2.ZERO, 350.0 * delta)
	
	if anim_time > 0.25 and anim_time < 0.35:
		_deal_damage()
	
	if anim_time > 0.65:
		attack_cooldown = attack_cooldown_time
		state = State.CHASE

func _process_hurt(delta: float) -> void:
	hurt_timer -= delta
	velocity = velocity.move_toward(Vector2.ZERO, 450.0 * delta)
	
	if hurt_timer <= 0:
		if hp <= 0:
			state = State.DEAD
			death_timer = 0.8
			monster_died.emit(self)
		else:
			state = State.CHASE

func _process_dead(delta: float) -> void:
	death_timer -= delta
	velocity = Vector2.ZERO
	if death_timer <= 0:
		queue_free()

func take_damage(amount: int, knockback_dir: Vector2 = Vector2.ZERO) -> void:
	if state == State.DEAD:
		return
	hp -= amount
	state = State.HURT
	hurt_timer = 0.35
	flash_timer = 0.3
	velocity = knockback_dir * 280.0
	SoundManager.play_hit()

func _deal_damage() -> void:
	if not is_instance_valid(player_ref):
		return
	if global_position.distance_to(player_ref.global_position) <= attack_range * 1.4:
		if player_ref.has_method("take_damage"):
			var kb = (player_ref.global_position - global_position).normalized()
			player_ref.take_damage(attack_damage, kb)

func _can_see_player() -> bool:
	if not is_instance_valid(player_ref):
		return false
	return global_position.distance_to(player_ref.global_position) <= detection_range

func _pick_patrol_target() -> void:
	var angle = randf() * TAU
	var dist = randf_range(50.0, patrol_radius)
	patrol_target = home_position + Vector2(cos(angle), sin(angle)) * dist

func _draw() -> void:
	var float_offset = sin(anim_time * 4.0) * 4.0
	
	# Death fading
	if state == State.DEAD:
		var death_alpha = clampf(death_timer / 0.8, 0.0, 1.0)
		modulate.a = death_alpha
		float_offset += (0.8 - death_timer) * 15.0
	
	# Ground Contact Shadow directly under feet
	draw_set_transform(Vector2(0, 0), 0.0, Vector2(1.0, 0.45))
	var shadow_size = 20.0 if monster_type != "astral_sentinel" else 26.0
	draw_circle(Vector2.ZERO, shadow_size, Color(0.01, 0.02, 0.04, 0.45))
	draw_set_transform(Vector2.ZERO)
	
	# Center of monster floating body
	var center = Vector2(0, -26 + float_offset)
	
	# Render Themed Visual Archetypes
	match monster_type:
		"crystal_golem":
			_draw_crystal_golem(center)
		"shadow_spectre":
			_draw_shadow_spectre(center)
		"astral_sentinel":
			_draw_astral_sentinel(center)
	
	# Health Bar
	if state != State.DEAD and hp < max_hp:
		var bw = 36.0
		var bh = 4.0
		var by = center.y - 30.0
		var ratio = float(hp) / float(max_hp)
		draw_rect(Rect2(-bw/2 - 1, by - 1, bw + 2, bh + 2), Color(0.05, 0.08, 0.12, 0.9))
		draw_rect(Rect2(-bw/2, by, bw, bh), Color(0.25, 0.1, 0.1, 0.8))
		draw_rect(Rect2(-bw/2, by, bw * ratio, bh), Color(0.95, 0.25, 0.2, 0.95))

	# Clean Alert Diamond indicator (above head, only while chasing!)
	if state == State.CHASE:
		var alert_y = center.y - 38.0
		var alert_pulse = sin(anim_time * 8.0) * 2.0
		draw_circle(Vector2(0, alert_y), 7.0 + alert_pulse, Color(1.0, 0.25, 0.2, 0.85))
		# Exclamation mark lines
		draw_line(Vector2(0, alert_y - 4), Vector2(0, alert_y + 1), Color.WHITE, 2.0)
		draw_circle(Vector2(0, alert_y + 4), 1.0, Color.WHITE)

# 1. CRYSTAL GOLEM (Gua Kristal) - Bioluminescent Animated Crystal Sphere & Floating Shards
func _draw_crystal_golem(c: Vector2) -> void:
	var flash_mod = Color.WHITE if flash_timer <= 0 else Color(1.8, 0.4, 0.4)
	
	# Luminous aura
	var aura_pulse = sin(anim_time * 5.0) * 4.0
	draw_circle(c, 24.0 + aura_pulse, Color(0.2, 0.6, 1.0, 0.25))
	
	# Animated Core Sprite from Brain Sphere 2 Sheet (48 frames of 176x160)
	if sphere_tex_2:
		var frame_idx = int(anim_time * 12.0) % 48
		var src_rect = Rect2(frame_idx * 176, 0, 176, 160)
		var scale_val = 0.35
		var dw = 176.0 * scale_val
		var dh = 160.0 * scale_val
		var dest_rect = Rect2(c.x - dw * 0.5, c.y - dh * 0.5, dw, dh)
		draw_texture_rect_region(sphere_tex_2, dest_rect, src_rect, Color(0.5, 0.85, 1.0, 0.95) * flash_mod)
	else:
		# Fallback faceted body
		var pts = PackedVector2Array([
			c + Vector2(0, -20), c + Vector2(14, -4), c + Vector2(10, 14),
			c + Vector2(-10, 14), c + Vector2(-14, -4)
		])
		draw_polygon(pts, PackedColorArray([Color(0.25, 0.65, 0.95, 0.92) * flash_mod]))
		draw_polyline(pts, Color(0.85, 0.95, 1.0, 1.0) * flash_mod, 2.0)
	
	# 3 Orbiting Floating Crystal Shards
	for i in range(3):
		var angle = (anim_time * 2.8) + (i * TAU / 3.0)
		var shard_pos = c + Vector2(cos(angle) * 28.0, sin(angle) * 12.0)
		var s_pts = PackedVector2Array([
			shard_pos + Vector2(0, -7),
			shard_pos + Vector2(4, 0),
			shard_pos + Vector2(0, 7),
			shard_pos + Vector2(-4, 0)
		])
		draw_polygon(s_pts, PackedColorArray([Color(0.4, 0.85, 1.0, 0.9) * flash_mod]))
		draw_polyline(s_pts, Color(0.9, 0.98, 1.0, 1.0) * flash_mod, 1.2)

# 2. SHADOW SPECTRE (Desa yang Terlupakan) - Corrupted Phantom with Animated Void Sphere & Crimson Eyes
func _draw_shadow_spectre(c: Vector2) -> void:
	var flash_mod = Color.WHITE if flash_timer <= 0 else Color(1.8, 0.4, 0.4)
	
	# Swirling dark void aura
	var wisp_pulse = sin(anim_time * 4.5) * 5.0
	draw_circle(c, 26.0 + wisp_pulse, Color(0.25, 0.08, 0.35, 0.35))
	
	# Animated Corrupted Sprite from Brain Sphere 3 Sheet (59 frames of 176x160)
	if sphere_tex_3:
		var frame_idx = int(anim_time * 12.0) % 59
		var src_rect = Rect2(frame_idx * 176, 0, 176, 160)
		var scale_val = 0.36
		var dw = 176.0 * scale_val
		var dh = 160.0 * scale_val
		var dest_rect = Rect2(c.x - dw * 0.5, c.y - dh * 0.5, dw, dh)
		draw_texture_rect_region(sphere_tex_3, dest_rect, src_rect, Color(0.8, 0.4, 1.0, 0.95) * flash_mod)
	else:
		var shroud_pts = PackedVector2Array()
		for i in range(12):
			var a = i * TAU / 12.0
			var r = 18.0 + sin(anim_time * 6.0 + i) * 3.5
			shroud_pts.append(c + Vector2(cos(a) * r, sin(a) * (r * 1.15)))
		draw_polygon(shroud_pts, PackedColorArray([Color(0.12, 0.08, 0.18, 0.95) * flash_mod]))
		draw_polyline(shroud_pts, Color(0.65, 0.3, 0.8, 0.75) * flash_mod, 2.0)
	
	# Piercing Crimson Eclipse Eyes
	var eye_offset_x = 5.0 if not facing_left else -5.0
	var eye_l = c + Vector2(eye_offset_x - 5, -4)
	var eye_r = c + Vector2(eye_offset_x + 5, -4)
	draw_circle(eye_l, 3.0, Color(1.0, 0.15, 0.3, 1.0))
	draw_circle(eye_r, 3.0, Color(1.0, 0.15, 0.3, 1.0))
	draw_circle(eye_l, 1.2, Color.WHITE)
	draw_circle(eye_r, 1.2, Color.WHITE)
	
	# Trailing shadowy wisps beneath
	for k in range(3):
		var trail_x = (k - 1) * 8.0
		var wave_y = sin(anim_time * 7.0 + k) * 5.0
		draw_line(c + Vector2(trail_x, 14), c + Vector2(trail_x, 26 + wave_y), Color(0.35, 0.12, 0.5, 0.65), 2.5)

# 3. ASTRAL SENTINEL (Kuil Astra) - Celestial Starlight Sphere with Rotating Rune Halo
func _draw_astral_sentinel(c: Vector2) -> void:
	var flash_mod = Color.WHITE if flash_timer <= 0 else Color(1.8, 0.4, 0.4)
	
	# Celestial Rotating Starlight Halo
	var halo_r = 30.0
	var halo_angle = anim_time * 1.8
	draw_arc(c, halo_r, 0, TAU, 36, Color(0.9, 0.75, 0.4, 0.55), 2.0)
	for j in range(4):
		var ga = halo_angle + (j * PI / 2.0)
		var gp = c + Vector2(cos(ga), sin(ga)) * halo_r
		draw_circle(gp, 3.5, Color(1.0, 0.95, 0.6, 0.95))
	
	# Animated Celestial Sprite from Brain Sphere 1 Sheet (48 frames of 176x160)
	if sphere_tex_1:
		var frame_idx = int(anim_time * 12.0) % 48
		var src_rect = Rect2(frame_idx * 176, 0, 176, 160)
		var scale_val = 0.38
		var dw = 176.0 * scale_val
		var dh = 160.0 * scale_val
		var dest_rect = Rect2(c.x - dw * 0.5, c.y - dh * 0.5, dw, dh)
		draw_texture_rect_region(sphere_tex_1, dest_rect, src_rect, Color(1.0, 0.92, 0.65, 0.95) * flash_mod)
	else:
		var body = PackedVector2Array([
			c + Vector2(0, -22), c + Vector2(16, -4), c + Vector2(12, 18),
			c + Vector2(-12, 18), c + Vector2(-16, -4)
		])
		draw_polygon(body, PackedColorArray([Color(0.18, 0.16, 0.28, 0.95) * flash_mod]))
		draw_polyline(body, Color(0.8, 0.65, 0.35, 0.9) * flash_mod, 2.0)
	
	# Central Starlight Core
	draw_circle(c, 4.0, Color.WHITE * flash_mod)
