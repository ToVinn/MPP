extends Node2D

@onready var player: CharacterBody2D = $YSortEntities/Player
@onready var knight_npc: Area2D = $YSortEntities/HollowKnightNPC
@onready var temple_barrier: Area2D = $YSortEntities/TempleBarrier
@onready var main_crystal: Area2D = $YSortEntities/MainCrystal
@onready var temple_ui: CanvasLayer = $TemplePuzzleUI
@onready var memory_cutscene: CanvasLayer = $MemoryCutscene
@onready var y_sort_entities: Node2D = $YSortEntities

const MONSTER_SCENE = preload("res://prefabs/monster.tscn")

var knight_talked: bool = false
var trial_started: bool = false
var trial_completed: bool = false
var active_sentinels: int = 0
var puzzle_completed: bool = false
var memory_viewed: bool = false

func _ready() -> void:
	GameManager.set_chapter("quest3")
	main_crystal.visible = false
	player.set_camera_limits(Rect2(0, 0, 2752, 1536))
	player.set_respawn_point(Vector2(1380, 1380))
	
	knight_npc.interacted.connect(_on_knight_interacted)
	temple_barrier.interacted.connect(_on_temple_barrier_interacted)
	temple_ui.puzzle_solved.connect(_on_puzzle_solved)
	main_crystal.interacted.connect(_on_main_crystal_interacted)
	
	QuestManager.set_objective("Quest 3: The Truth of Silent Eclipse", "Temui The Hollow Knight, penjaga suci Kuil Astra.")

func _on_knight_interacted(_p: Node) -> void:
	if not knight_talked:
		knight_talked = true
		GameManager.q3_hollow_knight_spoken = true
		DialogueManager.start_dialogue([
			{"speaker": "The Hollow Knight", "text": "Berhenti."},
			{"speaker": "Aren", "text": "Aku hanya ingin mengetahui kebenarannya."},
			{"speaker": "The Hollow Knight", "text": "Kebenaran adalah sesuatu yang telah lama kau tinggalkan."},
			{"speaker": "The Hollow Knight", "text": "Ingatanmu adalah kunci. Namun hanya jiwa yang teguh yang mampu menanggung kenyataannya."},
			{"speaker": "The Hollow Knight", "text": "Buktikan bahwa tekadmu layak menerima kebenaran ini!"}
		])
		await DialogueManager.dialogue_finished
		_start_astral_trial()
	elif trial_started and not trial_completed:
		DialogueManager.start_dialogue([
			{"speaker": "The Hollow Knight", "text": "Kalahkan kedua Penjaga Astral untuk membuktikan kesiapan tekadmu!"}
		])
	elif trial_completed and not puzzle_completed:
		DialogueManager.start_dialogue([
			{"speaker": "The Hollow Knight", "text": "Altar konstelasi telah terbuka. Selaraskan piringan kuil menuju Zenith (180°)."}
		])
	else:
		DialogueManager.start_dialogue([
			{"speaker": "The Hollow Knight", "text": "Langkahmu kini menuju kebenaran sejati di hadapan Kristal Utama."}
		])

func _start_astral_trial() -> void:
	trial_started = true
	SoundManager.play_bell()
	QuestManager.set_objective("Quest 3: The Truth of Silent Eclipse", "Kalahkan 2 Penjaga Astral Kuil Astra!")
	
	active_sentinels = 2
	
	# Spawn 2 elegant Astral Sentinels dynamically into the arena flanks
	var s1 = MONSTER_SCENE.instantiate()
	s1.name = "AstralSentinel1"
	s1.monster_type = "astral_sentinel"
	s1.max_hp = 3
	s1.speed = 90.0
	s1.chase_speed = 140.0
	s1.global_position = Vector2(1180, 920)
	s1.monster_died.connect(_on_sentinel_died)
	y_sort_entities.add_child(s1)
	
	var s2 = MONSTER_SCENE.instantiate()
	s2.name = "AstralSentinel2"
	s2.monster_type = "astral_sentinel"
	s2.max_hp = 3
	s2.speed = 90.0
	s2.chase_speed = 140.0
	s2.global_position = Vector2(1580, 920)
	s2.monster_died.connect(_on_sentinel_died)
	y_sort_entities.add_child(s2)

func _on_sentinel_died(_monster: Node) -> void:
	active_sentinels -= 1
	if active_sentinels <= 0:
		trial_completed = true
		SoundManager.play_puzzle_success()
		DialogueManager.start_dialogue([
			{"speaker": "The Hollow Knight", "text": "Luar biasa. Ingatan dan tekadmu telah membuktikan kelayakanmu."},
			{"speaker": "The Hollow Knight", "text": "Altar konstelasi di depan kini dapat kau akses. Selaraskan keempat piringan kuil menuju Zenith (180°)."}
		])
		await DialogueManager.dialogue_finished
		QuestManager.set_objective("Quest 3: The Truth of Silent Eclipse", "Selesaikan mekanisme konstelasi pada altar penghalang.")

func _on_temple_barrier_interacted(_p: Node) -> void:
	if puzzle_completed:
		return
	if not trial_completed:
		DialogueManager.start_dialogue([
			{"speaker": "The Hollow Knight", "text": "Hadapilah aku terlebih dahulu sebelum mendekati altar penghalang."}
		])
		return
		
	temple_ui.open()

func _on_puzzle_solved() -> void:
	puzzle_completed = true
	GameManager.q3_puzzle_solved = true
	temple_barrier.visible = false
	main_crystal.visible = true
	QuestManager.set_objective("Quest 3: The Truth of Silent Eclipse", "Penghalang sirna! Dekati Kristal Utama Astra.")

func _on_main_crystal_interacted(_p: Node) -> void:
	if memory_viewed:
		return
	memory_viewed = true
	
	# Memory Fragment 03: Silent Eclipse
	var lines = [
		{"speaker": "Lyra", "text": "Aren! Kristalnya tidak bisa bertahan lebih lama!"},
		{"speaker": "Aren", "text": "Harus ada cara untuk menghentikannya!"},
		{"speaker": "Lyra", "text": "Kau harus pergi!"},
		{"speaker": "Aren", "text": "Aku tidak akan meninggalkanmu!"},
		{"speaker": "Aren", "text": "Jadi... inilah yang sebenarnya terjadi."},
		{"speaker": "Aren", "text": "Aku kehilangan ingatanku karena berusaha menyelamatkannya saat Silent Eclipse."}
	]
	
	memory_cutscene.play_memory(
		3,
		"INGATAN KETIGA — PERISTIWA SILENT ECLIPSE",
		lines,
		"★ Ingatan Ketiga Pulih: Aren mengingat pengorbanan dan cinta tak bersyarat untuk menyelamatkan Lyra."
	)
	await memory_cutscene.cutscene_finished
	
	# Scene 04: The Final Choice
	DialogueManager.start_dialogue([
		{"speaker": "Lyra", "text": "Aren... jika kau bisa mendengarku, jangan terburu-buru."},
		{"speaker": "Lyra", "text": "Ingatlah apa yang pernah kita janjikan."},
		{"speaker": "Aren", "text": "Aku sudah mengingat semuanya."}
	])
	await DialogueManager.dialogue_finished
	
	DialogueManager.show_choice(
		"Bagaimana caramu membangkitkan resonansi Kristal Utama untuk membebaskan Lyra?",
		[
			"A. Memahami seluruh pesan Lyra dan mengalirkan kekuatan kristal dengan hati-hati",
			"B. Memaksakan aliran kekuatan kristal secara penuh untuk membebaskannya secepat mungkin"
		]
	)
	var choice_result = await DialogueManager.choice_made
	var choice_idx = choice_result[0]
	
	if choice_idx == 0:
		GameManager.q3_choice = "A"
		GameManager.add_memory_point("Quest 3: Aliran kristal hati-hati")
	else:
		GameManager.q3_choice = "B"
		
	QuestManager.complete_quest("Quest 3: The Truth of Silent Eclipse")
	QuestManager.set_objective("Final: Takdir Akhir", "Menentukan akhir kisah Echoes of Astra...")
	
	await get_tree().create_timer(1.0).timeout
	GameManager.evaluate_ending()
