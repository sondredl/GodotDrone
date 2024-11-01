extends Control


@export var horizontal := false
@export var width := 100
@export var height := 100
@export var max_value := 1.0
var value := 0.0

var container: BoxContainer = null


@onready var pos := $TextureProgressPos
@onready var neg := $TextureProgressNeg
func _ready() -> void:
    self.remove_child(pos)
    self.remove_child(neg)
    if horizontal:
        container = HBoxContainer.new()
        add_child(container)
        container.add_child(neg)
        container.add_child(pos)
    else:
        container = VBoxContainer.new()
        add_child(container)
        container.add_child(pos)
        container.add_child(neg)
    pos.set_owner(container)
    neg.set_owner(container)
    container.custom_minimum_size = Vector2(width, height)
    container.size = container.custom_minimum_size
    container.size_flags_horizontal = SIZE_SHRINK_CENTER
    container.size_flags_vertical = SIZE_SHRINK_CENTER
    container.add_theme_constant_override("separation", 0)

    pos.size_flags_horizontal = SIZE_EXPAND
    pos.size_flags_vertical = SIZE_EXPAND
    pos.min_value = 0
    pos.max_value = max_value
    pos.step = max_value / 100.0
    neg.size_flags_horizontal = SIZE_EXPAND
    neg.size_flags_vertical = SIZE_EXPAND
    neg.min_value = 0
    neg.max_value = max_value
    neg.step = max_value / 100.0

    if horizontal:
        pos.fill_mode = TextureProgressBar.FILL_LEFT_TO_RIGHT
        neg.fill_mode = TextureProgressBar.FILL_RIGHT_TO_LEFT
        pos.custom_minimum_size = Vector2(width / 2.0, height)
        neg.custom_minimum_size = Vector2(width / 2.0, height)
    else:
        pos.fill_mode = TextureProgressBar.FILL_BOTTOM_TO_TOP
        neg.fill_mode = TextureProgressBar.FILL_TOP_TO_BOTTOM
        pos.custom_minimum_size = Vector2(width, height / 2.0)
        neg.custom_minimum_size = Vector2(width, height / 2.0)


func update_gauge(v: float) -> void:
    value = v
    if value > 0:
        pos.value = value
        neg.value = 0
    elif value < 0:
        pos.value = 0
        neg.value = -value
    elif value == 0:
        pos.value = 0
        neg.value = 0
