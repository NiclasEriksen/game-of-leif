extends Node2D

const BASE_SIZE = Vector2(1920, 1080)
export(Vector2) var WORLD_SIZE = Vector2(1670, 1080)
export(Vector2) var WORLD_OFFSET = Vector2(250, 0)

onready var PARTICLE_SCENE = preload("res://simulation/LeifParticle.tscn")
onready var WORLD_SCENE = preload("res://simulation/LeifWorld.tscn")
var world: Node2D

var glow_intensity: float = ProjectSettings.get_setting("global/glow_amount")

var RED := Globals.RED
var GREEN := Globals.GREEN
var WHITE := Globals.WHITE
var BLUE := Globals.BLUE

var boundaries_type = Globals.BOUNDS_STRICT

var running := false
var mouse_pressed := false


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
	
	$CanvasLayer2/GUI.update_particle_count(Globals.RED, Globals.RED_PARTICLE_COUNT)
	$CanvasLayer2/GUI.update_particle_count(Globals.GREEN, Globals.GREEN_PARTICLE_COUNT)
	$CanvasLayer2/GUI.update_particle_count(Globals.WHITE, Globals.WHITE_PARTICLE_COUNT)
	$CanvasLayer2/GUI.update_particle_count(Globals.BLUE, Globals.BLUE_PARTICLE_COUNT)
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
	for _i in range(Globals.RED_PARTICLE_COUNT):
		var p := Vector2(world.WORLD_SIZE.x * randf(), world.WORLD_SIZE.y * randf())
		var ps: Sprite = PARTICLE_SCENE.instance()
		ps.position = p
		ps.modulate = Globals.RED_COLOR
		ps.add_to_group("red")
		world.add_child(ps)
	for _i in range(Globals.GREEN_PARTICLE_COUNT):
		var p := Vector2(world.WORLD_SIZE.x * randf(), world.WORLD_SIZE.y * randf())
		var ps: Sprite = PARTICLE_SCENE.instance()
		ps.position = p
		ps.modulate = Globals.GREEN_COLOR
		ps.add_to_group("green")
		world.add_child(ps)
	for _i in range(Globals.WHITE_PARTICLE_COUNT):
		var p := Vector2(world.WORLD_SIZE.x * randf(), world.WORLD_SIZE.y * randf())
		var ps: Sprite = PARTICLE_SCENE.instance()
		ps.position = p
		ps.modulate = Globals.WHITE_COLOR
		ps.add_to_group("white")
		world.add_child(ps)
	for _i in range(Globals.BLUE_PARTICLE_COUNT):
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
	world.BOUNDS_TYPE = boundaries_type
		
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


func _on_AudioController_mid_changed(val):
	if running:
		glow_intensity = ProjectSettings.get_setting("global/glow_amount") + val
		Globals.VISCOSITY = 0.75 - val * 0.5
		world.set_viscosity(Globals.VISCOSITY)
		$CanvasLayer2/GUI.update_viscosity(Globals.VISCOSITY)
		
func _on_AudioController_bass_changed(val):
	if running:
		var sp: float = ProjectSettings.get_setting("global/music_color_shift_speed")
		var mr: float = ProjectSettings.get_setting("global/music_reactivity")
		Globals.RED_COLOR.h += val * sp * mr
		Globals.GREEN_COLOR.h += val * sp * mr
		Globals.WHITE_COLOR.h += val * sp * mr
		Globals.BLUE_COLOR.h += val * sp * mr
		update_colors_of_particles(Globals.RED)
		update_colors_of_particles(Globals.GREEN)
		update_colors_of_particles(Globals.WHITE)
		update_colors_of_particles(Globals.BLUE)


func update_colors_of_particles(color_id: int) -> void:
	match(color_id):
		Globals.RED:
			for n in get_tree().get_nodes_in_group("red"):
				n.modulate = Globals.RED_COLOR
		Globals.GREEN:
			for n in get_tree().get_nodes_in_group("green"):
				n.modulate = Globals.GREEN_COLOR
		Globals.WHITE:
			for n in get_tree().get_nodes_in_group("white"):
				n.modulate = Globals.WHITE_COLOR
		Globals.BLUE:
			for n in get_tree().get_nodes_in_group("blue"):
				n.modulate = Globals.BLUE_COLOR
		_:
			pass


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
	$AudioController.playing = false
	for c in get_children():
		c.queue_free()
	yield(get_tree().create_timer(0.5),"timeout")
	get_tree().notification(MainLoop.NOTIFICATION_WM_QUIT_REQUEST)
	OS.call_deferred("kill", OS.get_process_id())


func _on_GUI_particle_count_applied(red: int, green: int, white: int, blue: int):
	Globals.RED_PARTICLE_COUNT = red
	Globals.GREEN_PARTICLE_COUNT = green
	Globals.WHITE_PARTICLE_COUNT = white
	Globals.BLUE_PARTICLE_COUNT = blue
	restart_simulation()


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
	RuleLoader.change_current_rules(name)


func _on_GUI_viscosity_changed(value):
	Globals.VISCOSITY = value
	world.set_viscosity(Globals.VISCOSITY)


func _on_GUI_boundaries_changed(new_val):
	boundaries_type = new_val
	world.BOUNDS_TYPE = new_val


func _on_GUI_color_changed(color_id: int, new_color: Color):
	match(color_id):
		Globals.RED:
			Globals.RED_COLOR = new_color
		Globals.GREEN:
			Globals.GREEN_COLOR = new_color
		Globals.WHITE:
			Globals.WHITE_COLOR = new_color
		Globals.BLUE:
			Globals.BLUE_COLOR = new_color
		_:
			pass

	update_colors_of_particles(color_id)


func _on_ViewportContainer_gui_input(event: InputEvent):
	if event.is_action_pressed("zoom_in"):
		$Control/ViewportContainer/WorldViewport/Camera2D.zoom -= Vector2(0.1, 0.1)
	elif event.is_action_pressed("zoom_out"):
		$Control/ViewportContainer/WorldViewport/Camera2D.zoom += Vector2(0.1, 0.1)
	if event is InputEventMouseMotion and mouse_pressed:
		$Control/ViewportContainer/WorldViewport/Camera2D.offset -= event.relative * $Control/ViewportContainer/WorldViewport/Camera2D.zoom
	if event is InputEventMouseButton and event.button_index == BUTTON_MASK_LEFT:
		mouse_pressed = event.pressed
	elif event is InputEventMouseButton and event.button_index == BUTTON_MASK_RIGHT and event.pressed:
		$Control/ViewportContainer/WorldViewport/Camera2D.zoom = Vector2.ONE
		$Control/ViewportContainer/WorldViewport/Camera2D.offset = Vector2.ZERO
