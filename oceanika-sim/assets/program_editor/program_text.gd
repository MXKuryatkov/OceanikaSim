extends VBoxContainer

@onready var program_text: TextEdit = $program_text
@onready var file_dialog: FileDialog = $top_panel/FileDialog
@onready var program_editor: ProgramEditor = $"../.."


func _ready() -> void:
	_on_program_text_text_changed()


func _on_program_text_text_changed() -> void:
	if program_text.text == '':
		hide()
	else:
		show()


func _on_popup_menu_id_pressed(id: int) -> void:
	match id:
		0:
			program_text.text = ''
			_on_program_text_text_changed()
		1:
			file_dialog.visible = true
			file_dialog.clear_filters()
			match DroneToProgram.current_drone:
				DroneToProgram.Drone.kit:
					file_dialog.add_filter('*.py', 'Python3 files')
				DroneToProgram.Drone.piranya:
					file_dialog.add_filter('*.ino', 'Arduino files')




func _on_file_dialog_file_selected(path: String) -> void:
	var file = FileAccess.open(path, FileAccess.WRITE)
	if file:
		file.store_string(program_text.text)
