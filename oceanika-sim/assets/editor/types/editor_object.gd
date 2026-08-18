class_name EditorObject
extends Resource

## String that you will see in the objects list
@export var display_name: String = ""

## Scene that is visible in editor mode
@export var editor_scene: PackedScene

## Scene added in race mode[br]
## Config is passed through the configure function
@export var race_scene: PackedScene

## Config new objects get by default
@export var default_config: Dictionary[String, Variant]

## If a property has multiple configurators, set the required one here[br]
## {"config_name": "configurator"}
@export var type_map: Dictionary[String, String]
