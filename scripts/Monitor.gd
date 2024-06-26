extends Node
class_name Monitor

@export_range(-1.0, 1.0) var brightness: float:
    set = _set_brightness

@export var brightness_increment: float
@export var power_state: Power:
    set(state):
        power_state = state
        _set_brightness(brightness)
    get:
        if _pc_power == Desktop.Power.ON:
            return power_state
        return Power.OFF

@onready var _brightness_rect: ColorRect = $"Brightness"
@onready var _brightness_up: Button = $"BrightnessUp"
@onready var _brightness_down: Button = $"BrightnessDown"
@onready var _power: Button = $"Power"

var _pc_power: Desktop.Power

enum Power {ON, OFF}

func _ready():
    _power.pressed.connect(_on_power_pressed)
    _brightness_up.pressed.connect(_on_brightness_up_pressed)
    _brightness_down.pressed.connect(_on_brightness_down_pressed)

    # trigger once so that visual appearance matches initial power_state
    _set_brightness(brightness)

func _set_brightness(b: float):
    brightness = b

    if _pc_power == Desktop.Power.OFF or power_state == Power.OFF:
        _brightness_rect.color.a = 1.0
        _brightness_rect.color.v = 0.1
        return

    if brightness > 0.0:
        _brightness_rect.color.v = 1.0
        _brightness_rect.color.a = brightness
    else:
        _brightness_rect.color.v = 0.1
        _brightness_rect.color.a = -brightness

func _on_brightness_up_pressed():
    if power_state == Power.ON:
        brightness = min(1.0, brightness + brightness_increment)

func _on_brightness_down_pressed():
    if power_state == Power.ON:
        brightness = max( - 1.0, brightness - brightness_increment)

func _on_power_pressed():
    match power_state:
        Power.ON: power_state = Power.OFF
        Power.OFF: power_state = Power.ON

    # Retrigger the normal brightness flow
    _set_brightness(brightness)

func _on_pc_power_changed(state: Desktop.Power):
    _pc_power = state
    _set_brightness(brightness)
