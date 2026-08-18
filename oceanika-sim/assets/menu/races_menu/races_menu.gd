extends Control

@onready var race_choose_panel: Panel = $race_choose_panel
@onready var race_confirm_panel: Panel = $race_confirm_panel
@onready var race_name: Label = $race_confirm_panel/race_name
@onready var race_description: Label = $race_confirm_panel/Panel/race_description
@onready var race_icon: TextureRect = $race_confirm_panel/Panel/race_icon
@onready var race_cards_container: VBoxContainer = $race_choose_panel/Panel/ScrollContainer/VBoxContainer
@onready var file_dialog: FileDialog = $FileDialog

var races_world: PackedScene = preload('res://assets/races_world/races_world.tscn')
var race_card: PackedScene = preload('res://assets/menu/races_menu/race_card.tscn')

@export var races: Array[Race]
var selected_race: Race

func _ready() -> void:
	place_races()
	race_choose_panel.show()
	race_confirm_panel.hide()

func clear():
	for child in race_cards_container.get_children():
		child.queue_free()

func place_races():
	clear()
	for race: Race in races:
		var new_card: RaceCard = race_card.instantiate()
		new_card.race_name = race.name
		new_card.description = race.description
		new_card.icon = race.icon
		new_card.pressed.connect(_on_race_card_pressed)
		new_card.id = races.find(race)
		race_cards_container.add_child(new_card)


func _on_race_card_pressed(_name: String, des: String, ico: CompressedTexture2D, _id: int) -> void:
	race_choose_panel.hide()
	race_confirm_panel.show()
	
	race_name.text = _name
	race_description.text = des
	race_icon.texture = ico
	selected_race = races[_id]
	


func _on_start_pressed() -> void:
	RaceHandler.race = selected_race
	get_tree().change_scene_to_packed(races_world)


func _on_back_pressed() -> void:
	race_choose_panel.show()
	race_confirm_panel.hide()


func _on_load_pressed() -> void:
	file_dialog.visible = true


func _on_file_dialog_file_selected(path: String) -> void:
	var new_race: Race = Race.new()
	new_race.name = path.get_file().replace('.ocs', '')
	new_race.race_file_path = path
	new_race.icon = preload("uid://cesdy7r7c6xng")
	new_race.description = 'Неофициальная пользовательская карта.\nСоздана пользователем в режиме редактирования.'
	races.append(new_race)
	place_races()
	
