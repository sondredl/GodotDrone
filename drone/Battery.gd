extends Node3D
class_name Battery


const CELL_VOLTAGE_FULL := 4.2
const CELL_VOLTAGE_STORAGE := 3.8
const CELL_VOLTAGE_LOW := 3.5
const CELL_VOLTAGE_DAMAGED := 3.3
const DAMAGE_HEALTH_DROP_SPEED := 0.05


@export var cells := 4  # (int, 1, 6)
@export var capacity := 1300  # (int, 100, 10000)
@export var c_rating := 100  # (int, 1, 200)
@export var infinite := false
var voltage := 0.0
var current := 0.0
var mah := 0.0
var health := 1.0


func _ready() -> void:
    voltage = cells * CELL_VOLTAGE_FULL


func _physics_process(delta: float) -> void:
    # update voltage, current, mah
    if current > capacity * c_rating or voltage < cells * CELL_VOLTAGE_DAMAGED:
        health -= delta * DAMAGE_HEALTH_DROP_SPEED
