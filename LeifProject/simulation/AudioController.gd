extends Node

const VU_COUNT := 4
const FREQ_MAX := 11050.0
const MIN_DB := 60

var AUDIO_STRENGTH := [1.0, 1.0, 1.0, 1.0]

var spectrum: AudioEffectInstance


func _ready():
	spectrum = AudioServer.get_bus_effect_instance(0, 0)


func _process(_delta):
	var prev_hz: float = 0.0
	for i in range(1, VU_COUNT+1):
		var hz := i * FREQ_MAX / VU_COUNT
		var magnitude: float = spectrum.get_magnitude_for_frequency_range(prev_hz, hz).length()
		var energy: float = clamp((MIN_DB + linear2db(magnitude)) / MIN_DB, 0.0, 1.0)
		prev_hz = hz
		AUDIO_STRENGTH[i-1] = energy
	
#	print(AUDIO_STRENGTH)


