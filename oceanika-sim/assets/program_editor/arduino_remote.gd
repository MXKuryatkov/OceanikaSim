extends Node
class_name ArduinoRemote

var device_list: OptionButton
var compile_push_button: Button

var sketch_path: String
var parent: ProgramEditor
var compile_thread: Thread
var upload_progress_bar: ProgressBar

var scan_timer: Timer
var cli_path: String = "arduino-cli"
var is_compiling: bool = false
var is_windows: bool = false

var scan_thread: Thread
var is_scanning: bool = false

# PROGRESS TRACKING
var current_phase: int = 0
var target_percentage: float = 0.0
var current_percentage: float = 0.0
var last_file_position: int = 0

var target_fqbn: String = "esp32:esp32:esp32:PartitionScheme=huge_app,UploadSpeed=921600" 

func _process(_delta: float) -> void:
	get_sketch_path()
	
	# --- REAL-TIME FILE PARSER ---
	if is_compiling:
		var exe_dir = OS.get_executable_path().get_base_dir() + "/"
		var native_log_path = exe_dir + "upload_log.txt"
		
		if FileAccess.file_exists(native_log_path):
			var file = FileAccess.open(native_log_path, FileAccess.READ)
			if file:
				file.seek(last_file_position)
				var new_text = file.get_as_text()
				last_file_position = file.get_position()
				file.close()
				
				if not new_text.is_empty():
					if current_phase == 1:
						var lines = new_text.split("\n")
						for line in lines:
							if line.length() > 5:
								target_percentage += 0.5
								if "Compiling library" in line: target_percentage = max(target_percentage, 10.0)
								if "Compiling sketch" in line: target_percentage = max(target_percentage, 25.0)
								if "Linking" in line: target_percentage = max(target_percentage, 45.0)
						target_percentage = min(target_percentage, 49.0)
					elif current_phase == 2:
						var regex = RegEx.new()
						regex.compile("(\\d+)\\s*%") 
						var matches = regex.search_all(new_text)
						if matches.size() > 0:
							var last_match = matches[matches.size() - 1]
							var raw_val = last_match.get_string(1).to_int()
							var scaled_val = 50.0 + (float(raw_val) / 2.0)
							if scaled_val > target_percentage:
								target_percentage = scaled_val

	if is_compiling and current_percentage < target_percentage:
		current_percentage = lerp(current_percentage, target_percentage, _delta * 5.0)
		if abs(current_percentage - target_percentage) < 0.1:
			current_percentage = target_percentage
		upload_progress_bar.value = current_percentage

func get_sketch_path():
	parent = get_parent()
	sketch_path = parent.file_path

func _ready():
	parent = get_parent()
	upload_progress_bar = parent.upload_progress_bar
	
	is_windows = (OS.get_name() == "Windows")
	var exe_dir = OS.get_executable_path().get_base_dir() + "/"
	
	if is_windows:
		if OS.has_feature("editor"):
			cli_path = ProjectSettings.globalize_path("res://arduino-cli.exe")
		else:
			cli_path = exe_dir + "arduino-cli.exe"
		OS.set_environment("PATH", exe_dir + ";" + OS.get_environment("PATH"))
		
	# Clean up old logs
	var log_path = exe_dir + "upload_log.txt"
	if FileAccess.file_exists(log_path):
		DirAccess.remove_absolute(log_path)
		
	scan_timer = Timer.new()
	scan_timer.wait_time = 5.0
	scan_timer.timeout.connect(_start_scan_async)
	add_child(scan_timer)
	scan_timer.start()
	
	compile_push_button.pressed.connect(_on_push_pressed)
	_start_scan_async()
	upload_progress_bar.value = 0


func _start_scan_async():
	if is_compiling: return
	if is_scanning: return
	if scan_thread and scan_thread.is_started(): return
	
	is_scanning = true
	var selected_text = device_list.get_item_text(device_list.selected) if device_list.selected != -1 else ""
	scan_thread = Thread.new()
	scan_thread.start(_scan_network_devices_thread.bind(selected_text))

func _scan_network_devices_thread(selected_text: String):
	var output = []
	var args = ["board", "list", "--format", "json", "--no-color"]
	var exit_code = OS.execute(cli_path, args, output)
	
	var result = {
		"success": false,
		"devices": [],
		"selected_text": selected_text
	}
	
	if exit_code == 0 and not output.is_empty():
		var raw_text: String = "".join(output)
		var first_brace = raw_text.find("{")
		var last_brace = raw_text.rfind("}")
		if first_brace != -1 and last_brace != -1:
			var clean_json_text = raw_text.substr(first_brace, (last_brace - first_brace) + 1)
			var json_parser = JSON.new()
			if json_parser.parse(clean_json_text) == OK:
				var data = json_parser.get_data()
				if data.has("detected_ports"):
					for item in data["detected_ports"]:
						if item.has("port"):
							var port_data = item["port"]
							if port_data.has("protocol") and port_data["protocol"] == "network":
								var ip_address = port_data["address"]
								var display_name = port_data["label"] if port_data.has("label") else "Device (" + ip_address + ")"
								result.devices.append({"ip": ip_address, "name": display_name})
				result.success = true
	
	call_deferred("_on_scan_finished", result)


func _on_scan_finished(result: Dictionary):
	is_scanning = false
	if scan_thread and scan_thread.is_started():
		scan_thread.wait_to_finish()
	
	if not result.success:
		return
		
	var current_selected_text = result.selected_text
	device_list.clear()
	
	for dev in result.devices:
		var display_name = dev.name
		var ip_address = dev.ip
		device_list.add_item(display_name)
		device_list.set_item_metadata(device_list.get_item_count() - 1, ip_address)
		if display_name == current_selected_text:
			device_list.selected = device_list.get_item_count() - 1

func _on_push_pressed():
	parent.compile_console.show()
	upload_progress_bar.show()
	if is_compiling: return
	if device_list.selected == -1: return
		
	var target_ip = device_list.get_item_metadata(device_list.selected)
	
	compile_push_button.disabled = true
	parent.compile_console.add_text("Starting Compilation...\n")
	
	upload_progress_bar.value = 0
	target_percentage = 0.0
	current_percentage = 0.0
	current_phase = 1
	last_file_position = 0
	is_compiling = true
	
	var exe_dir = OS.get_executable_path().get_base_dir() + "/"
	var native_log_path = exe_dir + "upload_log.txt"
	if is_windows: native_log_path = native_log_path.replace("/", "\\")
	
	if FileAccess.file_exists(native_log_path):
		DirAccess.remove_absolute(native_log_path)
	
	var task_data = {
		"ip": target_ip,
		"sketch": ProjectSettings.globalize_path(sketch_path),
		"fqbn": target_fqbn,
		"cli": cli_path,
		"is_win": is_windows,
		"log_path": native_log_path
	}
	
	compile_thread = Thread.new()
	compile_thread.start(_background_compile_and_push.bind(task_data))

func _background_compile_and_push(task_data: Dictionary):
	var real_log_file = task_data["log_path"]
	var compile_cmd = '"' + task_data["cli"] + '" compile -v --fqbn ' + task_data["fqbn"] + ' "' + task_data["sketch"] + '"'
	
	var shell_bin = "cmd.exe" if task_data["is_win"] else "sh"
	var shell_args = ["/C", compile_cmd + " > \"" + real_log_file + "\" 2>&1"] if task_data["is_win"] else ["-c", compile_cmd + " > \"" + real_log_file + "\" 2>&1"]
	
	var compile_code = OS.execute(shell_bin, shell_args, [], true)
	
	var compile_log = ""
	if FileAccess.file_exists(real_log_file):
		compile_log = FileAccess.get_file_as_string(real_log_file)
		
	if compile_code != 0 or compile_log.contains("Error") or compile_log.contains("error:"):
		call_deferred("_on_pipeline_finished", false, "Compilation failed!\n", [compile_log])
		return
		
	current_phase = 2 
	call_deferred("_update_phase_status", 50.0, "Compilation Done! Uploading...\n")
	
	var upload_cmd = '"' + task_data["cli"] + '" upload -v -p ' + task_data["ip"] + ' --protocol network -l network --fqbn ' + task_data["fqbn"] + ' --upload-field password= "' + task_data["sketch"] + '"'
	var upload_shell_args = ["/C", upload_cmd + " > \"" + real_log_file + "\" 2>&1"] if task_data["is_win"] else ["-c", upload_cmd + " > \"" + real_log_file + "\" 2>&1"]
	
	call_deferred("_reset_file_reader")
	
	var upload_code = OS.execute(shell_bin, upload_shell_args, [], true)
	
	var upload_log = ""
	if FileAccess.file_exists(real_log_file):
		upload_log = FileAccess.get_file_as_string(real_log_file)
		DirAccess.remove_absolute(real_log_file)
		
	if upload_code != 0 or upload_log.contains("Error") or upload_log.contains("Failed") or upload_log.contains("error"):
		call_deferred("_on_pipeline_finished", false, "Upload failed!\n", [upload_log])
	else:
		call_deferred("_on_pipeline_finished", true, "Successfully uploaded!\n", [upload_log])

func _update_phase_status(percent: float, msg: String):
	target_percentage = percent
	current_percentage = percent
	parent.compile_console.add_text(msg)

func _reset_file_reader():
	last_file_position = 0

func _on_pipeline_finished(success: bool, status_message: String, terminal_logs: Array):
	if compile_thread and compile_thread.is_started():
		compile_thread.wait_to_finish()
		
	is_compiling = false
	compile_push_button.disabled = false
	parent.compile_console.add_text(status_message)
	
	if not success:
		for log_line in terminal_logs:
			parent.compile_console.add_text(str(log_line) + "\n")
	
	if success:
		target_percentage = 100.0
		upload_progress_bar.value = 100
