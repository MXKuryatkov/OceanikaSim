extends Node

signal new_message(text: String, level: Level)
signal update_monitors

enum Level { Error, Warning, Info, Debug }

var monitors: Dictionary[String, String] = {}

func message(text: Variant, level: Level=Level.Debug):
	match level:
		Level.Debug: print(text)
		Level.Info: print("info: " + str(text))
		Level.Warning: push_warning(text)
		Level.Error: push_error(text)
	new_message.emit(str(text), level)

func monitor(key: String, value: Variant):
	monitors.set(key, str(value))
	update_monitors.emit()
