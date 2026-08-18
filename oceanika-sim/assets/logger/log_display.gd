class_name LoggerDisplay
extends Control

@onready var monitors_label: RichTextLabel = %Monitors
@onready var messages_label: RichTextLabel = %Messages

@export var auto_update_properties: Dictionary[Node, String]
@export var auto_update_root: Node

var colors = {
	Log.Level.Error: Color.DARK_RED,
	Log.Level.Warning: Color.YELLOW,
	Log.Level.Info: Color.LIGHT_BLUE,
	Log.Level.Debug: Color.WHITE,
}

func _ready() -> void:
	Log.new_message.connect(message)
	Log.update_monitors.connect(update_monitors)

func _process(_delta: float) -> void:
	if visible:
		update_monitors()

func update_monitors():
	var text = ""
	for property in auto_update_properties.keys():
		if property != null:
			text += auto_update_properties[property] + ": " + str(property.get(auto_update_properties[property])) + "\n"
	for i in Log.monitors.keys():
		text += i + ": " + Log.monitors[i] + "\n"
	monitors_label.text = text.trim_suffix("\n")

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_action_pressed("toggle_log"):
		visible = not visible

func message(text: String, level: Log.Level=Log.Level.Debug):
	messages_label.push_color(colors[level])
	messages_label.append_text(text)
	messages_label.pop()
	messages_label.newline()
