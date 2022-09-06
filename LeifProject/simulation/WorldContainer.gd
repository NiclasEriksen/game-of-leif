extends Node2D

const BASE_SIZE = Vector2(1920, 1080)
export(Vector2) var WORLD_SIZE = Vector2(1670, 1080)
export(Vector2) var WORLD_OFFSET = Vector2(250, 0)

onready var PARTICLE_SCENE = preload("res://simulation/LeifParticle.tscn")
onready var WORLD_SCENE = preload("res://simulation/LeifWorld.tscn")
var world: Node2D

var parallelThreads := []

const BASE_GLOW_INTENSITY = 0.5
var glow_intensity: float = BASE_GLOW_INTENSITY

var RED := Globals.RED
var GREEN := Globals.GREEN
var WHITE := Globals.WHITE
var BLUE := Globals.BLUE

var boundaries_enabled = true

var RED_PARTICLE_COUNT := 900
var GREEN_PARTICLE_COUNT := 900
var WHITE_PARTICLE_COUNT := 900
var BLUE_PARTICLE_COUNT := 900

var running := false

# Called when the node enters the scene tree for the first time.
func _ready():
	OS.set_window_maximized(true)
	_reset_world()
	running = false
	var _c = RuleLoader.connect("current_rules_changed", self, "_on_current_rules_changed")

	randomize()
	spawn_all()
	RuleLoader._reset_settings()
	_on_current_rules_changed(RuleLoader.current_rule_name)
	
	$CanvasLayer2/GUI.update_particle_count(Globals.RED, RED_PARTICLE_COUNT)
	$CanvasLayer2/GUI.update_particle_count(Globals.GREEN, GREEN_PARTICLE_COUNT)
	$CanvasLayer2/GUI.update_particle_count(Globals.WHITE, WHITE_PARTICLE_COUNT)
	$CanvasLayer2/GUI.update_particle_count(Globals.BLUE, BLUE_PARTICLE_COUNT)
	$CanvasLayer2/GUI.update_world_size(WORLD_SIZE)

func clear_all() -> void:
	for n in get_tree().get_nodes_in_group("red"):
		n.queue_free()
	for n in get_tree().get_nodes_in_group("green"):
		n.queue_free()
	for n in get_tree().get_nodes_in_group("white"):
		n.queue_free()
	for n in get_tree().get_nodes_in_group("blue"):
		n.queue_free()


func spawn_all() -> void:
	running = false
	for _i in range(RED_PARTICLE_COUNT):
		var p := Vector2(world.WORLD_SIZE.x * randf(), world.WORLD_SIZE.y * randf())
		var ps: Sprite = PARTICLE_SCENE.instance()
		ps.position = p
		ps.modulate = Globals.RED_COLOR
		ps.add_to_group("red")
		world.add_child(ps)
	for _i in range(GREEN_PARTICLE_COUNT):
		var p := Vector2(world.WORLD_SIZE.x * randf(), world.WORLD_SIZE.y * randf())
		var ps: Sprite = PARTICLE_SCENE.instance()
		ps.position = p
		ps.modulate = Globals.GREEN_COLOR
		ps.add_to_group("green")
		world.add_child(ps)
	for _i in range(WHITE_PARTICLE_COUNT):
		var p := Vector2(world.WORLD_SIZE.x * randf(), world.WORLD_SIZE.y * randf())
		var ps: Sprite = PARTICLE_SCENE.instance()
		ps.position = p
		ps.modulate = Globals.WHITE_COLOR
		ps.add_to_group("white")
		world.add_child(ps)
	for _i in range(BLUE_PARTICLE_COUNT):
		var p := Vector2(world.WORLD_SIZE.x * randf(), world.WORLD_SIZE.y * randf())
		var ps: Sprite = PARTICLE_SCENE.instance()
		ps.position = p
		ps.modulate = Globals.BLUE_COLOR
		ps.add_to_group("blue")
		world.add_child(ps)

	world._gather_particles()
	running = true


func restart_simulation() -> void:
	running = false
	print("Restarting simulation")
	_reset_world()
#	clear_all()
	spawn_all()


func _reset_world() -> void:
	print("Resetting world")
	if world != null:
		world.free()
	world = WORLD_SCENE.instance()
	$Control/ViewportContainer/WorldViewport.add_child(world)
	if boundaries_enabled:
		world.BOUNDS_TYPE = Globals.BOUNDS_STRICT
	else:
		world.BOUNDS_TYPE = Globals.BOUNDS_DISABLED
		
	world.WORLD_SIZE = WORLD_SIZE
	world.set_position(WORLD_OFFSET)


func _run_rule(ruledef: Array) -> void:
	world.rule(int(ruledef[0]), int(ruledef[1]), ruledef[2], ruledef[3])


func _thread_process() -> void:
	var cr: Array = RuleLoader.current_rules
	for i in range(len(cr)):
		if RuleLoader.inactive_rules[i]:
			continue
		_run_rule(cr[i])

func _process(delta) -> void:
	if running:
		_thread_process()

	$Control/ViewportContainer/WorldViewport.world.environment.glow_intensity = lerp(
		$Control/ViewportContainer/WorldViewport.world.environment.glow_intensity,
		glow_intensity,
		delta * 4.0
	)

func _on_current_rules_changed(_new_rule_name: String) -> void:
	$CanvasLayer2/GUI.update_rules_container()


func _exit_tree():
	running = false
	RuleLoader._reset_settings()


func _on_AudioController_mid_changed(val):
	glow_intensity = BASE_GLOW_INTENSITY + val * 2.0


######### NEW GUI ############


func _on_GUI_audio_file_selected(path):
	$AudioPlayer.load_from_file(path)
	$AudioController.playing = true


func _on_GUI_music_stop():
	$AudioController.playing = false
	$AudioPlayer.stop()


func _on_GUI_volume_changed(val):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear2db(val))


func _on_GUI_quit():
	print("Quitting")
	running = false
	RuleLoader.save_data()
	get_tree().quit()


func _on_GUI_particle_count_applied(red: int, green: int, white: int, blue: int):
	RED_PARTICLE_COUNT = red
	GREEN_PARTICLE_COUNT = green
	WHITE_PARTICLE_COUNT = white
	BLUE_PARTICLE_COUNT = blue
	restart_simulation()


func _on_GUI_boundaries_enabled_toggle(value: bool):
	boundaries_enabled = value
	if value:
		world.BOUNDS_TYPE = Globals.BOUNDS_STRICT
	else:
		world.BOUNDS_TYPE = Globals.BOUNDS_DISABLED


func _on_GUI_world_size_changed(new_size: Vector2):
	WORLD_SIZE = new_size
	WORLD_OFFSET = (BASE_SIZE - WORLD_SIZE) / 2
	world.WORLD_SIZE = WORLD_SIZE
	world.transform.origin = WORLD_OFFSET


func _on_GUI_randomize_rules():
	RuleLoader.randomize_rules()


func _on_GUI_restart_world():
	restart_simulation()


func _on_GUI_preset_selected(name):
	print(name)
	RuleLoader.change_current_rules(name)


func _on_GUI_viscosity_changed(value):
	world.set_viscosity(value)
