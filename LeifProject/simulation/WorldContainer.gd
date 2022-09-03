extends Node2D

export(Vector2) var WORLD_SIZE = Vector2(1670, 1080)
export(Vector2) var WORLD_OFFSET = Vector2(250, 0)

onready var PARTICLE_SCENE = preload("res://simulation/LeifParticle.tscn")
onready var WORLD_SCENE = preload("res://simulation/LeifWorld.tscn")
var world: Node2D

var parallelThreads := []

var RED := Globals.RED
var GREEN := Globals.GREEN
var WHITE := Globals.WHITE
var BLUE := Globals.BLUE


var RED_PARTICLE_COUNT := 750
var GREEN_PARTICLE_COUNT := 750
var WHITE_PARTICLE_COUNT := 750
var BLUE_PARTICLE_COUNT := 750

var running := false

# Called when the node enters the scene tree for the first time.
func _ready():
	world = WORLD_SCENE.instance()
	add_child(world)
	world.WORLD_SIZE = WORLD_SIZE
	world.set_position(WORLD_OFFSET)
	running = false
	RuleLoader.connect("current_rules_changed", self, "_on_current_rules_changed")
	RuleLoader.connect("current_rulename_changed", self, "_on_current_rulename_changed")
	_populate_load_menu()
	randomize()
	spawn_all()
	RuleLoader._reset_settings()
	_on_current_rules_changed(RuleLoader.current_rule_name)

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
	world.free()
	world = WORLD_SCENE.instance()
	add_child(world)
	world.WORLD_SIZE = WORLD_SIZE
	world.set_position(WORLD_OFFSET)


func _run_rule(ruledef: Array) -> void:
	world.rule(int(ruledef[0]), int(ruledef[1]), ruledef[2], ruledef[3])


func _thread_process() -> void:
	var cr: Array = RuleLoader.current_rules

	for r in cr:
		_run_rule(r)

func _process(_delta) -> void:
	$CanvasLayer/Control/FPSLabel.text = "FPS: " + str(Engine.get_frames_per_second())
	if running:
		_thread_process()

func _populate_load_menu() -> void:
	var r = RuleLoader.rules
	$CanvasLayer/LoadMenu.clear()

	for name in r:
		$CanvasLayer/LoadMenu.add_item(name)


func _on_RuleContainer_attraction_updated(index: int, value: float):
	RuleLoader.modify_rule(int(index), 2, value)


func _on_RuleContainer_range_updated(index: int, value: float):
	RuleLoader.modify_rule(int(index), 3, value)

func _on_current_rules_changed(new_rule_name: String) -> void:
	$CanvasLayer/Control/RuleInfoContainer2/RuleNameLabel.text = new_rule_name
	$CanvasLayer/Control/RuleContainer.build(RuleLoader.current_rules)
	_populate_load_menu()

func _on_current_rulename_changed(new_rule_name: String) -> void:
	$CanvasLayer/Control/RuleInfoContainer2/RuleNameLabel.text = new_rule_name


func _on_RandomButton_pressed():
	RuleLoader.randomize_rules()


func _on_SaveButton_pressed():
	$CanvasLayer/SavePanel/RuleNameEdit.text = RuleLoader.current_rule_name
	$CanvasLayer/SavePanel.popup(Rect2(40, 40, 350, 75))
	$CanvasLayer/SavePanel/RuleNameEdit.grab_focus()
	$CanvasLayer/SavePanel/RuleNameEdit.select_all()


func _on_SavePanel_confirmed():
	var new_name: String = $CanvasLayer/SavePanel/RuleNameEdit.text
	RuleLoader.add_new_rule_and_save(new_name)
	_populate_load_menu()


func _on_RestartButton_pressed():
	restart_simulation()


func _on_LoadButton_pressed():
	$CanvasLayer/LoadMenu.popup(Rect2(40, 40, 250, 200))
	$CanvasLayer/LoadMenu.grab_focus()


func _on_LoadMenu_id_pressed(id):
	var n = $CanvasLayer/LoadMenu.get_item_text(id)
	RuleLoader.change_current_rules(n)


func _on_ExportButton_pressed():
	var s := RuleLoader.generate_rule_string()
	$CanvasLayer/ExportPanel/ExportStringEdit.text = s
	$CanvasLayer/ExportPanel.popup(Rect2(40, 40, 350, 75))
	$CanvasLayer/ExportPanel/ExportStringEdit.grab_focus()
	$CanvasLayer/ExportPanel/ExportStringEdit.select_all()


func _on_ImportButton_pressed():
	$CanvasLayer/ImportPanel.popup(Rect2(40, 40, 350, 75))
	$CanvasLayer/ImportPanel/ImportStringEdit.grab_focus()
	$CanvasLayer/ImportPanel/ImportStringEdit.select_all()


func _on_ImportPanel_confirmed():
	var s = $CanvasLayer/ImportPanel/ImportStringEdit.text.strip_edges()
	RuleLoader.import_rule_string(s)


func _on_FullscreenButton_pressed():
	OS.window_fullscreen = !OS.window_fullscreen

func _exit_tree():
	running = false
	RuleLoader._reset_settings()

func _on_QuitButton2_pressed():
	print("Quitting")
	running = false
	RuleLoader.save_data()
	get_tree().quit()
