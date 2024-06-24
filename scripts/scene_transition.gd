extends ColorRect
class_name SceneTransition

## Whether the current scene should animate a transition in
@export var fade_in: bool = true

func _ready():
    if fade_in:
        self.mouse_filter = Control.MOUSE_FILTER_STOP
        $AnimationPlayer.play_backwards("fade_out")

    self.mouse_filter = Control.MOUSE_FILTER_IGNORE

# Big oof using "": https://github.com/godotengine/godot-proposals/issues/162
func transition(next_scene: String=""):
    self.mouse_filter = Control.MOUSE_FILTER_STOP

    $AnimationPlayer.play("fade_out")
    await $AnimationPlayer.animation_finished
    if next_scene != "":
        get_tree().change_scene_to_file(next_scene)
    else:
        get_tree().reload_current_scene()
        $AnimationPlayer.play_backwards("fade_out")
