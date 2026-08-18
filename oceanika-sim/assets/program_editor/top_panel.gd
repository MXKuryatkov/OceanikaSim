extends HBoxContainer


@onready var file_dialog: FileDialog = $FileDialog
@onready var file_name: Label = %file_name
@onready var autosave_timer: Timer = $"../autosave_timer"
@export var program_saver: Node


func _on_popup_menu_id_pressed(id: int) -> void:
	match id:
		0:
			file_name.text = 'Новая программа'
			program_saver.new_program()
		1:
			file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
			file_dialog.visible = true
		2:
			file_dialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE
			file_dialog.visible = true
	autosave_timer.start()

func _on_file_dialog_file_selected(path: String) -> void:
	file_dialog.current_file = file_name.text
	file_name.text = path.get_file()
	program_saver.program_file_path = path
	_on_file_dialog_confirmed()

func _on_file_dialog_confirmed() -> void:
	if file_dialog.file_mode == FileDialog.FILE_MODE_SAVE_FILE:
		program_saver.save_program()
	elif file_dialog.file_mode == FileDialog.FILE_MODE_OPEN_FILE:
		program_saver.load_program()


func _on_autosave_timer_timeout() -> void:
	if program_saver.program_file_path == "" and file_dialog.visible == false:
		file_dialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE
		file_dialog.visible = true
	elif program_saver.program_file_path != "":
		program_saver.save_program()
	autosave_timer.start()


func _on_file_dialog_close_requested() -> void:	
	autosave_timer.start()
