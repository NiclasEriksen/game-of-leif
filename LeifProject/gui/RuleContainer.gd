extends VBoxContainer

onready var RULEBOX_SCENE = load("res://gui/RuleBox.tscn")

signal attraction_updated(index, value)
signal range_updated(index, value)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for c in get_children():
		c.queue_free()

func build(rules: Array) -> void:
	for c in get_children():
		c.queue_free()
	for i in range(len(rules)):
		var rule: Array = rules[i]
		var rs: VBoxContainer = RULEBOX_SCENE.instance()
		rs.rule_index = i
		add_child(rs)
		rs.set_parameters(rule)
		var _c = rs.connect("attraction_updated", self, "_on_RuleBox_attraction_updated")
		_c = rs.connect("range_updated", self, "_on_RuleBox_range_updated")


func _on_RuleBox_attraction_updated(index: int, value: float):
	emit_signal("attraction_updated", index, value)


func _on_RuleBox_range_updated(index: int, value: float):
	emit_signal("range_updated", index, value)

