extends Control

@onready var visual_box: Control = %EndingVisual
@onready var title_label: Label = %TitleLabel
@onready var quote_label: Label = %QuoteLabel
@onready var status_badge: Label = %StatusBadge
@onready var return_btn: Button = %ReturnBtn
@onready var dialogue_box: CanvasLayer = $DialogueBox

var time: float = 0.0

func _ready() -> void:
	return_btn.visible = false
	title_label.modulate.a = 0.0
	quote_label.modulate.a = 0.0
	status_badge.modulate.a = 0.0
	
	return_btn.pressed.connect(func():
		SoundManager.play_select()
		GameManager.change_scene("res://scenes/title_screen.tscn", 1.0)
	)
	
	_play_good_ending_sequence()

func _process(delta: float) -> void:
	time += delta
	visual_box.queue_redraw()

func _play_good_ending_sequence() -> void:
	SoundManager.play_bell()
	await get_tree().create_timer(1.2).timeout
	
	# Scene 01 & 02: Reunion Dialogue
	DialogueManager.start_dialogue([
		{"speaker": "Aren", "text": "Jadi selama ini... kau menungguku."},
		{"speaker": "Lyra", "text": "Aku tahu suatu hari nanti kau akan kembali."},
		{"speaker": "Aren", "text": "Aku tidak akan melupakanmu lagi."},
		{"speaker": "Lyra", "text": "Kau sudah menepati janjimu, Aren."},
		{"speaker": "Lyra", "text": "Aren..."},
		{"speaker": "Aren", "text": "Lyra!"},
		{"speaker": "Aren", "text": "Perjalanan kita belum berakhir, bukan?"},
		{"speaker": "Lyra", "text": "Tidak. Masih banyak hal yang belum kita temukan di dunia Astra ini."}
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

