extends Node

class_name RadioController

signal reset_requested
signal mode_changed
signal arm_input
signal disarm_input


export (NodePath) var target_path = null
var target = null

var input = [0.0, 0.0, 0.0, 0.0]


func _ready():
	target = get_node(target_path)
	connect("reset_requested", target, "_on_reset")
	connect("mode_changed", target.flight_controller, "_on_cycle_flight_modes")
	connect("arm_input", target.flight_controller, "_on_arm_input")
	connect("disarm_input", target.flight_controller, "_on_disarm_input")


func _input(event):
	if Input.is_action_just_pressed("respawn"):
		emit_signal("reset_requested")
	elif event.is_action_pressed("cycle_flight_modes"):
		emit_signal("mode_changed")
	elif event.is_action_pressed("toggle_arm"):
		if target.flight_controller.armed == false:
			emit_signal("arm_input")
		else:
			emit_signal("disarm_input")


func _physics_process(delta):
	read_input()
	
	if target is Drone:
		target.flight_controller.input = input


func read_input():
	var power = (Input.get_action_strength("throttle_up") - Input.get_action_strength("throttle_down") + 1) / 2
	var pitch = Input.get_action_strength("pitch_up") - Input.get_action_strength("pitch_down")
	var roll = Input.get_action_strength("roll_right") - Input.get_action_strength("roll_left")
	var yaw = Input.get_action_strength("yaw_right") - Input.get_action_strength("yaw_left")
#	print("Pow: %6.3f ptc: %6.3f rol: %6.3f yaw: %6.3f" % [power, pitch, roll, yaw])
	input = [power, yaw, roll, pitch]
