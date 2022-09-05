extends Node

const MIN_DB := 60
const RULE_G_CHANGE := 5.0
const RULE_R_CHANGE := 20.0
var cooldown := false
var playing := false

var AUDIO_STRENGTH := [0.0, 0.0, 0.0]
var FREQ_RANGES := [
	[0.0, 80.0],
	[200.0, 400.0],
	[1000.0, 6000.0]
]


var last_rules: Array = []


var num_rules := 16

var spectrum: AudioEffectInstance
signal mid_changed(val)

func _ready():
	spectrum = AudioServer.get_bus_effect_instance(0, 0)
	num_rules = len(RuleLoader.current_rules)
	last_rules = RuleLoader.current_rules.duplicate(true)

func modify_random_rules() -> void:
	var cr: Array = RuleLoader.current_rules
	
	var bass: float = AUDIO_STRENGTH[0]
	var mid: float = AUDIO_STRENGTH[1]
	var disk: float = AUDIO_STRENGTH[2]
	if not cooldown:
		if bass > 0.8:
			cooldown = true
			RuleLoader.randomize_rules()
			last_rules = RuleLoader.current_rules.duplicate(true)
			$RandomizeTimer.start()
	
	for i in range(num_rules):
		if bass > 0.0:
			var lv: float = last_rules[i][3]
			RuleLoader.modify_rule(i, 3, clamp(
				lv - (lv / 2.0) + bass * lv,
				0.0,
				400.0
			))
		if disk > 0.75 and randf() > 0.66:
			var cv: float = cr[i][2]
			RuleLoader.modify_rule(i, 2, cv * -1)
			last_rules[i][2] *= -1
		else:
			var lv: float = last_rules[i][2]
			RuleLoader.modify_rule(i, 2, (lv - lv / 2) + lv * disk)
	
	emit_signal("mid_changed", mid)
#			else:	# g
#				var higher: bool = R_DIRECTIONS[i]
#				var v = a * RULE_G_CHANGE
#				if cv + v > 30.0 and higher:
#					higher = false
#					R_DIRECTIONS[i] = true
#				elif cv - v <= -30.0 and not higher:
#					higher = true
#					G_DIRECTIONS[i] = true
#				var ratio := 1.0 - abs(cv) / 100.0
#				if higher:
#					cv += v * ratio * ratio * ratio
#				else:
#					cv -= v * ratio * ratio * ratio
#				RuleLoader.modify_rule(i, 2, cv)


func _process(_delta):
	if !playing:
		return
	for i in range(3):
		var magnitude: float = spectrum.get_magnitude_for_frequency_range(FREQ_RANGES[i][0], FREQ_RANGES[i][1]).length()
		var energy: float = clamp((MIN_DB + linear2db(magnitude)) / MIN_DB, 0.0, 1.0)
		AUDIO_STRENGTH[i] = energy
	
	modify_random_rules()
#	print(AUDIO_STRENGTH)




func _on_RandomizeTimer_timeout():
	cooldown = false
