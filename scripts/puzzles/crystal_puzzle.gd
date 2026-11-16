extends CanvasLayer

# Crystal Resonance Mechanism Puzzle (Quest 1)
# 4 resonant nodes (Azure, Cobalt, Sapphire, Prism)
# Target: All 4 crystals must reach peak harmonic level 4 (4 - 4 - 4 - 4)

signal puzzle_solved

@onready var panel: PanelContainer = $PanelContainer
@onready var btn1: Button = %Btn1
@onready var btn2: Button = %Btn2
@onready var btn3: Button = %Btn3
@onready var btn4: Button = %Btn4
@onready var status_label: Label = %StatusLabel
@onready var close_btn: Button = %CloseBtn

var values = [2, 3, 1, 2]
var target = [4, 4, 4, 4]

func _ready() -> void:
	visible = false
	btn1.pressed.connect(func(): _tune_crystal(0))
	btn2.pressed.connect(func(): _tune_crystal(1))
	btn3.pressed.connect(func(): _tune_crystal(2))
	btn4.pressed.connect(func(): _tune_crystal(3))
	close_btn.pressed.connect(close)
	_update_buttons()

func open() -> void:
	visible = true
	_update_buttons()
	status_label.text = "Selaraskan keempat pilar kristal hingga mencapai resonansi penuh (4 - 4 - 4 - 4)."

func close() -> void:
	visible = false

func _tune_crystal(index: int) -> void:
	SoundManager.play_crystal()
	values[index] = (values[index] % 4) + 1
	var neighbor = (index + 1) % 4
	values[neighbor] = (values[neighbor] % 4) + 1
	
	_update_buttons()
	_check_solution()

func _update_buttons() -> void:
	var symbols = ["-", "◆ (1)", "◆◆ (2)", "◆◆◆ (3)", "★ PUNCAK (4)"]
	btn1.text = "Pilar Azure: " + symbols[values[0]]
	btn2.text = "Pilar Cobalt: " + symbols[values[1]]
	btn3.text = "Pilar Sapphire: " + symbols[values[2]]
	btn4.text = "Pilar Prisma: " + symbols[values[3]]

func _check_solution() -> void:
	if values == target:
		SoundManager.play_puzzle_success()
		status_label.text = "★ MEKANISME TERBUKA! Resonansi kristal berhasil diselaraskan sempurna!"
		btn1.disabled = true
		btn2.disabled = true
		btn3.disabled = true
		btn4.disabled = true
		await get_tree().create_timer(1.2).timeout
		visible = false
		puzzle_solved.emit()
