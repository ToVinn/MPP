extends CanvasLayer

@onready var panel_container: PanelContainer = $PanelContainer
@onready var speaker_label: Label = %SpeakerLabel
@onready var content_label: RichTextLabel = %ContentLabel
@onready var continue_prompt: Label = %ContinuePrompt
@onready var choice_container: VBoxContainer = %ChoiceContainer
@onready var choice_title: Label = %ChoiceTitle

var is_typing: bool = false
var full_text: String = ""
var tween: Tween = null
var current_options: Array = []

func _ready() -> void:
	visible = false
	DialogueManager.register_ui(self)
	continue_prompt.visible = false
	choice_container.visible = false
	panel_container.gui_input.connect(_on_panel_gui_input)

func _on_panel_gui_input(event: InputEvent) -> void:
	if not visible or DialogueManager.is_waiting_for_choice:
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		DialogueManager.advance()
		get_viewport().set_input_as_handled()

func _input(event: InputEvent) -> void:
	if not visible or DialogueManager.is_waiting_for_choice:
		return
		
	var should_advance = false
	if event.is_action_pressed("ui_accept"):
		should_advance = true
	elif event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_SPACE or event.keycode == KEY_ENTER or event.keycode == KEY_E:
			should_advance = true
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		should_advance = true
		
	if should_advance:
		DialogueManager.advance()
		get_viewport().set_input_as_handled()

func display_line(data: Dictionary) -> void:
	choice_container.visible = false
	continue_prompt.visible = false
	content_label.visible = true
	
	var speaker = data.get("speaker", "")
	var text = data.get("text", "")
	
	speaker_label.text = speaker
	_style_speaker(speaker)
	
	full_text = text
	content_label.text = text
	content_label.visible_characters = 0
	is_typing = true
	
	if tween:
		tween.kill()
		
	var duration = max(0.4, float(text.length()) * 0.025)
	tween = create_tween()
	tween.tween_property(content_label, "visible_characters", text.length(), duration)
	
	# Periodically trigger sound during typing
	var steps = int(duration / 0.05)
	for i in range(steps):
		tween.parallel().tween_callback(func():
			if is_typing and (i % 2 == 0):
				SoundManager.play_dialogue_blip()
		).set_delay(i * 0.05)
		
	tween.finished.connect(func():
		is_typing = false
		continue_prompt.visible = true
	)

func skip_typewriter() -> void:
	if tween:
		tween.kill()
	content_label.visible_characters = full_text.length()
	is_typing = false
	continue_prompt.visible = true

func display_choice(prompt_text: String, options: Array) -> void:
	if tween:
		tween.kill()
	is_typing = false
	continue_prompt.visible = false
	content_label.visible = false
	speaker_label.text = "PILIHAN PENTING"
	speaker_label.modulate = Color(1.0, 0.85, 0.3)
	
	choice_title.text = prompt_text
	choice_container.visible = true
	
	# Clear previous choice buttons
	for child in choice_container.get_children():
		if child != choice_title:
			child.queue_free()
			
	for i in range(options.size()):
		var opt_text = options[i]
		var btn = Button.new()
		btn.text = opt_text
		btn.custom_minimum_size = Vector2(0, 42)
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		
		# Button style
		var style = StyleBoxFlat.new()
		style.bg_color = Color(0.12, 0.16, 0.28, 0.9)
		style.border_color = Color(0.3, 0.6, 1.0, 0.8)
		style.set_border_width_all(2)
		style.set_corner_radius_all(6)
		style.content_margin_left = 16.0
		style.content_margin_right = 16.0
		btn.add_theme_stylebox_override("normal", style)
		
		var hover_style = style.duplicate()
		hover_style.bg_color = Color(0.2, 0.3, 0.5, 0.95)
		hover_style.border_color = Color(0.6, 0.85, 1.0, 1.0)
		btn.add_theme_stylebox_override("hover", hover_style)
		btn.add_theme_stylebox_override("focus", hover_style)
		
		var idx = i
		btn.pressed.connect(func():
			SoundManager.play_select()
			DialogueManager.select_choice(idx, opt_text)
		)
		choice_container.add_child(btn)
		
		if i == 0:
			btn.grab_focus()

func _style_speaker(speaker: String) -> void:
	match speaker:
		"Aren", "Aren kecil":
			speaker_label.modulate = Color(0.4, 0.8, 1.0) # Azure cyan
		"Lyra", "Gadis misterius":
			speaker_label.modulate = Color(1.0, 0.6, 0.85) # Soft luminous rose
		"Eldrin":
			speaker_label.modulate = Color(0.9, 0.75, 0.4) # Ancient gold
		"The Hollow Knight":
			speaker_label.modulate = Color(0.8, 0.3, 0.3) # Crimson mystery
		_:
			speaker_label.modulate = Color.WHITE

