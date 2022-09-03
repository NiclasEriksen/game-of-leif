extends Node


func _ready():
#	load_from_file("/home/fredspipa/Music/Glacier - Patrick Patrikios.mp3")
#	load_from_file("/home/fredspipa/Music/chase.ogg")
	pass


func load_from_file(path: String) -> void:
	print("Loading " + path)
	var sound_object
	if path.to_lower().ends_with(".ogg"):
		sound_object = AudioStreamOGGVorbis.new()
	elif path.to_lower().ends_with(".mp3"):
		sound_object = AudioStreamMP3.new()
	else:
		print("No loader for '" + path + "'!")
		return
	sound_object.loop = true
	var file = File.new()
	file.open(path, File.READ)
	sound_object.data = file.get_buffer(file.get_len())
	file.close()
	$AudioStreamPlayer.set_stream(sound_object)
	$AudioStreamPlayer.play()

