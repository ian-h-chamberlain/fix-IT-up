extends Node

@export var game_scene: PackedScene
@export_multiline var help_text: String

# Called when the node enters the scene tree for the first time.
func _ready():
    $Menu/Buttons/Start.grab_focus()
    $Menu/Buttons/Start.pressed.connect(func(): get_tree().change_scene_to_packed(game_scene))
    $Menu/Buttons/Settings.pressed.connect(func(): $SettingsDialog.visible=true)
    $Menu/Buttons/Help.pressed.connect(func(): $HelpDialog.visible=true)

    $Menu/Credits.meta_clicked.connect(_credits_on_meta_clicked)

# https://docs.godotengine.org/en/4.2/tutorials/ui/bbcode_in_richtextlabel.html#handling-url-tag-clicks
func _credits_on_meta_clicked(meta):
    OS.shell_open(str(meta))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    pass
