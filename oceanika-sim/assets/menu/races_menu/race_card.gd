extends HBoxContainer
class_name RaceCard

signal pressed(_name: String, des: String, ico: CompressedTexture2D, _id: int)

@export var id: int = -1
@export var race_name: String = 'Название трассы'
@export var description: String = 'Описание трассы'
@export var icon: CompressedTexture2D = preload("res://icon.svg")
@export var medal_colors: Dictionary = {
	0: Color(1.0, 1.0, 1.0, 0.0),
	1: Color(0.918, 0.769, 0.304, 1.0),
	2: Color(0.753, 0.753, 0.753),
	3: Color(0.875, 0.631, 0.486),
}

var can_press = false

@onready var medals_container: VBoxContainer = $HBoxContainer/medals_container


func _ready() -> void:
	%icon.texture = icon
	%race_name.text = race_name
	%description.text = description
	if not RaceHandler.race_places.has(race_name):
		RaceHandler.race_places.get_or_add(race_name, 0)
		RaceHandler.race_places[race_name] = 0
	set_medal(RaceHandler.race_places[race_name])

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed() and can_press:
			pressed.emit(race_name, description, icon, id)
			#здесь надо переключить вид в самой сцене races menu на вид конкретной трассы, где уже будет кнопка старта.

func _on_mouse_entered() -> void:
	can_press = true



func _on_mouse_exited() -> void:
	can_press = false

func set_medal(place: int):
	if place == 0: return
	var medal: TextureRect = medals_container.get_child(place-1)
	medal.modulate = medal_colors[place]
	medal.self_modulate = Color(1.0, 1.0, 1.0, 1.0)
	medal.use_parent_material = false
	
	
