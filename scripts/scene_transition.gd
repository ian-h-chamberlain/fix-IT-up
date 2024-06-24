extends ColorRect
class_name SceneTransition

## Whether the current scene should animate a transition in
@export var fade_in: bool = true

func _ready():
    if fade_in:
        $AnimationPlayer.play_backwards("fade_out")

    if get_parent() == get_tree().root:
        # Testing in its own scene
        await $AnimationPlayer.animation_finished
        await get_tree().create_timer(1.0).timeout
        transition()

func transition(next_scene: PackedScene=null):
    $AnimationPlayer.play("fade_out")
    await $AnimationPlayer.animation_finished
    if next_scene == null:
        get_tree().reload_current_scene()
    else:
        get_tree().change_scene_to_packed(next_scene)
