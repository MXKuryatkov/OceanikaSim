extends HBoxContainer



func _process(_delta: float) -> void:
	if len(Input.get_connected_joypads()) > 0:
		$connected.show()
		$disconnected.hide()
	else:
		$connected.hide()
		$disconnected.show()
		
