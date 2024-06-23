extends Node

signal describe_problem(problem: Main.Problem)

@onready var _dialog := $MarginContainer/SpeechDialog as RichTextLabel

func _ready():
    connect("describe_problem", _on_describe_problem)

func _on_describe_problem(problem: Main.Problem):
    if problem != null:
        _dialog.text = problem.dialogue_text
        self.visible = true
    else:
        self.visible = false
