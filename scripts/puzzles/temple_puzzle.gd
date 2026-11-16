extends CanvasLayer

# Temple Constellation Mechanism Puzzle (Quest 3)
# 4 celestial dials (Surya, Rembulan, Gerhana, Astra)
# Target: All 4 dials aligned to Zenith (180°)

signal puzzle_solved

@onready var status_label: Label = %StatusLabel
@onready var dial1_btn: Button = %Dial1Btn
@onready var dial2_btn: Button = %Dial2Btn
@onready var dial3_btn: Button = %Dial3Btn
@onready var dial4_btn: Button = %Dial4Btn
@onready var close_btn: Button = %CloseBtn

var angles = [90, 0, 270, 90] # Target is [180, 180, 180, 180]

func _ready() -> void:
	visible = false
	dial1_btn.pressed.connect(func(): _rotate_dial(0))
	dial2_btn.pressed.connect(func(): _rotate_dial(1))
	dial3_btn.pressed.connect(func(): _rotate_dial(2))
	dial4_btn.pressed.connect(func(): _rotate_dial(3))
	close_btn.pressed.connect(close)
	_update_labels()

func open() -> void:
	visible = true
	_update_labels()
	status_label.text = "Selaraskan keempat piringan konstelasi kuil menuju Zenith (180°)."

func close() -> void:
	visible = false

func _rotate_dial(index: int) -> void:
	SoundManager.play_select()
	angles[index] = (angles[index] + 90) % 360
	
	# Harmonic linkage to linked dial
	var linked = (index + 1) % 4
	angles[linked] = (angles[linked] + 90) % 360
	
	_update_labels()
	_check_solution()

func _update_labels() -> void:
	dial1_btn.text = "Piringan Surya: " + str(angles[0]) + "°" + (" [Zenith]" if angles[0] == 180 else "")
	dial2_btn.text = "Piringan Rembulan: " + str(angles[1]) + "°" + (" [Zenith]" if angles[1] == 180 else "")
	dial3_btn.text = "Piringan Gerhana: " + str(angles[2]) + "°" + (" [Zenith]" if angles[2] == 180 else "")
	dial4_btn.text = "Piringan Bintang Astra: " + str(angles[3]) + "°" + (" [Zenith]" if angles[3] == 180 else "")

func _check_solution() -> void:
	if angles[0] == 180 and angles[1] == 180 and angles[2] == 180 and angles[3] == 180:
		SoundManager.play_puzzle_success()
		status_label.text = "★ PENGHALANG SIRNA! Seluruh konstelasi kuil telah selaras sempurna!"
		dial1_btn.disabled = true
		dial2_btn.disabled = true
		dial3_btn.disabled = true
		dial4_btn.disabled = true
		await get_tree().create_timer(1.2).timeout
		visible = false
		puzzle_solved.emit()
