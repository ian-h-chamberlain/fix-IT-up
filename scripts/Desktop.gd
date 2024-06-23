extends Node

enum Power {ON, OFF}

@export var power_state: Power = Power.OFF
@export var floppy_inserted: bool = true
@export var cd_inserted: bool = true

func _ready():
	$PowerButton.pressed.connect(_on_power_pressed)
	$HardDisk/LED/Timer.timeout.connect(func(): _toggle_vis($HardDisk/LED))

	$Floppy/EjectButton.pressed.connect(func(): _toggle_vis($Floppy/LED))
	$Floppy/LED/Timer.timeout.connect(func(): _toggle_vis($Floppy/LED))

	$CD/EjectButton.pressed.connect(func(): _toggle_vis($CD/LED))
	$CD/LED/Timer.timeout.connect(func(): _toggle_vis($CD/LED))

	if power_state == Power.ON:
		_toggle_vis($HardDisk/LED)
		if floppy_inserted:
			_toggle_vis($Floppy/LED)

		if cd_inserted:
			_toggle_vis($CD/LED)

func _toggle_vis(led: ColorRect):
	led.visible = not led.visible
	var timer := led.get_node("Timer") as Timer
	timer.wait_time = randf_range(0.05, 0.6)
	timer.start()

func _on_power_pressed():
	match power_state:
		Power.OFF: power_state = Power.ON
		Power.ON: power_state = Power.OFF

	_toggle_leds()

func _toggle_leds():
	for timer in [
		$CD/LED/Timer,
		$Floppy/LED/Timer,
		$HardDisk/LED/Timer,
	]:
		if timer.is_stopped() and power_state == Power.ON:
			timer.wait_time += randf_range(1.0, 3.0)
			timer.start()
		elif not timer.is_stopped() and power_state == Power.OFF:
			timer.stop()

	if power_state == Power.OFF:
		for led in [
			$PowerLED,
			$CD/LED,
			$Floppy/LED,
			$HardDisk/LED,
		]:
			led.visible = false
	else:
		$PowerLED.visible = true
