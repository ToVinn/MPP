extends Node2D

@onready var player: CharacterBody2D = $YSortEntities/Player
@onready var page1: Area2D = $YSortEntities/Page1
@onready var page2: Area2D = $YSortEntities/Page2
@onready var page3: Area2D = $YSortEntities/Page3
@onready var page4: Area2D = $YSortEntities/Page4
@onready var secret_door: Area2D = $YSortEntities/SecretDoor
@onready var hill_altar: Area2D = $YSortEntities/HillAltar
@onready var diary_ui: CanvasLayer = $DiaryPuzzleUI
@onready var memory_cutscene: CanvasLayer = $MemoryCutscene
@onready var exit_door: Area2D = $YSortEntities/ExitDoor

var pages_collected: int = 0
var puzzle_completed: bool = false
var memory_viewed: bool = false
var choice_resolved: bool = false

func _ready() -> void:
	GameManager.set_chapter("quest2")
	exit_door.visible = false
	hill_altar.visible = false
	player.set_camera_limits(Rect2(0, 0, 2752, 1536))
	player.set_respawn_point(Vector2(250, 750))
	
	page1.interacted.connect(func(_p): _collect_page(page1))
	page2.interacted.connect(func(_p): _collect_page(page2))
	page3.interacted.connect(func(_p): _collect_page(page3))
	page4.interacted.connect(func(_p): _collect_page(page4))
	
	secret_door.interacted.connect(_on_secret_door_interacted)
	diary_ui.puzzle_solved.connect(_on_puzzle_solved)
	
	hill_altar.interacted.connect(_on_hill_altar_interacted)
	exit_door.interacted.connect(_on_exit_door_interacted)
	
	QuestManager.set_objective("Quest 2: The Forgotten Promise", "Cari 4 lembar catatan harian Lyra di reruntuhan desa (0/4).")

func _collect_page(page_node: Area2D) -> void:
	page_node.visible = false
	page_node.queue_free()
	pages_collected += 1
	GameManager.q2_pages_collected = pages_collected
	SoundManager.play_select()
	
	if pages_collected < 4:
		QuestManager.set_objective("Quest 2: The Forgotten Promise", "Cari lembar catatan harian Lyra (" + str(pages_collected) + "/4).")
	else:
		QuestManager.set_objective("Quest 2: The Forgotten Promise", "Semua catatan terkumpul! Buka pintu rahasia di bukit utara.")

func _on_secret_door_interacted(_p: Node) -> void:
	if puzzle_completed:
		return
	if pages_collected < 4:
		DialogueManager.start_dialogue([
			{"speaker": "Aren", "text": "Pintu rahasia ini membutuhkan 4 lembar catatan harian untuk memecahkan urutan segelnya."}
		])
		return
		
	diary_ui.open()

func _on_puzzle_solved() -> void:
	puzzle_completed = true
	GameManager.q2_puzzle_solved = true
	secret_door.visible = false
	hill_altar.visible = true
	QuestManager.set_objective("Quest 2: The Forgotten Promise", "Pintu rahasia terbuka! Naiki puncak bukit untuk memeriksa ingatan janji masa lalu.")

func _on_hill_altar_interacted(_p: Node) -> void:
	if memory_viewed:
		return
	memory_viewed = true
	
	var lines = [
		{"speaker": "Lyra", "text": "Aren, berjanjilah padaku."},
		{"speaker": "Aren", "text": "Apa?"},
		{"speaker": "Lyra", "text": "Jika suatu hari semuanya menghilang, jangan berhenti mencariku."},
		{"speaker": "Aren", "text": "Aku berjanji."},
		{"speaker": "Aren", "text": "Jadi... aku pernah berjanji kepadanya."},
		{"speaker": "Aren", "text": "Tapi kenapa aku melupakan semuanya?"}
	]
	
	memory_cutscene.play_memory(
		2,
		"INGATAN KEDUA — JANJI DI ATAS BUKIT",
		lines,
		"★ Ingatan Kedua Pulih: Aren mengingat janji suci yang pernah dibuatnya bersama Lyra."
	)
	await memory_cutscene.cutscene_finished
	
	# Scene 04: Pilihan Kedua
	DialogueManager.show_choice(
		"Aren menemukan sebuah surat kuno yang ditulis Lyra, berisi petunjuk penting tentang Kuil Astra:",
		[
			"A. Membaca seluruh surat dan meresapi pesan Lyra",
			"B. Mengambil surat tanpa membacanya dan langsung bergegas ke kuil"
		]
	)
	var choice_result = await DialogueManager.choice_made
	var choice_idx = choice_result[0]
	
	if choice_idx == 0:
		GameManager.q2_choice = "A"
		GameManager.add_memory_point("Quest 2: Membaca seluruh surat")
		DialogueManager.start_dialogue([
			{"speaker": "Aren", "text": "'Kekuatan kristal kuil bukanlah senjata, melainkan cerminan ikatan jiwa...' Aku mengerti sekarang, Lyra."}
		])
	else:
		GameManager.q2_choice = "B"
		DialogueManager.start_dialogue([
			{"speaker": "Aren", "text": "Tak ada waktu membaca kata-kata panjang ini. Aku harus segera sampai di Kuil Astra!"}
		])
	await DialogueManager.dialogue_finished
	
	choice_resolved = true
	exit_door.visible = true
	QuestManager.complete_quest("Quest 2: The Forgotten Promise")
	QuestManager.set_objective("Quest 2: Selesai", "Lanjutkan pendakian menuju Kuil Astra.")

func _on_exit_door_interacted(_p: Node) -> void:
	if choice_resolved:
		GameManager.change_scene("res://scenes/quests/ch3_quest3_temple.tscn", 0.8)
