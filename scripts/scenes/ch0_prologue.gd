extends Node2D

@onready var player: CharacterBody2D = $YSortEntities/Player
@onready var blue_crystal: Area2D = $YSortEntities/BlueCrystal
@onready var lyra_apparition: Sprite2D = $YSortEntities/LyraApparition
@onready var eldrin_npc: Area2D = $YSortEntities/EldrinNPC
@onready var exit_door: Area2D = $YSortEntities/ExitDoor
@onready var black_curtain: ColorRect = $BlackCurtain

var awakening_done: bool = false
var crystal_examined: bool = false
var eldrin_talked: bool = false

func _ready() -> void:
	GameManager.set_chapter("prologue")
	exit_door.visible = true
	player.set_camera_limits(Rect2(0, 0, 2752, 1536))
	
	blue_crystal.interacted.connect(_on_crystal_interacted)
	eldrin_npc.interacted.connect(_on_eldrin_interacted)
	exit_door.interacted.connect(_on_exit_door_interacted)
	
	_play_awakening_cutscene()

func _play_awakening_cutscene() -> void:
	black_curtain.color.a = 1.0
	black_curtain.visible = true
	
	await get_tree().create_timer(1.0).timeout
	SoundManager.play_bell()
	
	# Fade screen in slowly
	var tween = create_tween()
	tween.tween_property(black_curtain, "color:a", 0.0, 2.0)
	await tween.finished
	black_curtain.visible = false
	
	# Awakening dialog
	DialogueManager.start_dialogue([
		{"speaker": "Aren", "text": "Di mana... aku?"},
		{"speaker": "Aren", "text": "Kenapa aku tidak mengingat apa pun?"}
	])
	await DialogueManager.dialogue_finished
	
	QuestManager.set_objective("Prologue: The Lost Memory", "Periksa kristal biru yang bersinar di sampingmu.")
	awakening_done = true

func _on_crystal_interacted(_player: Node) -> void:
	if crystal_examined:
		return
	crystal_examined = true
	GameManager.has_prologue_crystal = true
	
	# Play crystal bell chime
	SoundManager.play_bell()
	
	# Ethereal Lyra shadow apparition appears in the crystal glow
	if lyra_apparition:
		var appear_tween = create_tween()
		appear_tween.tween_property(lyra_apparition, "modulate:a", 0.75, 0.6)
	
	DialogueManager.start_dialogue([
		{"speaker": "Aren", "text": "Kristal ini... memancarkan kehangatan yang aneh."},
		{"speaker": "Gadis misterius", "text": "Aren..."},
		{"speaker": "Aren", "text": "Suara siapa itu?! Apakah bayangan tadi berasal dari dalam kristal ini?"}
	])
	await DialogueManager.dialogue_finished
	
	# Apparition gently vanishes
	if lyra_apparition:
		var vanish_tween = create_tween()
		vanish_tween.tween_property(lyra_apparition, "modulate:a", 0.0, 0.8)
	
	blue_crystal.visible = false
	QuestManager.set_objective("Prologue: The Lost Memory", "Lanjutkan perjalanan ke kanan menuju Desa Astra.")

func _on_eldrin_interacted(_player: Node) -> void:
	if not GameManager.has_prologue_crystal:
		DialogueManager.start_dialogue([
			{"speaker": "Eldrin", "text": "Hutan di sebelah kiri terasa berbahaya hari ini. Hati-hatilah anak muda."}
		])
		return
		
	if not eldrin_talked:
		eldrin_talked = true
		GameManager.spoke_with_eldrin = true
		DialogueManager.start_dialogue([
			{"speaker": "Eldrin", "text": "Kristal itu... dari mana kau mendapatkannya?"},
			{"speaker": "Aren", "text": "Aku tidak tahu. Aku bahkan tidak ingat siapa diriku."},
			{"speaker": "Eldrin", "text": "Kalau begitu, kau harus mencari jawaban di tempat-tempat yang menyimpan masa lalumu."},
			{"speaker": "Eldrin", "text": "Dahulu kala, ada tiga tempat yang terikat dengan resonansi kristal itu:"},
			{"speaker": "Eldrin", "text": "1. Gua Kristal di pegunungan utara.\n2. Desa yang Terlupakan di barat.\n3. Kuil Astra di puncak reruntuhan."},
			{"speaker": "Eldrin", "text": "Mulailah dari Gua Kristal. Di sanalah jejak ingatan pertamamu bersemayam."},
			{"speaker": "Aren", "text": "Gua Kristal... baiklah, aku akan pergi ke sana."}
		])
		await DialogueManager.dialogue_finished
		
		exit_door.visible = true
		QuestManager.set_objective("Prologue: The Lost Memory", "Gunakan gerbang di ujung desa untuk pergi ke Gua Kristal.")
	else:
		DialogueManager.start_dialogue([
			{"speaker": "Eldrin", "text": "Gerbang menuju Gua Kristal ada di sebelah kanan. Carilah masa lalumu, Aren."}
		])

func _on_exit_door_interacted(_player: Node) -> void:
	if eldrin_talked:
		QuestManager.complete_quest("Prologue: The Lost Memory")
		GameManager.change_scene("res://scenes/quests/ch1_quest1_cave.tscn", 0.8)
	else:
		DialogueManager.start_dialogue([
			{"speaker": "Aren", "text": "Gerbang ini menuju pegunungan utara. Aku sebaiknya bicara dengan orang tua di desa terlebih dahulu."}
		])

