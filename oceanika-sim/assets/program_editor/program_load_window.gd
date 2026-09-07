extends Window
class_name ProgramLoadWindow

@onready var path_line: LineEdit = %path_line
@onready var file_dialog: FileDialog = $FileDialog
@onready var program_editor: ProgramEditor = $".."
@onready var program_text: TextEdit = $VBoxContainer/program_text/program_text
@onready var compile_console: CompileConsole = %compile_console
@onready var upload_progress_bar: ProgressBar = %UploadProgressBar
@onready var saved_label: Label = $VBoxContainer/HBoxContainer/saved_label

var main_directory_path = ''
var project_directory_name = ''
var file_name = ''
var file_type = ''

func _ready() -> void:
	saved_label.hide()
	hide()
	if DroneToProgram.current_drone == DroneToProgram.Drone.kit:
		file_type = 'py'
		$VBoxContainer/HBoxContainer/load_to_kit.show()
	elif DroneToProgram.current_drone == DroneToProgram.Drone.piranya:
		file_type = 'ino'
		$VBoxContainer/HBoxContainer/load_to_kit.hide()

	compile_console.hide()
	upload_progress_bar.hide()

func _on_load_to_robot_pressed() -> void:
	_on_save_pressed()
	program_text.editable = false
	if DroneToProgram.current_drone == DroneToProgram.Drone.kit:
		program_editor.upload_kit()

func _on_save_pressed() -> void:
	if main_directory_path == '':
		main_directory_path = ProjectSettings.globalize_path("user://").left(-1)
		project_directory_name = program_editor.file_name.remove_chars(program_editor.file_name.get_extension()).left(-1)
		file_name = project_directory_name
		program_editor.file_path = main_directory_path + '/' + project_directory_name + '/' + file_name + '.' + file_type
	program_text.editable = false

	var path = main_directory_path + '/' + project_directory_name + '/' + file_name + '.' + file_type
	var parent_folder = path.get_base_dir()

	if not DirAccess.dir_exists_absolute(parent_folder):
		DirAccess.make_dir_recursive_absolute(parent_folder)

	var file = FileAccess.open(path, FileAccess.WRITE)
	if file:
		file.store_string(program_text.text)
		program_editor.file_path = path

	saved_label.show()
	await get_tree().create_timer(2).timeout
	saved_label.hide()

func _on_choose_path_pressed() -> void:
	file_dialog.visible = true
	file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_DIR


func new_path_line():
	path_line.text = main_directory_path + '/' + project_directory_name + '/' + file_name + '.' + file_type
	path_line.caret_column = path_line.text.length()

func _on_file_dialog_dir_selected(dir: String) -> void:
	main_directory_path = dir
	project_directory_name = program_editor.file_name.remove_chars(program_editor.file_name.get_extension())
	file_name = project_directory_name
	program_editor.file_path = main_directory_path + '/' + project_directory_name + '/' + file_name + '.' + file_type

	new_path_line()

func _on_about_to_popup() -> void:
	if main_directory_path == '':
		main_directory_path = ProjectSettings.globalize_path("res://").left(-1)
		project_directory_name = program_editor.program_file_path.get_file().split('.')[0]
		file_name = project_directory_name
		program_editor.file_path = main_directory_path + '/' + project_directory_name + '/' + file_name + '.' + file_type
	new_path_line()

func _on_close_requested() -> void:
	hide()

func _on_compile_push_pressed() -> void:
	_on_save_pressed()
