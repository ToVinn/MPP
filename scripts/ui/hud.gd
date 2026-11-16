extends CanvasLayer

@onready var quest_title_label: Label = %QuestTitleLabel
@onready var objective_label: Label = %ObjectiveLabel
@onready var memory_points_label: Label = %MemoryPointsLabel
@onready var notification_banner: PanelContainer = %NotificationBanner
@onready var notification_label: Label = %NotificationLabel
@onready var health_label: Label = %HealthLabel
@onready var pause_menu: PanelContainer = %PauseMenu
@onready var resume_btn: Button = %ResumeBtn
@onready var save_btn: Button = %SaveBtn
@onready var quit_btn: Button = %QuitBtn

var notif_tween: Tween = null
var player_ref: CharacterBody2D = null

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS # Allows processing while game paused
	
	QuestManager.objective_updated.connect(_on_objective_updated)
	GameManager.memory_points_changed.connect(_on_memory_points_changed)
	
	quest_title_label.text = QuestManager.current_quest_title
	objective_label.text = "Objektif: " + QuestManager.current_objective
	_update_memory_points(GameManager.memory_points)
	
	notification_banner.modulate.a = 0.0
	pause_menu.visible = false
	
	resume_btn.pressed.connect(_on_resume_pressed)
	save_btn.pressed.connect(_on_save_pressed)
	quit_btn.pressed.connect(_on_quit_pressed)
	
	_hook_player()

func _hook_player() -> void:
	var players = get_tree().get_nodes_in_group("player")
	if not players.is_empty():
		player_ref = players[0]
		player_ref.health_changed.connect(_on_health_changed)
		player_ref.player_died.connect(_on_player_died)
		player_ref.player_respawned.connect(_on_player_respawned)
		_update_health(player_ref.current_hp, player_ref.max_hp)
	else:
		_update_health(5, 5)

func _process(_delta: float) -> void:
	if not is_instance_valid(player_ref):
		_hook_player()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause_game") or (event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE):
		if not DialogueManager.is_active:
			_toggle_pause()

func _toggle_pause() -> void:
	var is_paused = not get_tree().paused
	get_tree().paused = is_paused
	pause_menu.visible = is_paused
	if is_paused:
		SoundManager.play_select()
		resume_btn.grab_focus()

func _on_resume_pressed() -> void:
	SoundManager.play_select()
	get_tree().paused = false
	pause_menu.visible = false

func _on_save_pressed() -> void:
	SoundManager.play_select()
	if GameManager.save_game():
		show_notification("★ Progres permainan berhasil disimpan!")
	else:
		show_notification("Gagal menyimpan permainan.")

func _on_quit_pressed() -> void:
	SoundManager.play_select()
	get_tree().paused = false
	GameManager.change_scene("res://scenes/title_screen.tscn", 0.6)

func _on_health_changed(curr: int, max_h: int) -> void:
	_update_health(curr, max_h)

func _on_player_died() -> void:
	show_notification("Aren terluka parah! Memulihkan ingatan di titik aman...")

func _on_player_respawned() -> void:
	show_notification("Aren bangkit kembali dengan tekad baru.")

func _update_health(curr: int, max_h: int) -> void:
	if not health_label:
		return
	var hearts = ""
	for i in range(max_h):
		if i < curr:
			hearts += "♥ "
		else:
			hearts += "♡ "
	health_label.text = "Vitalitas: " + hearts.strip_edges()

func _on_objective_updated(new_objective: String) -> void:
	quest_title_label.text = QuestManager.current_quest_title
	objective_label.text = "Objektif: " + new_objective
	show_notification("Tujuan Baru: " + new_objective)

func _on_memory_points_changed(points: int) -> void:
	_update_memory_points(points)
	show_notification("★ Memory Point Bertambah! (" + str(points) + "/3)")

func _update_memory_points(points: int) -> void:
	var stars = ""
	for i in range(3):
		if i < points:
			stars += "◆ "
		else:
			stars += "◇ "
	memory_points_label.text = "Ingatan: " + stars + " (" + str(points) + "/3)"

func show_notification(msg: String) -> void:
	notification_label.text = msg
	if notif_tween:
		notif_tween.kill()
		
	notif_tween = create_tween()
	notif_tween.tween_property(notification_banner, "modulate:a", 1.0, 0.3)
	notif_tween.tween_interval(3.0)
	notif_tween.tween_property(notification_banner, "modulate:a", 0.0, 0.4)
