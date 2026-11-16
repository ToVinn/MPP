extends Node2D

@onready var player: CharacterBody2D = $YSortEntities/Player
@onready var frag1: Area2D = $YSortEntities/Fragment1
@onready var frag2: Area2D = $YSortEntities/Fragment2
@onready var frag3: Area2D = $YSortEntities/Fragment3
@onready var puzzle_door: Area2D = $YSortEntities/PuzzleDoor
@onready var memory_altar: Area2D = $YSortEntities/MemoryAltar
@onready var puzzle_ui: CanvasLayer = $CrystalPuzzleUI
@onready var memory_cutscene: CanvasLayer = $MemoryCutscene
@onready var exit_door: Area2D = $YSortEntities/ExitDoor

var fragments_collected: int = 0
var puzzle_completed: bool = false
var memory_viewed: bool = false
var choice_resolved: bool = false

func _ready() -> void:
	GameManager.set_chapter("quest1")
	exit_door.visible = false
	memory_altar.visible = false
	player.set_camera_limits(Rect2(0, 0, 2752, 1536))
	player.set_respawn_point(Vector2(360, 200))
	
	frag1.interacted.connect(func(_p): _collect_fragment(frag1))
	frag2.interacted.connect(func(_p): _collect_fragment(frag2))
	frag3.interacted.connect(func(_p): _collect_fragment(frag3))
	
	puzzle_door.interacted.connect(_on_puzzle_door_interacted)
	puzzle_ui.puzzle_solved.connect(_on_puzzle_solved)
	
	memory_altar.interacted.connect(_on_memory_altar_interacted)
	exit_door.interacted.connect(_on_exit_door_interacted)
	
	QuestManager.set_objective("Quest 1: The Forgotten Cave", "Kumpulkan 3 Fragmen Kristal yang tersebar di dalam gua (0/3).")

func _collect_fragment(frag_node: Area2D) -> void:
	frag_node.visible = false
	frag_node.queue_free()
	fragments_collected += 1
	GameManager.q1_fragments_collected = fragments_collected
	SoundManager.play_crystal()
	
	if fragments_collected < 3:
		QuestManager.set_objective("Quest 1: The Forgotten Cave", "Kumpulkan Fragmen Kristal (" + str(fragments_collected) + "/3).")
	else:
		QuestManager.set_objective("Quest 1: The Forgotten Cave", "Semua fragmen terkumpul! Periksa mekanisme pintu kuno di depan.")

func _on_puzzle_door_interacted(_p: Node) -> void:
	if puzzle_completed:
		return
	if fragments_collected < 3:
		DialogueManager.start_dialogue([
			{"speaker": "Aren", "text": "Mekanisme pintu ini membutuhkan 3 fragmen kristal agar dapat diaktifkan."}
		])
		return
		
	# Open puzzle UI
	puzzle_ui.open()

func _on_puzzle_solved() -> void:
	puzzle_completed = true
	GameManager.q1_puzzle_solved = true
	puzzle_door.visible = false
	memory_altar.visible = true
	QuestManager.set_objective("Quest 1: The Forgotten Cave", "Pintu terbuka! Dekati kristal altar untuk memulihkan ingatan.")

func _on_memory_altar_interacted(_p: Node) -> void:
	if memory_viewed:
		return
	memory_viewed = true
	
	# Trigger Memory Fragment 01
	var lines = [
		{"speaker": "Lyra", "text": "Aren, jangan sampai kau melupakan tempat ini."},
		{"speaker": "Aren kecil", "text": "Kenapa?"},
		{"speaker": "Lyra", "text": "Karena suatu hari nanti, kau mungkin harus kembali."},
		{"speaker": "Aren", "text": "Lyra... siapa dia?"},
		{"speaker": "Aren", "text": "Kenapa aku merasa pernah mengenalnya begitu dekat?"}
	]
	
	memory_cutscene.play_memory(
		1,
		"INGATAN PERTAMA — PERTEMUAN DI GUA KRISTAL",
		lines,
		"★ Ingatan Pertama Pulih: Aren mengetahui bahwa Lyra adalah seseorang yang sangat dekat dengannya."
	)
	await memory_cutscene.cutscene_finished
	
	# Scene 04: Pilihan Pertama
	DialogueManager.show_choice(
		"Aren menemukan pesan yang ditinggalkan Lyra di dekat kristal:\n'Bagi yang mencari cahaya, jangan biarkan waktu menghapus janji.'",
		[
			"A. Menyimpan pesan Lyra dan berusaha memahaminya",
			"B. Mengabaikan pesan tersebut dan langsung melanjutkan perjalanan"
		]
	)
	var choice_result = await DialogueManager.choice_made
	var choice_idx = choice_result[0]
	
	if choice_idx == 0:
		GameManager.q1_choice = "A"
		GameManager.add_memory_point("Quest 1: Menyimpan pesan Lyra")
		DialogueManager.start_dialogue([
			{"speaker": "Aren", "text": "Pesan ini pasti memiliki arti penting. Aku akan menyimpannya baik-baik."}
		])
	else:
		GameManager.q1_choice = "B"
		DialogueManager.start_dialogue([
			{"speaker": "Aren", "text": "Aku tidak punya waktu untuk memikirkan pesan ini sekarang. Aku harus terus maju."}
		])
	await DialogueManager.dialogue_finished
	
	choice_resolved = true
	exit_door.visible = true
	QuestManager.complete_quest("Quest 1: The Forgotten Cave")
	QuestManager.set_objective("Quest 1: Selesai", "Keluarlah dari gua menuju Desa yang Terlupakan.")

func _on_exit_door_interacted(_p: Node) -> void:
	if choice_resolved:
		GameManager.change_scene("res://scenes/quests/ch2_quest2_village.tscn", 0.8)

