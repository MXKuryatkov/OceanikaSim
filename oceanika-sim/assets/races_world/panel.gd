extends Panel

func _ready() -> void:
	%race_info.hide()
	hide()

var pause = false
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed('pause'):
		pause = !pause
		pause_check()
		

			

func calc_fines(m:int, s:int, mm:int, fine:int):
	if s + fine >= 60:
		@warning_ignore("integer_division")
		var mins_to_add = ceil((s+fine)/60)
		m += mins_to_add
		s = s+fine - mins_to_add*60
	else:
		s += fine
	return [str(m), str(s), str(mm)]


func _on_restart_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()



func _on_rechoose_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file('res://assets/menu/races_menu/races_menu.tscn')


func _on_tomenu_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file('res://assets/menu/menu.tscn')


func _on_race_info_visibility_changed() -> void:
	size.x = $HBoxContainer.size.x + 15
	set_anchors_and_offsets_preset(Control.PRESET_CENTER, Control.PRESET_MODE_KEEP_SIZE)

func pause_check():
	if pause:
		%pause.texture_normal = preload("res://assets/UI/play.png")
		show()
		get_tree().paused = true
	else:
		%pause.texture_normal = preload("res://assets/UI/pause.png")
		hide()
		get_tree().paused = false

func _on_pause_pressed() -> void:
	pause = !pause
	pause_check()
		
