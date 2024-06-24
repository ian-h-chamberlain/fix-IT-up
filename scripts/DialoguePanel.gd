extends Node

signal describe_problem(problem: Main.Problem)

@onready var _dialog := $MarginContainer/SpeechDialog as RichTextLabel

@export var done_delay: float = 1.0

func _ready():
    connect("describe_problem", _on_describe_problem)

func _on_describe_problem(problem: Main.Problem):
    if problem != null:
        _dialog.text = problem.dialogue_text
        self.visible = true
    else:
        _dialog.text = [
            "Amazing, thank you!",
            "Wow, you fixed it!",
            "I'll definitely recommend your services to my friends.",
        ].pick_random()
        await get_tree().create_timer(done_delay).timeout
        self.visible = false
