extends StaticBody2D

# Echoes of Astra - World Tree with Solid Trunk Collision & Dither Transparency / Camera Occlusion
# - Trunk Collision: Players hit the trunk base and stop ("mentok")
# - Canopy Camera Occlusion: When the player walks behind leaves, tree dissolves with Dither Transparency

@export var tree_scale: Vector2 = Vector2(1.8, 1.8)

@onready var sprite: Sprite2D = $Sprite2D
@onready var col_shape: CollisionShape2D = $CollisionShape2D
@onready var canopy_area: Area2D = $CanopyArea

const BIG_TREE_TEX = preload("res://assets/textures/tree_big.png")
const DITHER_SHADER = preload("res://shaders/dither_transparency.gdshader")

var shader_mat: ShaderMaterial
var fade_tween: Tween
var is_player_behind_leaves: bool = false

func _ready() -> void:
	z_index = 0
	collision_layer = 1
	collision_mask = 0
	
	shader_mat = ShaderMaterial.new()
	shader_mat.shader = DITHER_SHADER
	shader_mat.set_shader_parameter("dither_amount", 0.0)
	shader_mat.set_shader_parameter("alpha_mult", 1.0)
	
	if sprite:
		# Gunakan texture yang sudah di-assign di scene; fallback ke tree_big
		if sprite.texture == null:
			sprite.texture = BIG_TREE_TEX
		sprite.scale = tree_scale
		# Center trunk contact at local (0, 0)
		sprite.position = Vector2(0, -60)
		sprite.material = shader_mat
		
	if col_shape:
		var circle = CircleShape2D.new()
		circle.radius = 18.0
		col_shape.shape = circle
		col_shape.position = Vector2(0, 0)
		
	if canopy_area:
		canopy_area.collision_layer = 0
		canopy_area.collision_mask = 2 # Player is on layer 2
		canopy_area.body_entered.connect(_on_canopy_body_entered)
		canopy_area.body_exited.connect(_on_canopy_body_exited)

func _on_canopy_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		is_player_behind_leaves = true
		_update_dither_state()

func _on_canopy_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		is_player_behind_leaves = false
		_update_dither_state()

func _update_dither_state() -> void:
	if not shader_mat:
		return
		
	var target_dither = 0.65 if is_player_behind_leaves else 0.0
	var target_alpha = 0.45 if is_player_behind_leaves else 1.0
	
	if fade_tween and fade_tween.is_valid():
		fade_tween.kill()
		
	fade_tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	var curr_dither = shader_mat.get_shader_parameter("dither_amount")
	var curr_alpha = shader_mat.get_shader_parameter("alpha_mult")
	
	fade_tween.tween_method(func(val): shader_mat.set_shader_parameter("dither_amount", val), curr_dither, target_dither, 0.22)
	fade_tween.tween_method(func(val): shader_mat.set_shader_parameter("alpha_mult", val), curr_alpha, target_alpha, 0.22)

func _draw() -> void:
	# Clean ground contact shadow accurately centered beneath the trunk roots
	draw_set_transform(Vector2(0, 2), 0.0, Vector2(1.0, 0.42))
	draw_circle(Vector2.ZERO, 28.0, Color(0.01, 0.02, 0.02, 0.4))
	draw_set_transform(Vector2.ZERO)
