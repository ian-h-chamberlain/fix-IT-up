extends Node

@export_range(-1.0, 1.0) var brightness: float:
	set = _set_brightness

@export var brightness_increment: float
@export var state: State

@onready var _brightness_rect: ColorRect = $"Brightness"
@onready var _brightness_up: Button = $"BrightnessUp"
@onready var _brightness_down: Button = $"BrightnessDown"
@onready var _power: Button = $"Power"

enum State {ON, OFF}

func _ready():
	_power.pressed.connect(_on_power_pressed)
	_brightness_up.pressed.connect(_on_brightness_up_pressed)
	_brightness_down.pressed.connect(_on_brightness_down_pressed)

	# trigger once so that visual appearance matches initial state
	_set_brightness(brightness)

func _set_brightness(b: float):
	brightness = b

	if state == State.OFF:
		_brightness_rect.color.a = 1.0
		_brightness_rect.color.v = 0.2
		return

	if brightness > 0.0:
		_brightness_rect.color.v = 1.0
		_brightness_rect.color.a = brightness
	else:
		_brightness_rect.color.v = 0.2
		_brightness_rect.color.a = -brightness

func _on_brightness_up_pressed():
	if state == State.ON:
		brightness = min(1.0, brightness + brightness_increment)

func _on_brightness_down_pressed():
	if state == State.ON:
		brightness = max( - 1.0, brightness - brightness_increment)

func _on_power_pressed():
	match state:
		State.ON: state = State.OFF
		State.OFF: state = State.ON

	# Retrigger the normal brightness flow
	_set_brightness(brightness)
