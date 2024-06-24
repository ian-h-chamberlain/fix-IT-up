extends Node
class_name Main

signal describe_problem(problem: Problem)

@onready var _desktop := $Interactables/Desktop as Desktop
@onready var _monitor := $Interactables/Monitor as Monitor

@export var transition_time: float = 0.5

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
                    "It says [code]please insert disk 2[/code] and I don't know what that means."
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
    # Even though it's disabled, this should allow for keyboard / gamepad focus to work
    $Interactables/CableMgmt.grab_focus()

    # TODO: turn this into a game loop. Probably with some kind of "thank you!"
    # and perhaps a transition of sorts to the next customer
    current_problem = Problem.new()
    _randomize_state()
    _set_problem_state()

    assert(not _is_problem_solved(), "generated problem was already solved")

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
            _desktop.power_state = Desktop.Power.ON
        ProblemType.MONITOR_OFF:
            _monitor.power_state = Monitor.Power.OFF

func _is_problem_solved() -> bool:
    if _desktop.power_state == Desktop.Power.OFF:
        # For now, all problem states require the PC to be on
        return false

    match current_problem.type:
        ProblemType.CD_STUCK:
            return _desktop.cd_inserted
        ProblemType.FLOPPY_STUCK:
            return _desktop.floppy_inserted
        ProblemType.PC_OFF, ProblemType.BRIGHTNESS_LOW, ProblemType.MONITOR_OFF:
            return _monitor.power_state == Monitor.Power.ON and _monitor.brightness > - 0.3
        ProblemType.BRIGHTNESS_HIGH:
            return _monitor.brightness < 0.3

    return false

func _process(_delta):
    if Input.is_action_just_pressed("add_problem") and OS.is_debug_build():
        _randomize_state()
        current_problem = Problem.new()

    if Input.is_action_just_pressed("clear_problems") and OS.is_debug_build():
        current_problem = null

    # lol, checking every frame is probably not ideal
    if current_problem != null and _is_problem_solved():
        current_problem = null
        # also this would probably be better off as a
        await $DialoguePanel.visibility_changed
        await get_tree().create_timer(transition_time).timeout
        $SceneTransition.transition()
