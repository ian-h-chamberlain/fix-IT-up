extends ColorRect
class_name SceneTransition

## Whether the current scene should animate a transition in
@export var fade_in: bool = true

func _ready():
    if fade_in:
        self.mouse_filter = Control.MOUSE_FILTER_STOP
        $AnimationPlayer.play_backwards("fade_out")

    self.mouse_filter = Control.MOUSE_FILTER_PASS

func transition(next_scene: String):
    self.mouse_filter = Control.MOUSE_FILTER_STOP

    $AnimationPlayer.play("fade_out")
    await $AnimationPlayer.animation_finished
    get_tree().change_scene_to_file(next_scene)
