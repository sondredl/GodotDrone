extends Control
class_name HUDLadder


@onready var horizon := $HorizonLine
var center_pos := Vector2.ZERO

var pitch_marker_scene := preload("res://HUD/HUDPitchMarker.tscn")
var pitch_markers := []
var pitch_marker_spacing := 20


func _ready() -> void:
    horizon.pivot_offset = horizon.size / 2
    center_pos = size / 2 - horizon.size / 2

    for i in range(-85, 90, 5):
        if i == 0:
            continue
        var marker := pitch_marker_scene.instantiate()
        horizon.add_child(marker)
        pitch_markers.append(marker)
        marker.update_marker(i)
        marker.position = Vector2(
            horizon.size.x / 2, -i * pitch_marker_spacing)

func update_ladder(pitch: float, roll: float) -> void:
    var horizon_length = size.x / abs(cos(roll))
    if horizon_length > size.length():
        horizon_length = size.y / abs(sin(roll))
    horizon.size.x = horizon_length - 10
    horizon.set_anchors_and_offsets_preset(
        Control.PRESET_CENTER, Control.PRESET_MODE_KEEP_SIZE)
    center_pos = size / 2.0 - horizon.size / 2.0
    horizon.position = center_pos + \
        rad_to_deg(pitch * pitch_marker_spacing) * Vector2(-sin(roll), cos(roll))
    horizon.pivot_offset = horizon.size / 2.0
    horizon.rotation = rad_to_deg(roll)
