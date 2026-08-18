class_name SelectionButton
extends Button

var editor: RaceEditor
var scene: EditorScene
var configurator = null

func _ready() -> void:
	toggle_mode = true
	add_to_group("selection_buttons")
	pressed.connect(on_pressed)

func on_pressed():
	if configurator:
		if configurator.active:
			configurator.set_node(scene.id)
			if configurator.has_method("set_node_name"):
				configurator.set_node_name(scene.object.display_name)
			button_pressed = not button_pressed
		else:
			select_scene()
		configurator = null
	else:
		select_scene()

func configure_selector(conf):
	configurator = conf

func update_selection():
	set_pressed_no_signal(editor.selected_scene == scene)

func select_scene():
	if editor.selected_scene == scene:
		editor.select_scene(null)
	else:
		editor.select_scene(scene)
