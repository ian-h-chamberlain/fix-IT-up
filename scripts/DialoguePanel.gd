extends Node

@onready var _speech_bubble: RichTextLabel = $"MarginContainer/SpeechDialog"

func _on_describe_problem(problems: Array[Main.Problem]):
	if problems.is_empty():
		self.visible = false
		return

	self.visible = true
	_speech_bubble.text = problems[0].dialogue_text
