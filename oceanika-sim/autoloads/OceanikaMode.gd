extends Node


var mode: String = ''
var controller_prefix: String = 'rm_'
var controller_name: String = ''
var current_vendor_id: int = 0

var vendor_id_match: Dictionary = {
	1356: 'ps_',
	4617: 'rm_',
	1155: 'bfpv_',
}
var hints: Dictionary = {
	1356: preload("uid://dpchvmr2j6an"),
	4617: preload("uid://btnfu3kfqiqj5"),
	1155: preload("uid://btnfu3kfqiqj5"),
}

func _process(_delta: float) -> void:
	if len(Input.get_connected_joypads()) > 0:
		controller_prefix = vendor_id_match[int(Input.get_joy_info(0)["vendor_id"])]
		controller_name = Input.get_joy_info(0)['raw_name']
		current_vendor_id = int(Input.get_joy_info(0)["vendor_id"])
	else:
		controller_name = ''
		current_vendor_id = 0
