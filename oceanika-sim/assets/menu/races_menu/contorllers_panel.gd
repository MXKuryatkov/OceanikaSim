extends Panel


@onready var controllers_container: VBoxContainer = $controllers_container
var text_color: Color = Color("004288ff")
var connected_controllers: Array = []
@onready var controller_name: Label = $"../controller_detection/VBoxContainer/controller_name"


func _ready() -> void:
	hide()


func _process(_delta: float) -> void:
	controller_name.text = OceanikaMode.controller_name
	if not OceanikaMode.current_vendor_id == 0:
		%buttons_hint.texture = OceanikaMode.hints[OceanikaMode.current_vendor_id]
	else:
		%buttons_hint.texture = null
	




func _on_visibility_changed() -> void:
	if controllers_container == null: return
	connected_controllers = Input.get_connected_joypads()

	for j in connected_controllers:
		Log.monitor('j'+ str(j), Input.get_joy_info(j))
		var button: Button = Button.new()
		button.text = Input.get_joy_name(j)
		button.add_theme_color_override("font_color", text_color)
		button.add_theme_color_override("font_focus_color", text_color)
		button.add_theme_color_override("font_pressed_color", text_color)
		button.add_theme_color_override("font_hover_color", text_color)
		button.add_theme_stylebox_override("normal", preload('res://assets/menu/styles/button_normal.tres'))
		button.add_theme_stylebox_override("pressed", preload('res://assets/menu/styles/button_pressed.tres'))
		button.add_theme_stylebox_override("hover", preload('res://assets/menu/styles/button_hover.tres'))
		button.add_theme_stylebox_override("focus", preload('res://assets/menu/styles/button_focus.tres'))
		button.pressed.connect(on_button_pressed.bind(button))

		controllers_container.add_child(button)
		
		size.x = controllers_container.size.x + 15
		set_anchors_and_offsets_preset(Control.PRESET_CENTER, Control.PRESET_MODE_KEEP_SIZE)
		


func _on_hidden() -> void:
	for button in controllers_container.get_children():
		button.queue_free()

func on_button_pressed(button: Button):
	var joypads_names = []
	for j in Input.get_connected_joypads():
		joypads_names.append(Input.get_joy_name(j))

	if button.text in joypads_names:
		OceanikaMode.controller_prefix = OceanikaMode.vendor_id_match[int(get_vendor_id(button.text))]
		controller_name.text = button.text
		controller_name.show()
		print(get_vendor_id(button.text))
		%buttons_hint.texture = OceanikaMode.hints[int(get_vendor_id(button.text))]
		
		hide()
	else:
		button.queue_free()


func get_vendor_id(_name: String) -> String:
	for j in Input.get_connected_joypads():
		if Input.get_joy_name(j) == _name:
			return Input.get_joy_info(j)['vendor_id']
	return ''
