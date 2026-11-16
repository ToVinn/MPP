extends Node

# Central Quest Manager for Echoes of Astra
# Tracks current active quest, objectives, and notifications

signal objective_updated(objective_text: String)
signal quest_completed(quest_name: String)

var current_quest_title: String = "Prologue: The Lost Memory"
var current_objective: String = "Periksa kristal biru di dekat pohon tua."

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func set_objective(quest_title: String, objective: String) -> void:
	current_quest_title = quest_title
	current_objective = objective
	objective_updated.emit(objective)
	print("[QuestManager] [", quest_title, "] Objective: ", objective)

func complete_quest(quest_title: String) -> void:
	quest_completed.emit(quest_title)
	print("[QuestManager] Quest Completed: ", quest_title)

