extends CharacterBody2D

# Aren - Main Character of Echoes of Astra
# Top-Down 2D Controller with Combat, Parkour/Jump, Health, and 4-directional Sprites

signal health_changed(current_hp: int, max_hp: int)
signal player_died
signal player_respawned

@export var speed: float = 185.0
@export var max_hp: int = 5

@onready var camera: Camera2D = $Camera2D
@onready var interact_detector: Area2D = $InteractDetector
@onready var prompt_label: Label = $PromptLabel
@onready var sprite: Sprite2D = $Sprite2D

# Sprite Preloads
const IDLE_DOWN = preload("res://Model/Aren/Sprites/IDLE/idle_down.png")
const IDLE_UP = preload("res://Model/Aren/Sprites/IDLE/idle_up.png")
const IDLE_RIGHT = preload("res://Model/Aren/Sprites/IDLE/idle_right.png")
const IDLE_LEFT = preload("res://Model/Aren/Sprites/IDLE/idle_left.png")

const RUN_DOWN = preload("res://Model/Aren/Sprites/RUN/run_down.png")
const RUN_UP = preload("res://Model/Aren/Sprites/RUN/run_up.png")
const RUN_RIGHT = preload("res://Model/Aren/Sprites/RUN/run_right.png")
const RUN_LEFT = preload("res://Model/Aren/Sprites/RUN/run_left.png")

const ATK1_DOWN = preload("res://Model/Aren/Sprites/ATTACK 1/attack1_down.png")
const ATK1_UP = preload("res://Model/Aren/Sprites/ATTACK 1/attack1_up.png")
const ATK1_RIGHT = preload("res://Model/Aren/Sprites/ATTACK 1/attack1_right.png")
const ATK1_LEFT = preload("res://Model/Aren/Sprites/ATTACK 1/attack1_left.png")

const ATK2_DOWN = preload("res://Model/Aren/Sprites/ATTACK 2/attack2_down.png")
const ATK2_UP = preload("res://Model/Aren/Sprites/ATTACK 2/attack2_up.png")
const ATK2_RIGHT = preload("res://Model/Aren/Sprites/ATTACK 2/attack2_right.png")
const ATK2_LEFT = preload("res://Model/Aren/Sprites/ATTACK 2/attack2_left.png")

# Gameplay State
var current_hp: int = 5
var current_interactable: Node = null
var facing_direction: String = "down" # "down", "up", "left", "right"
var is_moving: bool = false
var interact_cooldown: float = 0.0
var anim_frame_timer: float = 0.0
var respawn_position: Vector2 = Vector2.ZERO

# Combat State
var is_attacking: bool = false
var attack_timer: float = 0.0
var attack_duration: float = 0.36
var attack_combo: int = 1 # 1 or 2
var attack_hitbox: Area2D = null
var attack_has_hit: bool = false

# Parkour / Jump State
var is_jumping: bool = false
var is_airborne: bool = false
var jump_timer: float = 0.0
var jump_duration: float = 0.44
var jump_direction: Vector2 = Vector2.ZERO
var base_sprite_y: float = -22.0

# Dash / Dodge Roll State
var is_dashing: bool = false
var dash_timer: float = 0.0
var dash_duration: float = 0.22
var dash_cooldown: float = 0.0
var dash_direction: Vector2 = Vector2.ZERO

# Lighting
var crystal_light: PointLight2D = null

# Damage / Invulnerability
var is_invulnerable: bool = false
var invuln_timer: float = 0.0
var flash_timer: float = 0.0
var is_dead: bool = false

func _ready() -> void:
	z_index = 0
	add_to_group("player")
	current_hp = max_hp
	respawn_position = global_position
	prompt_label.visible = false
	
	interact_detector.area_entered.connect(_on_interact_area_entered)
	interact_detector.area_exited.connect(_on_interact_area_exited)
	
	DialogueManager.dialogue_finished.connect(func():
		interact_cooldown = 0.35
	)
	
	if sprite:
		sprite.texture = IDLE_DOWN
		sprite.hframes = 8
		sprite.vframes = 1
		sprite.frame = 0
		base_sprite_y = sprite.position.y
		
	_setup_attack_hitbox()
	health_changed.emit(current_hp, max_hp)
	
	# Dynamic Crystal Lantern Light
	crystal_light = PointLight2D.new()
	crystal_light.texture = GameManager.create_light_texture(128)
	crystal_light.texture_scale = 1.9
	crystal_light.color = Color(0.45, 0.82, 1.0, 1.0)
	crystal_light.energy = 0.95
	crystal_light.position = Vector2(0, -18)
	add_child(crystal_light)

func _setup_attack_hitbox() -> void:
	attack_hitbox = Area2D.new()
	attack_hitbox.name = "AttackHitbox"
	attack_hitbox.collision_layer = 32
	attack_hitbox.collision_mask = 8 | 16 # Detect monsters and monster hurtboxes
	attack_hitbox.monitoring = false
	
	var col = CollisionShape2D.new()
	var shape = CircleShape2D.new()
	shape.radius = 32.0
	col.shape = shape
	attack_hitbox.add_child(col)
	add_child(attack_hitbox)
	
	attack_hitbox.body_entered.connect(_on_attack_body_entered)
	attack_hitbox.area_entered.connect(_on_attack_area_entered)

func set_camera_limits(limit_rect: Rect2) -> void:
	if camera:
		camera.limit_left = int(limit_rect.position.x)
		camera.limit_top = int(limit_rect.position.y)
		camera.limit_right = int(limit_rect.position.x + limit_rect.size.x)
		camera.limit_bottom = int(limit_rect.position.y + limit_rect.size.y)

func _physics_process(delta: float) -> void:
	if is_dead:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	if interact_cooldown > 0.0:
		interact_cooldown -= delta

	if dash_cooldown > 0.0:
		dash_cooldown -= delta
		
	# Handle Active Dash State
	if is_dashing:
		dash_timer += delta
		velocity = dash_direction * (speed * 2.2)
		move_and_slide()
		if dash_timer >= dash_duration:
			is_dashing = false
			velocity = velocity * 0.4
		return
		
	# Invulnerability timer & flashing effect
	if is_invulnerable:
		invuln_timer -= delta
		flash_timer += delta * 18.0
		sprite.modulate.a = 0.35 if int(flash_timer) % 2 == 0 else 1.0
		if invuln_timer <= 0.0:
			is_invulnerable = false
			sprite.modulate.a = 1.0

	# Block player action during cutscenes, transitions, or dialogue
	if DialogueManager.is_active or GameManager.is_transitioning:
		velocity = velocity.move_toward(Vector2.ZERO, speed * delta * 6.0)
		move_and_slide()
		is_moving = false
		_update_sprite_animation(delta)
		return

	# Handle Active Attack State
	if is_attacking:
		_process_attack(delta)
		move_and_slide()
		return

	# Handle Active Jump (Parkour) State
	if is_jumping:
		_process_jump(delta)
		move_and_slide()
		return

	# Input: Combat Dash (Shift)
	if Input.is_action_just_pressed("dash") and not is_dashing and not is_jumping and not is_attacking and dash_cooldown <= 0.0:
		is_dashing = true
		dash_timer = 0.0
		dash_cooldown = 0.55
		is_invulnerable = true
		invuln_timer = 0.28
		var ddir = velocity.normalized()
		if ddir == Vector2.ZERO:
			ddir = _get_facing_vector()
		dash_direction = ddir
		SoundManager.play_jump()
		move_and_slide()
		return

	# Input: Jump / Parkour Leap
	if Input.is_action_just_pressed("jump") and not is_jumping and not is_attacking and not is_dashing:
		_start_jump()
		move_and_slide()
		return

	# Input: Sword Attack
	if (Input.is_action_just_pressed("attack") or Input.is_key_pressed(KEY_J)) and not is_attacking and not is_jumping:
		_start_attack()
		move_and_slide()
		return

	# Top-Down 2D Movement Input
	var input_vector = Vector2.ZERO
	if Input.is_action_pressed("move_left") or Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT):
		input_vector.x -= 1.0
	if Input.is_action_pressed("move_right") or Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
		input_vector.x += 1.0
	if Input.is_action_pressed("move_up") or Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP):
		input_vector.y -= 1.0
	if Input.is_action_pressed("move_down") or Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN):
		input_vector.y += 1.0

	if input_vector != Vector2.ZERO:
		input_vector = input_vector.normalized()
		velocity = input_vector * speed
		is_moving = true

		# Determine dominant facing direction
		if abs(input_vector.x) > abs(input_vector.y):
			facing_direction = "right" if input_vector.x > 0 else "left"
		else:
			facing_direction = "down" if input_vector.y > 0 else "up"
	else:
		velocity = velocity.move_toward(Vector2.ZERO, speed * delta * 7.0)
		is_moving = false

	move_and_slide()
	_update_sprite_animation(delta)

	# Interaction input - strictly 'E' with cooldown
	if current_interactable and interact_cooldown <= 0.0:
		if Input.is_action_just_pressed("interact"):
			if current_interactable.has_method("interact"):
				interact_cooldown = 0.4
				current_interactable.interact(self)

func _start_attack() -> void:
	is_attacking = true
	attack_timer = 0.0
	attack_has_hit = false
	anim_frame_timer = 0.0
	SoundManager.play_sword_slash()
	
	# Slight forward momentum step
	var fwd = _get_facing_vector()
	velocity = fwd * 80.0
	
	# Position attack hitbox in front of player
	if attack_hitbox:
		attack_hitbox.position = fwd * 34.0
		attack_hitbox.monitoring = true

func _process_attack(delta: float) -> void:
	attack_timer += delta
	anim_frame_timer += delta * 22.0
	velocity = velocity.move_toward(Vector2.ZERO, speed * delta * 4.0)
	
	# Check damage midway through swing
	if attack_hitbox and attack_hitbox.monitoring:
		_check_hitbox_overlaps()
	
	# Update Attack Animation
	var atk_tex = _get_attack_texture()
	if sprite.texture != atk_tex:
		sprite.texture = atk_tex
	sprite.frame = clampi(int(anim_frame_timer), 0, 7)
	
	if attack_timer >= attack_duration:
		is_attacking = false
		if attack_hitbox:
			attack_hitbox.monitoring = false
		# Toggle combo chain for next attack
		attack_combo = 2 if attack_combo == 1 else 1

func _get_attack_texture() -> Texture2D:
	if attack_combo == 1:
		match facing_direction:
			"down": return ATK1_DOWN
			"up": return ATK1_UP
			"right": return ATK1_RIGHT
			"left": return ATK1_LEFT
	else:
		match facing_direction:
			"down": return ATK2_DOWN
			"up": return ATK2_UP
			"right": return ATK2_RIGHT
			"left": return ATK2_LEFT
	return ATK1_DOWN

func _check_hitbox_overlaps() -> void:
	if not attack_hitbox or attack_has_hit:
		return
	var bodies = attack_hitbox.get_overlapping_bodies()
	for b in bodies:
		if b.is_in_group("monsters") and b.has_method("take_damage"):
			var kb = (b.global_position - global_position).normalized()
			b.take_damage(1, kb)
			attack_has_hit = true
			SoundManager.play_hit()
			break

func _on_attack_body_entered(body: Node2D) -> void:
	if body.is_in_group("monsters") and body.has_method("take_damage"):
		var kb = (body.global_position - global_position).normalized()
		body.take_damage(1, kb)
		attack_has_hit = true
		SoundManager.play_hit()

func _on_attack_area_entered(area: Area2D) -> void:
	var parent = area.get_parent()
	if parent and parent.is_in_group("monsters") and parent.has_method("take_damage"):
		var kb = (parent.global_position - global_position).normalized()
		parent.take_damage(1, kb)
		attack_has_hit = true
		SoundManager.play_hit()

# Parkour Jump Logic
func _start_jump() -> void:
	is_jumping = true
	is_airborne = true
	jump_timer = 0.0
	
	var dir = velocity.normalized()
	if dir == Vector2.ZERO:
		dir = _get_facing_vector()
	jump_direction = dir
	velocity = jump_direction * (speed * 1.35)
	
	SoundManager.play_jump()

func _process_jump(delta: float) -> void:
	jump_timer += delta
	var progress = clampf(jump_timer / jump_duration, 0.0, 1.0)
	
	# Parabolic vertical arc for Aren's sprite
	var arc_height = sin(progress * PI) * 26.0
	sprite.position.y = base_sprite_y - arc_height
	
	# Maintain jump velocity smoothly
	velocity = jump_direction * (speed * 1.3)
	
	# Running sprite frame during jump
	var run_tex = _get_run_texture()
	if sprite.texture != run_tex:
		sprite.texture = run_tex
	sprite.frame = 4 # Athletic leap pose frame
	
	if jump_timer >= jump_duration:
		_finish_jump()

func _finish_jump() -> void:
	is_jumping = false
	is_airborne = false
	sprite.position.y = base_sprite_y
	velocity = velocity * 0.5

func _get_facing_vector() -> Vector2:
	match facing_direction:
		"down": return Vector2.DOWN
		"up": return Vector2.UP
		"right": return Vector2.RIGHT
		"left": return Vector2.LEFT
	return Vector2.DOWN

func _get_run_texture() -> Texture2D:
	match facing_direction:
		"down": return RUN_DOWN
		"up": return RUN_UP
		"right": return RUN_RIGHT
		"left": return RUN_LEFT
	return RUN_DOWN

func _update_sprite_animation(delta: float) -> void:
	if not sprite or is_attacking or is_jumping:
		return

	var target_tex: Texture2D = IDLE_DOWN
	if is_moving:
		anim_frame_timer += delta * 11.0
		target_tex = _get_run_texture()
	else:
		anim_frame_timer += delta * 6.0
		match facing_direction:
			"down": target_tex = IDLE_DOWN
			"up": target_tex = IDLE_UP
			"right": target_tex = IDLE_RIGHT
			"left": target_tex = IDLE_LEFT

	if sprite.texture != target_tex:
		sprite.texture = target_tex

	sprite.frame = int(anim_frame_timer) % 8
	sprite.flip_h = false

# Damage & Respawn System
func take_damage(amount: int, knockback_dir: Vector2 = Vector2.ZERO) -> void:
	if is_invulnerable or is_dead or GameManager.is_transitioning:
		return
		
	current_hp = maxi(0, current_hp - amount)
	health_changed.emit(current_hp, max_hp)
	SoundManager.play_player_hurt()
	
	# Knockback
	velocity = knockback_dir * 220.0
	is_invulnerable = true
	invuln_timer = 1.1
	flash_timer = 0.0
	
	if current_hp <= 0:
		_handle_defeat()

func _handle_defeat() -> void:
	is_dead = true
	player_died.emit()
	velocity = Vector2.ZERO
	
	# Death fade effect
	var tween = create_tween()
	tween.tween_property(sprite, "modulate:a", 0.0, 0.8)
	await tween.finished
	
	await get_tree().create_timer(0.4).timeout
	_respawn()

func _respawn() -> void:
	global_position = respawn_position
	current_hp = max_hp
	is_dead = false
	is_invulnerable = true
	invuln_timer = 1.5
	sprite.position.y = base_sprite_y
	sprite.modulate = Color.WHITE
	health_changed.emit(current_hp, max_hp)
	player_respawned.emit()

func set_respawn_point(new_pos: Vector2) -> void:
	respawn_position = new_pos

func _on_interact_area_entered(area: Area2D) -> void:
	if area.is_in_group("interactable"):
		current_interactable = area
		prompt_label.text = area.get_prompt() if area.has_method("get_prompt") else "[E] Periksa"
		prompt_label.visible = true

func _on_interact_area_exited(area: Area2D) -> void:
	if current_interactable == area:
		current_interactable = null
		prompt_label.visible = false
