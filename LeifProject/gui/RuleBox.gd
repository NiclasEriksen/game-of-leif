extends HBoxContainer

var rule_index := 0
var color_from := Globals.RED
var color_to := Globals.RED

signal attraction_updated(rule_index, value)
signal range_updated(rule_index, value)

var RED: int = 0
var GREEN: int = 1
var WHITE: int = 2
var BLUE: int = 3

func set_parameters(rule: Array):
	$SliderContainer/Sliders/AttractionSlider.value = rule[2]
	$SliderContainer/Sliders/RangeSlider.value = rule[3]
	$SliderContainer/SliderLabels/Attraction.text = "g: %.2f" % rule[2]
	$SliderContainer/SliderLabels/Range.text = "r: %.2f" % rule[3]
	color_from = rule[0]
	color_to = rule[1]
	match int(rule[0]):
		RED:
			$Visual/FromColor.color = Globals.RED_COLOR
		GREEN:
			$Visual/FromColor.color = Globals.GREEN_COLOR
		WHITE:
			$Visual/FromColor.color = Globals.WHITE_COLOR
		BLUE:
			$Visual/FromColor.color = Globals.BLUE_COLOR
		_:
			print("Didn't match color??  ", rule[0])
	match int(rule[1]):
		RED:
			$Visual/ToColor.color = Globals.RED_COLOR
		GREEN:
			$Visual/ToColor.color = Globals.GREEN_COLOR
		WHITE:
			$Visual/ToColor.color = Globals.WHITE_COLOR
		BLUE:
			$Visual/ToColor.color = Globals.BLUE_COLOR
		_:
			print("Didn't match color??  ", rule[1])


func _on_AttractionSlider_value_changed(value: float):
	emit_signal("attraction_updated", rule_index, value)
	$SliderContainer/SliderLabels/Attraction.text = "g: %.2f" % value


func _on_RangeSlider_value_changed(value: float):
	emit_signal("range_updated", rule_index, value)
	$SliderContainer/SliderLabels/Range.text = "r: %.2f" % value

func _on_color_updated(color_id: int, new_color) -> void:
	if color_id == color_from:
		$Visual/FromColor.color = new_color
	if color_id == color_to:
		$Visual/ToColor.color = new_color

