extends Control

var hidden: bool = false

signal quit
signal restart_world
signal randomize_rules
signal audio_file_selected(path)
signal music_stop
signal volume_changed(val)
signal preset_selected(name)
signal boundaries_changed(new_val)
signal world_size_changed(new_size)
signal viscosity_changed(value)
signal particle_count_applied(red, green, white, blue)
signal color_changed(color_id, new_color)

# UI element paths
onready var fps_label = $VBoxContainer/Split/GeneralContainer/MainSettings/FPSLabel
onready var preset_list = $VBoxContainer/Split/GeneralContainer/PresetContainer/PresetListContainer/PresetList
onready var world_width_spinbox = $VBoxContainer/Split/GeneralContainer/WorldSettingsContainer/WorldSizeContainer/WorldWidthContainer/WorldWidthSpinbox
onready var world_height_spinbox = $VBoxContainer/Split/GeneralContainer/WorldSettingsContainer/WorldSizeContainer/WorldHeightContainer/WorldHeightSpinbox
onready var red_count_spinbox = $VBoxContainer/Split/GeneralContainer/ParticleSettingsContainer/HBoxContainer/RedCountSpinBox
onready var green_count_spinbox = $VBoxContainer/Split/GeneralContainer/ParticleSettingsContainer/HBoxContainer2/GreenCountSpinBox
onready var white_count_spinbox = $VBoxContainer/Split/GeneralContainer/ParticleSettingsContainer/HBoxContainer3/WhiteCountSpinBox
onready var blue_count_spinbox = $VBoxContainer/Split/GeneralContainer/ParticleSettingsContainer/HBoxContainer4/BlueCountSpinBox
onready var boundaries_button = $VBoxContainer/Split/GeneralContainer/WorldSettingsContainer/BoundariesButton
onready var rules_container = $VBoxContainer/Split/RuleContainer
onready var red_count_color_rect = $VBoxContainer/Split/GeneralContainer/ParticleSettingsContainer/HBoxContainer/RedColorPickerButton
onready var green_count_color_rect = $VBoxContainer/Split/GeneralContainer/ParticleSettingsContainer/HBoxContainer2/GreenColorPickerButton
onready var white_count_color_rect = $VBoxContainer/Split/GeneralContainer/ParticleSettingsContainer/HBoxContainer3/WhiteColorPickerButton
onready var blue_count_color_rect = $VBoxContainer/Split/GeneralContainer/ParticleSettingsContainer/HBoxContainer4/BlueColorPickerButton
onready var viscosity_slider = $VBoxContainer/Split/GeneralContainer/WorldSettingsContainer/ViscositySlider
onready var save_rule_name_edit = $SavePanel/RuleNameEdit
onready var import_string_edit = $ImportPanel/ImportStringEdit
onready var export_string_edit = $ExportPanel/ExportStringEdit


func _ready() -> void:
	rect_size = Vector2(0, 0)
	red_count_color_rect.color = Globals.RED_COLOR
	green_count_color_rect.color = Globals.GREEN_COLOR
	white_count_color_rect.color = Globals.WHITE_COLOR
	blue_count_color_rect.color = Globals.BLUE_COLOR
	boundaries_button.clear()
	boundaries_button.add_item("No bounds", Globals.BOUNDS_DISABLED)
	boundaries_button.add_item("Strict bounds", Globals.BOUNDS_STRICT)
	boundaries_button.add_item("Repeating bounds", Globals.BOUNDS_REPEATING)
	boundaries_button.select(Globals.BOUNDS_STRICT)
	update_load_menu()
	connect("color_changed", rules_container, "_on_color_updated")

func _process(_delta):
	fps_label.text = "FPS: " + str(Engine.get_frames_per_second())


func update_particle_count(color: int, value: int) -> void:
	match(color):
		Globals.RED:
			red_count_spinbox.value = value
		Globals.GREEN:
			green_count_spinbox.value = value
		Globals.WHITE:
			white_count_spinbox.value = value
		Globals.BLUE:
			blue_count_spinbox.value = value


func update_world_size(world_size: Vector2) -> void:
	world_width_spinbox.value = world_size.x
	world_height_spinbox.value = world_size.y


func update_viscosity(val) -> void:
	viscosity_slider.value = val


func update_rules_container() -> void:
	rules_container.build(RuleLoader.current_rules)


func update_load_menu() -> void:
	var r = RuleLoader.rules
	preset_list.clear()
	for name in r:
		preset_list.add_item(name)


func _on_HideButton_pressed():
	if hidden:
		$AnimationPlayer.play_backwards("Hide")
	else:
		$AnimationPlayer.play("Hide")
	hidden = not hidden



func _on_OpenAudioFileDialog_file_selected(path):
	emit_signal("audio_file_selected", path)


func _on_LoadAudioButton_pressed():
	$OpenAudioFileDialog.popup_centered(Vector2(500, 500))


func _on_StopButton_pressed():
	emit_signal("music_stop")


func _on_VolumeSlider_value_changed(value):
	emit_signal("volume_changed", clamp(value / 100.0, 0.0, 1.0))


func _on_FullscreenButton_pressed():
	OS.window_fullscreen = !OS.window_fullscreen


func _on_QuitButton_pressed():
	emit_signal("quit")


func _on_CountApplyButton_pressed():
	emit_signal(
		"particle_count_applied",
		red_count_spinbox.value,
		green_count_spinbox.value,
		white_count_spinbox.value,
		blue_count_spinbox.value
	)


func _on_RandomButton_pressed():
	emit_signal("randomize_rules")


func _on_RestartButton_pressed():
	emit_signal("restart_world")


func _on_WorldWidthSpinbox_value_changed(value):
	emit_signal(
		"world_size_changed",
		Vector2(value, world_height_spinbox.value)
	)


func _on_WorldHeightSpinbox_value_changed(value):
	emit_signal(
		"world_size_changed",
		Vector2(world_width_spinbox.value, value)
	)


func _on_PresetList_item_selected(index):
	var n = preset_list.get_item_text(index)
	emit_signal("preset_selected", n)


func _on_SaveButton_pressed():
	save_rule_name_edit.text = RuleLoader.current_rule_name
	$SavePanel.popup(Rect2(300, 700, 350, 75))
	save_rule_name_edit.grab_focus()
	save_rule_name_edit.select_all()


func _on_SavePanel_confirmed():
	var new_name: String = save_rule_name_edit.text
	RuleLoader.add_new_rule_and_save(new_name)
	update_load_menu()


func _on_ImportPanel_confirmed():
	var s = import_string_edit.text.strip_edges()
	RuleLoader.import_rule_string(s)


func _on_ImportButton_pressed():
	$ImportPanel.popup(Rect2(300, 700, 350, 75))
	import_string_edit.grab_focus()
	import_string_edit.select_all()


func _on_ExportButton_pressed():
	var s := RuleLoader.generate_rule_string(RuleLoader.current_rules)
	export_string_edit.text = s
	$ExportPanel.popup(Rect2(300, 700, 350, 75))
	export_string_edit.grab_focus()
	export_string_edit.select_all()


func _on_RuleContainer_attraction_updated(index, value):
	RuleLoader.modify_rule(int(index), 2, value)


func _on_RuleContainer_range_updated(index: int, value: float):
	RuleLoader.modify_rule(int(index), 3, value)


func _on_ViscositySlider_value_changed(value):
	emit_signal("viscosity_changed", value)


func _on_BoundariesButton_item_selected(index):
	emit_signal("boundaries_changed", index)



func _on_RedColorPickerButton_color_changed(color):
	emit_signal("color_changed", Globals.RED, color)


func _on_GreenColorPickerButton_color_changed(color):
	emit_signal("color_changed", Globals.GREEN, color)


func _on_WhiteColorPickerButton_color_changed(color):
	emit_signal("color_changed", Globals.WHITE, color)


func _on_BlueColorPickerButton_color_changed(color):
	emit_signal("color_changed", Globals.BLUE, color)
