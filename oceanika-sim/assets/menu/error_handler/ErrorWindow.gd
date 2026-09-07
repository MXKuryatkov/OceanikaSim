class_name ErrorWindow
extends Popup

const max_error_queue_size = 100

static var error_queue: Array = []
static var instance: ErrorWindow = null

@onready var error_text: Label = %ErrorText
@onready var close_all_button: Button = %CloseAllButton
@onready var counter_label: Label = %CounterLabel

static func push_error(tag: String, text: String):
	error_queue.push_back(tag + ": " + text)
	if instance == null:
		print("No error window to display the error")
	else:
		instance.update_errors()

func _ready() -> void:
	if instance == null:
		instance = self
	else:
		ErrorWindow.push_error("ErrorWindow", "There can be only one.")

func update_errors():
	if not error_queue.is_empty():
		var error: String = error_queue[0]
		error_text.text = error
		if error_queue.size() > 1:
			close_all_button.show()
			counter_label.text = "+" + str(error_queue.size() - 1)
			counter_label.show()
		else:
			close_all_button.hide()
			counter_label.hide()
		if not visible:
			popup_centered()
	else:
		hide()

func _on_popup_hide() -> void:
	if error_queue.size() > 0:
		error_queue.pop_front()
		update_errors()

func _on_close_all() -> void:
	error_queue.clear()
	update_errors()
