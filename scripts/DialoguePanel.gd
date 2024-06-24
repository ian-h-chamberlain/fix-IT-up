extends Node

signal describe_problem(problem: Main.Problem)

@onready var _dialog := $MarginContainer/SpeechDialog as RichTextLabel
@onready var _dialog_anim := _dialog.get_node("AnimationPlayer") as AnimationPlayer

@export var done_delay: float = 1.0
@export var anim_speed: float = 1.0

func _ready():
    connect("describe_problem", _on_describe_problem)

func _on_describe_problem(problem: Main.Problem):
    if problem != null:
        _animate_text(problem.dialogue_text)
        self.visible = true
    else:
        await _animate_text([
            "Amazing, thank you!",
            "Wow, you fixed it!",
            "I'll definitely recommend your services to my friends.",
        ].pick_random())
        await get_tree().create_timer(done_delay).timeout
        self.visible = false

func _animate_text(text: String):
    _dialog.text = text
    _dialog_anim.speed_scale = anim_speed / _dialog.get_total_character_count()
    _dialog_anim.stop()
    _dialog_anim.play("dialogue")
    await _dialog_anim.animation_finished
