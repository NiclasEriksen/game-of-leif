extends Node

var RED := Globals.RED
var GREEN := Globals.GREEN
var WHITE := Globals.WHITE
var BLUE := Globals.BLUE

var current_rule_name := "default"
var rules := {
	"default": [
		[GREEN, GREEN, -56.5, 23.4],
		[GREEN, RED, 14.5, 181.5],
		[GREEN, WHITE, -41.5, 62],
		[GREEN, BLUE, 13.5, 10],
		[RED, RED, 41.5, 78.6],
		[RED, GREEN, -42, 161.9],
		[RED, WHITE, 3.5, 131.3],
		[RED, BLUE, -57.5, 38],
		[WHITE, WHITE, 16, 232.0],
		[WHITE, RED, 13, 46.0],
		[WHITE, GREEN, 0, 108.0],
		[WHITE, BLUE, -35, 102.0],
		[BLUE, BLUE, -20.5, 145.5],
		[BLUE, WHITE, 27.5, 106],
		[BLUE, RED, -35.5, 124.0],
		[BLUE, GREEN, -5.5, 103]
	]
}

var inactive_rules = [
	false, false, false, false,
	false, false, false, false,
	false, false, false, false,
	false, false, false, false,
]

onready var current_rules: Array = rules[current_rule_name].duplicate(true)
var music_rules: Array


signal current_rules_changed(rule_name)


func _ready() -> void:
	_reset_settings()

func _reset_settings() -> void:
	load_data()
	if not current_rule_name in rules:
		current_rule_name = "default"
	current_rules = rules[current_rule_name].duplicate(true)

func zeroize_rules() -> void:
	var _rules = current_rules
	for i in range(len(_rules)):
		var r: Array = _rules[i]
		r[2] = 0.0
		r[3] = 0.0

	current_rules = _rules
	current_rule_name = "zero"
	emit_signal("current_rules_changed", current_rule_name)

func randomize_rules() -> void:
	var _rules = current_rules
	for i in range(len(_rules)):
		var r: Array = _rules[i]
		if randf() < 0.1:
			r[2] = 0.0
		else:
			var rf1 := randf()
			r[2] = (rf1 * rf1 * rf1) * 50
			if randf() > 0.5:
				r[2] *= -1
		r[3] = randf() * randf() * 400

		if abs(r[2]) < 0.1 || r[3] < 5.0:
			r[2] = 0.0
			r[3] = 0.0
			inactive_rules[i] = true
		else:
			inactive_rules[i] = false

	current_rules = _rules
	current_rule_name = "<custom *>"
	emit_signal("current_rules_changed", current_rule_name)


func modify_rule(rule_index: int, value_index: int, value: float) -> void:
	var _rules = current_rules
	if rule_index >= len(_rules):
		print("Invalid rule index, not modified!")
		return
	if value_index >= len(_rules[rule_index]):
		print("Invalid rule value index, not modified!")
		return
	if value == _rules[rule_index][value_index]:
#		print("Rule value identical, aborting.")
		return
	_rules[rule_index][value_index] = value
	current_rules = _rules
	current_rule_name = "<custom *>"


func add_new_rule_and_save(rule_name: String) -> void:
	rules[rule_name] = current_rules.duplicate(true)
	current_rule_name = rule_name
	save_data()
	emit_signal("current_rules_changed", current_rule_name)


func change_current_rules(name: String) -> void:
	if name in rules:
		current_rule_name = name
		current_rules = rules[name].duplicate(true)
		emit_signal("current_rules_changed", current_rule_name)
	else:
		print("NAME NOT IN RULES")


func generate_rule_string(rules_arr: Array) -> String:
	var s := ""
	var rules_arr_new = [
		rules_arr[1], rules_arr[0], rules_arr[2], rules_arr[3]
	]
	for rule in rules_arr_new:
		s += "%.2f " % rule[2]
		s += "%.2f " % rule[3]
	s += str(Globals.RED_PARTICLE_COUNT) + " "
	s += str(Globals.GREEN_PARTICLE_COUNT) + " "
	s += str(Globals.WHITE_PARTICLE_COUNT) + " "
	s += str(Globals.BLUE_PARTICLE_COUNT) + " "
	s += str(Globals.VISCOSITY)
	return s

func convert_old_rule_string(s: String) -> String:
	var rules_arr = []
	var rules_str: Array = s.split(";")
	if rules_str[-1].strip_edges() == "":
		rules_str.pop_back()
	for r_str in rules_str:
		if not r_str.countn(",") == 3:
			print("Invalid rule string!")
			return ""
		var r_str_arr: Array = r_str.split(",")
		if r_str_arr[-1].strip_edges() == "":
			r_str_arr.pop_back()
		if not len(r_str_arr) == 4:
			print("Invalid number of parameters for rule in string!")
			return ""
		rules_arr.append([
			int(r_str_arr[0]),
			int(r_str_arr[1]),
			float(r_str_arr[2]),
			float(r_str_arr[3]),
		])
	return generate_rule_string(rules_arr)


func import_rule_string(s: String) -> void:
	if s.countn(";") > 0:
		print("Probably old rule string, converting.")
		s = convert_old_rule_string(s)
	var rules_arr = []
	var rules_str: Array = s.split(" ")
	if rules_str[-1].strip_edges() == "":
		rules_str.pop_back()
	if not len(rules_str) == 37:
		print("Invalid number of rules in rule string!")
		return

	rules_arr.append([
		1, 1, float(rules_str[0]), float(rules_str[4])
	])
	rules_arr.append([
		1, 0, float(rules_str[1]), float(rules_str[5])
	])
	rules_arr.append([
		1, 2, float(rules_str[2]), float(rules_str[6])
	])
	rules_arr.append([
		1, 3, float(rules_str[3]), float(rules_str[7])
	])
	rules_arr.append([
		0, 1, float(rules_str[8]), float(rules_str[12])
	])
	rules_arr.append([
		0, 1, float(rules_str[9]), float(rules_str[13])
	])
	rules_arr.append([
		0, 2, float(rules_str[10]), float(rules_str[14])
	])
	rules_arr.append([
		0, 3, float(rules_str[11]), float(rules_str[15])
	])
	rules_arr.append([
		2, 1, float(rules_str[16]), float(rules_str[20])
	])
	rules_arr.append([
		2, 0, float(rules_str[17]), float(rules_str[21])
	])
	rules_arr.append([
		2, 2, float(rules_str[18]), float(rules_str[22])
	])
	rules_arr.append([
		2, 3, float(rules_str[19]), float(rules_str[23])
	])
	rules_arr.append([
		3, 1, float(rules_str[24]), float(rules_str[28])
	])
	rules_arr.append([
		3, 0, float(rules_str[25]), float(rules_str[29])
	])
	rules_arr.append([
		3, 2, float(rules_str[26]), float(rules_str[30])
	])
	rules_arr.append([
		3, 3, float(rules_str[27]), float(rules_str[31])
	])
	var count_green: int = int(rules_str[32])
	var count_red: int = int(rules_str[33])
	var count_white: int = int(rules_str[34])
	var count_blue: int = int(rules_str[35])
	var viscosity: float = float(rules_str[36])
	
	print("Parsing of rules string successful, applying...")

	current_rules = rules_arr
	current_rule_name = "<imported *>"	
	emit_signal("current_rules_changed", current_rule_name)


func save_data() -> void:
	var file = File.new()
	file.open("user://rules_data.json", File.WRITE)
	file.store_line(to_json(rules))
	file.close()


func load_data() -> void:
	var file = File.new()
	var missing = false
	if not file.file_exists("user://rules_data.json"):
		file.open("res://utility/default_rules_data.json", File.READ)
		missing = true
	else:
		file.open("user://rules_data.json", file.READ)

	var data = parse_json(file.get_as_text())
	rules = data
	if missing:
		save_data()
