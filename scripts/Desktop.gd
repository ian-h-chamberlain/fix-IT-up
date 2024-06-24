extends Node
class_name Desktop

enum Power {ON, OFF}

signal power_state_updated(Power)

@export var power_state: Power = Power.ON:
    set(state):
        power_state = state
        _handle_power_change()

@export var floppy_inserted: bool = true:
    set(inserted):
        if power_state == Power.ON:
            floppy_inserted = inserted
            _toggle_blinking($Floppy/LED, inserted)

@export var cd_inserted: bool = true:
    set(inserted):
        if power_state == Power.ON:
            cd_inserted = inserted
            _toggle_blinking($CD/LED, inserted)

func _ready():
    $PowerButton.pressed.connect(_on_power_pressed)
    $HardDisk/LED/Timer.timeout.connect(func(): _blink_and_reset_timer($HardDisk/LED))

    $Floppy/EjectButton.pressed.connect(func(): floppy_inserted=not floppy_inserted)
    $Floppy/LED/Timer.timeout.connect(func(): _blink_and_reset_timer($Floppy/LED))

    $CD/EjectButton.pressed.connect(func(): cd_inserted=not cd_inserted)
    $CD/LED/Timer.timeout.connect(func(): _blink_and_reset_timer($CD/LED))

    if power_state == Power.ON:
        $PowerLED.visible = true
        _blink_and_reset_timer($HardDisk/LED)

        if floppy_inserted:
            _blink_and_reset_timer($Floppy/LED)

        if cd_inserted:
            _blink_and_reset_timer($CD/LED)

func _toggle_blinking(led: ColorRect, inserted: bool, delay: float=- 1.0):
    var timer := led.get_node("Timer") as Timer

    if not inserted:
        led.visible = false
        timer.stop()
    else:
        led.visible = true
        _blink_and_reset_timer(led, delay)

func _blink_and_reset_timer(led: ColorRect, wait_time: float=- 1.0):
    led.visible = not led.visible
    var timer := led.get_node("Timer") as Timer
    timer.wait_time = randf_range(0.05, 0.6)
    timer.start(wait_time)

func _on_power_pressed():
    match power_state:
        Power.ON: power_state = Power.OFF
        Power.OFF: power_state = Power.ON

func _handle_power_change():
    power_state_updated.emit(power_state)
    match power_state:
        Power.ON:
            $PowerLED.visible = true
            _toggle_blinking($HardDisk/LED, true, randf_range(0.5, 1.5))
            _toggle_blinking($CD/LED, cd_inserted, randf_range(1.5, 3.0))
            _toggle_blinking($Floppy/LED, floppy_inserted, randf_range(1.5, 2.5))

        Power.OFF:
            $PowerLED.visible = false
            _toggle_blinking($HardDisk/LED, false)
            _toggle_blinking($CD/LED, false)
            _toggle_blinking($Floppy/LED, false)
