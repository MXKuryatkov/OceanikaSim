extends Resource
class_name BlockRes


@export var has_type: bool = true
@export var block_preset: PackedScene = preload('res://assets/program_editor/blocks/program_block_preset.tscn')
@export var block_name: String = 'name not setted'
@export var set_code_line: String = 'code line not setted'
@export var change_code_line: String = 'code line not setted'
@export_range(0, 100000) var max_value: int = 0
@export var code_lines: Array[String]
@export var param1_dict: Dictionary[String, String]
