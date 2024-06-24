extends ConfirmationDialog

@export_file("*.tscn") var menu_scene: String

func _ready():
    self.confirmed.connect(func(): $"../SceneTransition".transition(menu_scene))

func _on_menu_button_pressed():
    self.visible = true
