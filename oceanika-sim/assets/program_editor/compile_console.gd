extends TextEdit
class_name CompileConsole


func add_text(_text: String):
	text += _text
	set_caret_line(get_line_count())
