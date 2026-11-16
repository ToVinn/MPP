extends Control

@onready var visual_box: Control = %EndingVisual
@onready var title_label: Label = %TitleLabel
@onready var quote_label: Label = %QuoteLabel
@onready var status_badge: Label = %StatusBadge
@onready var return_btn: Button = %ReturnBtn
@onready var dialogue_box: CanvasLayer = $DialogueBox

func _ready() -> void:
	return_btn.visible = false
	title_label.modulate.a = 0.0
	quote_label.modulate.a = 0.0
	status_badge.modulate.a = 0.0
	
	return_btn.pressed.connect(func():
		SoundManager.play_select()
		GameManager.change_scene("res://scenes/title_screen.tscn", 1.0)
	)
	
	_play_bad_ending_sequence()

func _play_bad_ending_sequence() -> void:
	await get_tree().create_timer(1.0).timeout
	
	# Scene 01: The Unstable Crystal
	DialogueManager.start_dialogue([
		{"speaker": "Aren", "text": "Aku sudah mengingat semuanya. Aku tidak akan kehilanganmu lagi!"},
		{"speaker": "Lyra", "text": "Aren... tunggu! Kau belum memahami semuanya!"},
		{"speaker": "Aren", "text": "Lyra!"},
		{"speaker": "Lyra", "text": "Terima kasih... karena sudah mencariku..."},
		{"speaker": "Aren", "text": "Lyra...? Apakah... aku terlambat?"}
	])
	await DialogueManager.dialogue_finished
	
	# Scene 03: Title presentation
	var tween = create_tween()
	tween.tween_property(title_label, "modulate:a", 1.0, 1.5)
	tween.tween_property(quote_label, "modulate:a", 1.0, 1.2)
	tween.tween_property(status_badge, "modulate:a", 1.0, 1.0)
	await tween.finished
	
	return_btn.visible = true
	return_btn.grab_focus()

