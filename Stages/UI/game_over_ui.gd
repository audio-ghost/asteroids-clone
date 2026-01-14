extends CanvasLayer

@onready var final_score_label: Label = $Panel/FinalScoreLabel

func set_score(score: int):
	final_score_label.text = "Final Score: %d" % score

func _on_play_again_button_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()


func _on_quit_button_pressed() -> void:
	get_tree().quit()
