extends StaticBody2D

# Solid World Building with Real Collision, Depth Sorting & Dither Transparency Occlusion
# - Full Solid Collision: Players collide with walls and cannot walk through or on top of roofs ("ketabrak")
# - Roof Camera Occlusion: When player walks behind the roof/upper structure, building dissolves with Dither Transparency

@export var texture: Texture2D
@export var building_scale: Vector2 = Vector2(1.5, 1.5)
@export var collision_size: Vector2 = Vector2(170, 140)
@export var collision_offset: Vector2 = Vector2(0, -65)

@onready var sprite: Sprite2D = $Sprite2D
@onready var col_shape: CollisionShape2D = $CollisionShape2D

const DITHER_SHADER = preload("res://shaders/dither_transparency.gdshader")

var shader_mat: ShaderMaterial
var fade_tween: Tween
var is_player_behind_roof: bool = false
var roof_area: Area2D

func _ready() -> void:
	z_index = 0
	collision_layer = 1
	collision_mask = 0
	
	shader_mat = ShaderMaterial.new()
	shader_mat.shader = DITHER_SHADER
	shader_mat.set_shader_parameter("dither_amount", 0.0)
	shader_mat.set_shader_parameter("alpha_mult", 1.0)
	
	if sprite:
		if texture:
			sprite.texture = texture
		sprite.scale = building_scale
		sprite.position = Vector2(0, -88)
		sprite.material = shader_mat
		
	if col_shape:
		var rect_shape = RectangleShape2D.new()
		rect_shape.size = collision_size
		col_shape.shape = rect_shape
		col_shape.position = collision_offset

	# Dynamic Roof Occlusion Detector for alleyway behind the roof
	roof_area = Area2D.new()
	roof_area.name = "RoofOcclusionArea"
	roof_area.collision_layer = 0
	roof_area.collision_mask = 2 # Player layer
	
	var roof_col = CollisionShape2D.new()
	var roof_box = RectangleShape2D.new()
	roof_box.size = Vector2(collision_size.x + 20, 80)
	roof_col.shape = roof_box
	roof_col.position = Vector2(0, -155) # Area directly behind the roof
	roof_area.add_child(roof_col)
	add_child(roof_area)
	
	roof_area.body_entered.connect(_on_roof_body_entered)
	roof_area.body_exited.connect(_on_roof_body_exited)

func _on_roof_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		is_player_behind_roof = true
		_update_dither_state()

func _on_roof_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		is_player_behind_roof = false
		_update_dither_state()

func _update_dither_state() -> void:
	if not shader_mat:
		return
	var target_dither = 0.65 if is_player_behind_roof else 0.0
	var target_alpha = 0.5 if is_player_behind_roof else 1.0
	
	if fade_tween and fade_tween.is_valid():
		fade_tween.kill()
		
	fade_tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	var curr_dither = shader_mat.get_shader_parameter("dither_amount")
	var curr_alpha = shader_mat.get_shader_parameter("alpha_mult")
	
	fade_tween.tween_method(func(val): shader_mat.set_shader_parameter("dither_amount", val), curr_dither, target_dither, 0.22)
	fade_tween.tween_method(func(val): shader_mat.set_shader_parameter("alpha_mult", val), curr_alpha, target_alpha, 0.22)

func _draw() -> void:
	# Grounding contact shadow along the foundation contact line
	var shadow_rect = Rect2(-collision_size.x * 0.48, -10, collision_size.x * 0.96, 20)
	draw_rect(shadow_rect, Color(0.01, 0.02, 0.02, 0.35))
