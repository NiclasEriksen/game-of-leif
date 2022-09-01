extends VBoxContainer

var rule_index := 0

signal attraction_updated(rule_index, value)
signal range_updated(rule_index, value)

var RED: int = 0
var GREEN: int = 1
var WHITE: int = 2
var BLUE: int = 3

func set_parameters(rule: Array):
	$Sliders/AttractionSlider.value = rule[2]
	$Sliders/RangeSlider.value = rule[3]
	$Visual/Attraction.text = "%.2f" % rule[2]
	$Visual/Range.text = "%.2f" % rule[3]
	var pair_str := ""
	match int(rule[0]):
		RED:
			pair_str += "R-"
			$Visual/FromColor.color = Globals.RED_COLOR
		GREEN:
			pair_str += "G-"
			$Visual/FromColor.color = Globals.GREEN_COLOR
		WHITE:
			pair_str += "W-"
			$Visual/FromColor.color = Globals.WHITE_COLOR
		BLUE:
			pair_str += "B-"
			$Visual/FromColor.color = Globals.BLUE_COLOR
		_:
			print("Didn't match color??  ", rule[0])
			pair_str += "?-"
	match int(rule[1]):
		RED:
			pair_str += "R"
			$Visual/ToColor.color = Globals.RED_COLOR
		GREEN:
			pair_str += "G"
			$Visual/ToColor.color = Globals.GREEN_COLOR
		WHITE:
			pair_str += "W"
			$Visual/ToColor.color = Globals.WHITE_COLOR
		BLUE:
			pair_str += "B"
			$Visual/ToColor.color = Globals.BLUE_COLOR
		_:
			print("Didn't match color??  ", rule[1])
			pair_str += "?"

	$Sliders/PairLabel.text = pair_str


func _on_AttractionSlider_value_changed(value: float):
	emit_signal("attraction_updated", rule_index, value)
	$Visual/Attraction.text = "%.2f" % value


func _on_RangeSlider_value_changed(value: float):
	emit_signal("range_updated", rule_index, value)
	$Visual/Range.text = "%.2f" % value
