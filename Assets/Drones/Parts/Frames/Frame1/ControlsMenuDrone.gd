extends Node3D


const RPM := 4.0
const ANGLE := 0.5

var throttle := 0.0
var yaw := 0.0
var pitch := 0.0
var roll := 0.0


func _ready():
    $Motor1 / Propeller1 / PropBlurDisk.hide()
    $Motor2 / Propeller2 / PropBlurDisk.hide()
    $Motor3 / Propeller3 / PropBlurDisk.hide()
    $Motor4 / Propeller4 / PropBlurDisk.hide()
    $Motor1 / Propeller1 / CCW.hide()
    $Motor2 / Propeller2 / CW.hide()
    $Motor3 / Propeller3 / CCW.hide()
    $Motor4 / Propeller4 / CW.hide()

    var color := Color(0.7, 0.05, 0.05)
    var prop := "CW"
    for i in range(4):
        if i == 1 or i == 3:
            prop = "CCW"
        # get_node("Motor%d/Propeller%d/%s" % [i + 1, i + 1, prop]) super.mesh.surface_get_material(0).set_shader_parameter("propeller_color", color)
        # Get the specific node path using formatted string
        var propeller_path = "Motor%d/Propeller%d/%s" % [i + 1, i + 1, prop]
        var propeller = get_node(propeller_path)

        # Check if the node and its material exist before accessing
        if propeller and propeller.mesh:
            var material = propeller.mesh.surface_get_material(0)
            if material:
                material.set_shader_parameter("propeller_color", color)
            else:
                push_error(
                    "Material not found on propeller at path: " +
                    propeller_path)
        else:
            push_error("Propeller node not found at path: " + propeller_path)


func _process(delta):
    # transform = Transform3D.IDENTITY.rotated(Vector3.UP, -yaw * ANGLE) \
    # 	super.rotated(Vector3.RIGHT, pitch * ANGLE).rotated(Vector3.FORWARD, roll * ANGLE)
    # Start with an identity transform
    var transform = Transform3D.IDENTITY

    # Apply each rotation sequentially
    transform = transform.rotated(Vector3.UP, -yaw * ANGLE)
    transform = transform.rotated(Vector3.RIGHT, pitch * ANGLE)
    transform = transform.rotated(Vector3.FORWARD, roll * ANGLE)

    $Motor1 / Motor_Rotor.rotate_object_local(Vector3.UP, min(-(throttle * RPM - yaw + pitch + roll) * RPM * delta, 0))
    $Motor1 / Propeller1.rotate_object_local(Vector3.UP, min(-(throttle * RPM - yaw + pitch + roll) * RPM * delta, 0))
    $Motor2 / Motor_Rotor.rotate_object_local(Vector3.UP, max((throttle * RPM + yaw + pitch - roll) * RPM * delta, 0))
    $Motor2 / Propeller2.rotate_object_local(Vector3.UP, max((throttle * RPM + yaw + pitch - roll) * RPM * delta, 0))
    $Motor3 / Motor_Rotor.rotate_object_local(Vector3.UP, min(-(throttle * RPM - yaw - pitch - roll) * RPM * delta, 0))
    $Motor3 / Propeller3.rotate_object_local(Vector3.UP, min(-(throttle * RPM - yaw - pitch - roll) * RPM * delta, 0))
    $Motor4 / Motor_Rotor.rotate_object_local(Vector3.UP, max((throttle * RPM + yaw - pitch + roll) * RPM * delta, 0))
    $Motor4 / Propeller4.rotate_object_local(Vector3.UP, max((throttle * RPM + yaw - pitch + roll) * RPM * delta, 0))


func _input(event) -> void:
    if event is InputEventJoypadMotion:
        if event.is_action("throttle_up") or event.is_action("throttle_down"):
            throttle = (event.get_action_strength("throttle_up") -
                        event.get_action_strength("throttle_down")) / 2.0 + 0.5
        elif event.is_action("yaw_left") or event.is_action("yaw_right"):
            yaw = event.get_action_strength(
                "yaw_right") - event.get_action_strength("yaw_left")
        elif event.is_action("pitch_up") or event.is_action("pitch_down"):
            pitch = event.get_action_strength(
                "pitch_up") - event.get_action_strength("pitch_down")
        elif event.is_action("roll_left") or event.is_action("roll_right"):
            roll = event.get_action_strength(
                "roll_right") - event.get_action_strength("roll_left")
