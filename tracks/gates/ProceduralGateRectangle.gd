extends ProceduralGate
class_name ProceduralGateRectangle


@export var width := 1.5
@export var height := 1.5
@export var horizontal_panel_width := 0.2
@export var vertical_panel_width := 0.2
@export var thickness := 0.05
func _add_geometry() -> void:
    geometry = CSGBox3D.new()
    geometry.width = width + 2 * vertical_panel_width
    geometry.height = height + 2 * horizontal_panel_width
    geometry.depth = thickness
    add_child(geometry)
    var hole := CSGBox3D.new()
    hole.operation = CSGShape3D.OPERATION_SUBTRACTION
    hole.width = width
    hole.height = height
    hole.depth = 2 * thickness
    geometry.add_child(hole)


func _add_collision() -> void:
    if static_body.get_child_count() > 0:
        for child in static_body.get_children():
            remove_child(child)
            child.queue_free()
    # Add collision shapes
    var shape_horizontal := get_horizontal_panel_shape()
    var shape_vertical := get_vertical_panel_shape()

    add_shape(shape_horizontal, Vector3(
        0, -(height + horizontal_panel_width) / 2.0, 0))
    add_shape(
        shape_horizontal,
        Vector3(
            0,
            (height + horizontal_panel_width) / 2.0,
            0))
    add_shape(shape_vertical, Vector3(-(width + vertical_panel_width) / 2.0, 0, 0))
    add_shape(
        shape_vertical,
        Vector3(
            (width + vertical_panel_width) / 2.0,
            0,
            0))


func _add_checkpoint() -> void:
    var shape := BoxShape3D.new()
    shape.extents = Vector3(width / 2.0, height / 2.0, thickness / 2.0)
    var collision := CollisionShape3D.new()
    collision.shape = shape
    checkpoint.add_child(collision)


func get_horizontal_panel_shape() -> BoxShape3D:
    var shape_horizontal := BoxShape3D.new()
    shape_horizontal.extents = Vector3(
        width / 2.0 + vertical_panel_width,
        horizontal_panel_width / 2.0,
        thickness / 2.0)
    return shape_horizontal


func get_vertical_panel_shape() -> BoxShape3D:
    var shape_vertical := BoxShape3D.new()
    shape_vertical.extents = Vector3(
        vertical_panel_width,
        height / 2.0 + horizontal_panel_width,
        thickness / 2.0)
    return shape_vertical


func add_shape(shape: Shape3D, offset: Vector3) -> void:
    var collision_shape := CollisionShape3D.new()
    collision_shape.shape = shape
    collision_shape.translate_object_local(offset)
    static_body.add_child(collision_shape)
