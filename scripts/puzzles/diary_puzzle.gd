extends CanvasLayer

# Diary Reconstruction Puzzle (Quest 2)
# Arranging 4 chronological journal entries to unlock the secret hill vault

signal puzzle_solved

@onready var status_label: Label = %StatusLabel
@onready var page_btn1: Button = %PageBtn1
@onready var page_btn2: Button = %PageBtn2
@onready var page_btn3: Button = %PageBtn3
@onready var page_btn4: Button = %PageBtn4
@onready var reset_btn: Button = %ResetBtn
@onready var close_btn: Button = %CloseBtn

var pages = [
	{"id": 1, "text": "Catatan A (Janji di Bukit)"},
	{"id": 2, "text": "Catatan B (Awal Kegelapan Eclipse)"},
	{"id": 3, "text": "Catatan C (Runtuhnya Desa Astra)"},
	{"id": 4, "text": "Catatan D (Segel Kuil & Penantian)"}
]

# Correct chronological sequence:
# 1 (Janji) -> 2 (Eclipse) -> 3 (Desa Runtuh) -> 4 (Kuil & Penantian)
var correct_order = [1, 2, 3, 4]
var current_selection = []

func _ready() -> void:
	visible = false
	page_btn1.pressed.connect(func(): _select_page(0))
	page_btn2.pressed.connect(func(): _select_page(1))
	page_btn3.pressed.connect(func(): _select_page(2))
	page_btn4.pressed.connect(func(): _select_page(3))
	reset_btn.pressed.connect(_reset_selection)
	close_btn.pressed.connect(close)

func open() -> void:
	visible = true
	_reset_selection()

func close() -> void:
	visible = false

func _select_page(index: int) -> void:
	SoundManager.play_select()
	var page = pages[index]
	if page["id"] in current_selection:
		return
		
	current_selection.append(page["id"])
	match index:
		0: page_btn1.disabled = true
		1: page_btn2.disabled = true
		2: page_btn3.disabled = true
		3: page_btn4.disabled = true
		
	status_label.text = "Urutan terpilih: " + str(current_selection.size()) + " dari 4 catatan."
	
	if current_selection.size() == 4:
		if current_selection == correct_order:
			SoundManager.play_puzzle_success()
			status_label.text = "★ BENAR! Halaman tersusun sempurna! Pintu rahasia desa terbuka!"
			await get_tree().create_timer(1.2).timeout
			visible = false
			puzzle_solved.emit()
		else:
			status_label.text = "Urutan belum tepat. Narasi sejarah terasa rancu. Coba lagi."
			await get_tree().create_timer(1.2).timeout
			_reset_selection()

func _reset_selection() -> void:
	current_selection.clear()
	page_btn1.disabled = false
	page_btn2.disabled = false
	page_btn3.disabled = false
	page_btn4.disabled = false
	status_label.text = "Pilih urutan catatan: Mulai dari masa damai hingga ramalan Silent Eclipse."
