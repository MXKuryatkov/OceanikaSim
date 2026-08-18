extends OceanikaDrone


#var waiting = false
#
#func _on_body_entered(body: Node) -> void:
	#if body.is_in_group('fine') and get_parent().race_finished:
		#waiting = true
		#$Timer.start()
#
#
#func _on_body_exited(body: Node) -> void:
	#if body.is_in_group('fine'):
		#waiting = false
#
#
#func _on_timer_timeout() -> void:
	#if waiting:
		#get_parent().fine += 5
		#waiting = false
