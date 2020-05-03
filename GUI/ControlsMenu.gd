extends Control


var packed_calibration_menu = preload("res://GUI/CalibrationMenu.tscn")

onready var controller_list = $ControlsVBox/ControllerVBox/MenuButton
onready var controller_checkbutton = $ControlsVBox/ControllerVBox/ControllerCheckButton
onready var axes_list = $ControlsVBox/AxesVBox/AxesList
onready var button_grid = $ControlsVBox/ButtonsVBox/ButtonGrid

var connected_joypads = []
var auto_detect_controller = false
var active_controller = -1
var default_controller = -1

signal controller_detected
signal back


func _ready():
	connect("controller_detected", self, "_on_controller_autodetected")
	Input.connect("joy_connection_changed", self, "_on_joypad_connection_changed")
	
	$VBoxContainer/ButtonCalibrate.connect("pressed", self, "_on_calibrate_pressed")
	$VBoxContainer/ButtonBack.connect("pressed", self, "_on_back_pressed")
	
	Input.emit_signal("joy_connection_changed", -1, false)
	
	controller_list.connect("pressed", self, "_on_controller_list_pressed")
	controller_list.get_popup().connect("id_pressed", self, "_on_controller_selected")
	controller_list.get_popup().connect("modal_closed", self, "_on_controller_select_aborted")
	controller_list.get_popup().add_font_override("font", load("res://GUI/MenuFont.tres"))
	
	controller_checkbutton.connect("toggled", self, "_on_checkbutton_toggled")
	
	# TODO: only allow calibration for active controller OR update controller list
	
	var axis = TextureProgress.new()
	axis.rect_min_size = Vector2(200, 10)
	axis.max_value = 1.0
	axis.min_value = -1.0
	axis.value = 0.0
	axis.step = 0.01
	axis.nine_patch_stretch = true
	axis.stretch_margin_top = 3
	axis.stretch_margin_bottom = 3
	axis.stretch_margin_left = 3
	axis.stretch_margin_right = 3
	axis.texture_progress = load("res://Assets/GUI/ControlAxes.png")
	axis.tint_progress = Color(1.0, 0.6, 0.0, 1.0)
	axis.texture_under = axis.texture_progress
	axis.tint_under = axis.tint_progress * 0.25
	axis.tint_under.a = 1.0
	for i in range(8):
		axes_list.add_child(axis.duplicate())
	axis.queue_free()
	
	var button = ColorRect.new()
	button.rect_min_size = Vector2(20, 20)
	button.color = Color(0.8, 0.8, 0.8, 1.0)
	for i in range(16):
		button_grid.add_child(button.duplicate())
	button.queue_free()
	
	var active_controller_found = false
	var active_device = -1
	connected_joypads = Input.get_connected_joypads()
	for joypad in connected_joypads:
		if Input.get_joy_guid(joypad) == Global.active_controller_guid:
			active_controller_found = true
			active_device = joypad
			break
	if !active_controller_found:
		var default_controller_found = false
		if default_controller >= 0:
			for joypad in connected_joypads:
				if Input.get_joy_guid(joypad) == Global.default_controller_guid:
					default_controller_found = true
					default_controller = joypad
					active_device = joypad
		if !default_controller_found:
			if connected_joypads.empty():
				active_device = -1
			else:
				active_device = connected_joypads[0]
	controller_list.get_popup().emit_signal("id_pressed", connected_joypads.find(active_device))


func _input(event):
	if event is InputEventJoypadMotion or event is InputEventJoypadButton:
		if auto_detect_controller:
			if event is InputEventJoypadMotion and abs(event.axis_value) > 0.8 or event is InputEventJoypadButton:
				emit_signal("controller_detected", event.device)
		elif Input.get_joy_name(event.device) == controller_list.text:
			if event is InputEventJoypadMotion and event.axis < 8:
				update_axis_value(event.axis, event.axis_value)
			elif event is InputEventJoypadButton and event.button_index < 16:
				update_button_value(event.button_index, event.is_pressed())


func _on_calibrate_pressed():
	if packed_calibration_menu.can_instance():
		var calibration_menu = packed_calibration_menu.instance()
		add_child(calibration_menu)
		$VBoxContainer.visible = false
		yield(calibration_menu, "back")
		calibration_menu.queue_free()
		$VBoxContainer.visible = true


func _on_back_pressed():
	emit_signal("back")


func update_controller_list():
	connected_joypads = Input.get_connected_joypads()
	controller_list.get_popup().clear()
	if connected_joypads.empty():
		controller_list.get_popup().add_item("No controller found")
		controller_list.text = "No controller found"
		active_controller = -1
		controller_checkbutton.disabled = true
		controller_checkbutton.pressed = false
	else:
		for joypad in connected_joypads:
			controller_list.get_popup().add_item(Input.get_joy_name(joypad))
		controller_checkbutton.disabled = false


func _on_joypad_connection_changed(device: int, connected: bool):
	update_controller_list()
	var active_controller_found = false
	for joypad in connected_joypads:
		if Input.get_joy_name(joypad) == controller_list.text:
			active_controller_found = true
			break
	if !active_controller_found:
		active_controller = -1
		controller_list.get_popup().emit_signal("id_pressed", active_controller)


func _on_controller_list_pressed():
	update_controller_list()
	auto_detect_controller = true


func _on_controller_select_aborted():
	auto_detect_controller = false


func _on_controller_autodetected(device: int):
	active_controller = device
	controller_list.get_popup().emit_signal("id_pressed", connected_joypads.find(device))


func _on_controller_selected(id: int):
	if controller_list.get_popup().visible:
		controller_list.get_popup().hide()
	auto_detect_controller = false
	if connected_joypads.empty():
		return
	if connected_joypads[id] != active_controller:
		active_controller = connected_joypads[id]
		var checkbutton_pressed = (Input.get_joy_guid(active_controller) == Global.default_controller_guid)
		print("Active: %s, default: %s, check: %s" % [Input.get_joy_guid(active_controller), Global.default_controller_guid, checkbutton_pressed])
		controller_checkbutton.pressed = checkbutton_pressed
		Global.update_active_device(active_controller)
		update_input_map()
		update_axes_and_buttons(active_controller)


func _on_checkbutton_toggled(pressed: bool):
	if (!pressed and active_controller != default_controller) or (pressed and active_controller == default_controller):
		return
	if pressed:
		default_controller = active_controller
	else:
		default_controller = -1
	var err = Global.update_default_device(default_controller)
	if err != OK:
		print_debug("Controller checkbox input map save error")


func update_axes_and_buttons(device: int):
	controller_list.text = Input.get_joy_name(device)
	for i in range(8):
		update_axis_value(i, Input.get_joy_axis(device, i))
	for i in range(16):
		update_button_value(i, Input.is_joy_button_pressed(device, i))


func update_axis_value(id: int, value: float):
	axes_list.get_children()[id].value = value


func update_button_value(id: int, pressed: bool):
	var button = button_grid.get_children()[id]
	if pressed:
		button.modulate = Color(1.25, 0.0, 0.0, 1.0)
	else:
		button.modulate = Color(1.0, 1.0, 1.0, 1.0)


func update_input_map():
	# TODO: read cfg file and update input map
	pass