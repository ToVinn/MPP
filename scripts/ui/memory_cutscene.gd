extends CanvasLayer

signal cutscene_finished

@onready var background_rect: ColorRect = $BackgroundRect
@onready var title_label: Label = %TitleLabel
@onready var desc_label: Label = %DescLabel
@onready var visual_art: Control = %VisualArt
@onready var sub_label: Label = %SubLabel

var is_running: bool = false

func _ready() -> void:
	visible = false

func play_memory(memory_id: int, title: String, narrative_lines: Array, completion_text: String) -> void:
	visible = true
	is_running = true
	title_label.text = title
	desc_label.text = ""
	sub_label.text = ""
	visual_art.memory_id = memory_id
	visual_art.queue_redraw()
	
	SoundManager.play_memory()
	
	# Fade in solid ethereal background (100% opaque to prevent map/HUD bleed-through)
	background_rect.color.a = 0.0
	var tween = create_tween()
	tween.tween_property(background_rect, "color:a", 1.0, 0.8)
	await tween.finished
	
	# Start dialogue sequence through DialogueManager
	DialogueManager.start_dialogue(narrative_lines)
	await DialogueManager.dialogue_finished
	
	# Show summary realization
	sub_label.text = completion_text
	var sub_tween = create_tween()
	sub_label.modulate.a = 0.0
	sub_tween.tween_property(sub_label, "modulate:a", 1.0, 0.8)
	await get_tree().create_timer(3.0).timeout
	
	# Fade out
	var fade_out = create_tween()
	fade_out.tween_property(background_rect, "color:a", 0.0, 1.0)
	fade_out.parallel().tween_property(sub_label, "modulate:a", 0.0, 0.8)
	await fade_out.finished
	
	visible = false
	is_running = false
	cutscene_finished.emit()

