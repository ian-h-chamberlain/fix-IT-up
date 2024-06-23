extends Control
class_name Main

signal describe_problem(problem: Array[Problem])

@onready var _desktop := $Interactables/Desktop as Desktop
@onready var _monitor := $Interactables/Monitor as Monitor

var current_problem: Problem = null:
    set(prob):
        current_problem = prob
        describe_problem.emit(prob)

        if prob != null:
            _set_problem_state()

var problem_timer: Timer = Timer.new()

enum ProblemType {
    CD_STUCK,
    FLOPPY_STUCK,
    BRIGHTNESS_LOW,
    BRIGHTNESS_HIGH,
    MONITOR_OFF,
    PC_OFF,
}

class Problem:
    var type: ProblemType

    var dialogue_text: String:
        get:
            return "\n".join([
                [
                    "I've been having some issues with my computer.",
                    "Something seems wrong here.",
                    "Help!",
                ].pick_random(),
                self._problem_str(),
                [
                    "Can you help?",
                    "Any idea how to make it work again?",
                    "Is it fixable?",
                ].pick_random()
            ])

    func _init():
        self.type = ProblemType[ProblemType.keys().pick_random()]

    func _problem_str() -> String:
        var choices: Array[String] = []

        match self.type:
            ProblemType.CD_STUCK:
                choices = [
                    "I keep seeing something like [code]disc read error[/code]?",
                    "Some chewing gum [i]might[/i] have gotten into the tray...",
                ]
            ProblemType.FLOPPY_STUCK:
                choices = [
                    "I keep seeing something like [code]disk read error[/code]?",
                    "The black square thingy is kinda jammed in there.",
                ]
            ProblemType.BRIGHTNESS_LOW, ProblemType.MONITOR_OFF, ProblemType.PC_OFF:
                choices = [
                    "I can't see [b]anything[/b] on the screen!",
                    "I tried turning it off and on again but the screen is just [b]black[/b]."
                ]
                if self.type == ProblemType.PC_OFF:
                    choices.append_array([
                        "None of the little lights are blinking anymore and [i]nothing[/i] works!",
                        "I think the mainframe must have burnt out, [i]ya know[/i]?",
                    ])

            ProblemType.BRIGHTNESS_HIGH:
                choices = [
                    "Maybe my monitor is busted? It's really hard to read anything on it.",
                    "All of a sudden it is as if I turned to a TV channel that doesn't exist!",
                ]

        return choices.pick_random()

func _ready():
    # TODO: turn this into a game loop. Probably with some kind of "thank you!"
    # and perhaps a transition of sorts to the next customer
    current_problem = Problem.new()
    _randomize_state()
    _set_problem_state()

## Set the initial state to be totally random. This should be called before
## Problem.set_state to make sure the state makes sense for the current problem.
func _randomize_state():
    _desktop.cd_inserted = [true, false].pick_random()
    _desktop.floppy_inserted = [true, false].pick_random()
    _desktop.power_state = Desktop.Power.values().pick_random()
    _monitor.power_state = Monitor.Power.values().pick_random()
    _monitor.brightness = randf_range( - 1.0, 1.0)

## Set the state needed for the current problem to be solved
func _set_problem_state():
    if current_problem == null:
        return

    match current_problem.type:
        ProblemType.CD_STUCK:
            _desktop.cd_inserted = false
        ProblemType.FLOPPY_STUCK:
            _desktop.floppy_inserted = false
        ProblemType.PC_OFF:
            _desktop.power_state = Desktop.Power.OFF
        ProblemType.BRIGHTNESS_LOW:
            _monitor.brightness = -1.0
        ProblemType.BRIGHTNESS_HIGH:
            _monitor.brightness = 1.0
            _monitor.power_state = Monitor.Power.ON
        ProblemType.MONITOR_OFF:
            _monitor.power_state = Monitor.Power.OFF

func _process(_delta):
    if Input.is_action_just_pressed("add_problem"):
        _randomize_state()
        current_problem = Problem.new()

    if Input.is_action_just_pressed("clear_problems"):
        current_problem = null
