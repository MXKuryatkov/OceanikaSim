extends HBoxContainer
class_name TopPanel

@onready var file_dialog: FileDialog = $FileDialog
@onready var file_name: Label = %file_name
@onready var autosave_timer: Timer = $"../../autosave_timer"

@export var mission_saver: RaceEditor


func _on_popup_menu_id_pressed(id: int) -> void:
	match id:
		0:
			file_name.text = 'Новая миссия'
			mission_saver.new_mission()
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
	mission_saver.file_path = path
	_on_file_dialog_confirmed()

func _on_file_dialog_confirmed() -> void:
	if file_dialog.file_mode == FileDialog.FILE_MODE_SAVE_FILE:
		mission_saver.save_mission()
	elif file_dialog.file_mode == FileDialog.FILE_MODE_OPEN_FILE:
		mission_saver.load_mission()


func _on_autosave_timer_timeout() -> void:
	if mission_saver.file_path == "" and file_dialog.visible == false:
		file_dialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE
		file_dialog.visible = true
	elif mission_saver.file_path != "":
		mission_saver.save_mission()
	#elif file_dialog.visible == true:
	autosave_timer.start()


func _on_objects_child_entered_tree(node: Node) -> void:
	if mission_saver.file_path == "":
		file_dialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE
		file_dialog.visible = true
	autosave_timer.start()
	


func _on_file_dialog_close_requested() -> void:	
	autosave_timer.start()
