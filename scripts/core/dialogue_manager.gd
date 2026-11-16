extends Node

# Central Dialogue & Choice System for Echoes of Astra
# Supports typewriter text, speaker names, choices, and input blocking

signal dialogue_started
signal dialogue_line_started(speaker: String, text: String)
signal dialogue_finished
signal choice_made(choice_index: int, choice_text: String)

var is_active: bool = false
var is_waiting_for_choice: bool = false

var dialogue_queue: Array = []
var current_line_index: int = 0

# Dialogue UI reference
var dialogue_ui: CanvasLayer = null

func register_ui(ui: CanvasLayer) -> void:
	dialogue_ui = ui

func start_dialogue(lines: Array) -> void:
	# lines is Array of Dictionary: [{"speaker": "Aren", "text": "Di mana... aku?"}]
	if lines.is_empty():
		return
	dialogue_queue = lines.duplicate()
	current_line_index = 0
	is_active = true
	is_waiting_for_choice = false
	dialogue_started.emit()
	
	if dialogue_ui:
		dialogue_ui.visible = true
		dialogue_ui.display_line(dialogue_queue[0])

func advance() -> void:
	if not is_active or is_waiting_for_choice:
		return
	
	if dialogue_ui and dialogue_ui.is_typing:
		dialogue_ui.skip_typewriter()
		return
		
	current_line_index += 1
	if current_line_index < dialogue_queue.size():
		if dialogue_ui:
			dialogue_ui.display_line(dialogue_queue[current_line_index])
	else:
		finish_dialogue()

func finish_dialogue() -> void:
	is_active = false
	dialogue_queue.clear()
	if dialogue_ui:
		dialogue_ui.visible = false
	dialogue_finished.emit()

func show_choice(prompt_text: String, options: Array) -> void:
	# options is Array of String, e.g. ["Menyimpan pesan Lyra", "Mengabaikan pesan"]
	is_active = true
	is_waiting_for_choice = true
	dialogue_started.emit()
	
	if dialogue_ui:
		dialogue_ui.visible = true
		dialogue_ui.display_choice(prompt_text, options)

func select_choice(index: int, text: String) -> void:
	is_waiting_for_choice = false
	is_active = false
	if dialogue_ui:
		dialogue_ui.visible = false
	choice_made.emit(index, text)
	dialogue_finished.emit()
