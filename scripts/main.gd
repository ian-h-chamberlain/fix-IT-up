extends Control
class_name Main

signal describe_problem(problem: Array[Problem])

var current_problems: Array[Problem] = []

enum Comp {
	DESKTOP,
	MONITOR,
	KEYBOARD,
	MOUSE,
	SOFTWARE,
}

enum Monitor {
	BRIGHTNESS_LOW,
	BRIGHTNESS_HIGH,
	POWER_OFF,
	NO_SIGNAL,
	NO_POWER,
}

enum Desktop {
	NO_POWER,
	CD_PROBLEM,
	FLOPPY_PROBLEM,
	HARD_DISK_PROBLEM,
	FAN_PROBLEM,
}

enum Keyboard {
	UNPLUGGED,
	STUCK_KEY,
}

enum Mouse {
	UNPLUGGED,
	STUCK_BALL,
	STUCK_BUTTON,
}

enum Software {
	DISK_FULL,
	MALWARE_INFECTED,
}

class Problem:
	var component: Comp
	var problem_type

	func _init():
		self.component = _rand(Comp)
		match self.component:
			Comp.DESKTOP:
				self.problem_type = _rand(Desktop)
			Comp.MONITOR:
				self.problem_type = _rand(Monitor)
			Comp.KEYBOARD:
				self.problem_type = _rand(Keyboard)
			Comp.MOUSE:
				self.problem_type = _rand(Mouse)
			Comp.SOFTWARE:
				self.problem_type = _rand(Software)

	static func _rand(enu):
		return enu[enu.keys().pick_random()]

	var dialogue_text: String:
		get:
			return "I've been having some problems with the {comp}. ({desc})".format({
				"comp": self._component_str(),
				"desc": self,
			})

	func _to_string() -> String:
		return Comp.find_key(self.component)

	func _component_str() -> String:
		match self.component:
			Comp.DESKTOP: return "tower"
			Comp.MONITOR: return "screen"
			Comp.KEYBOARD: return "keyboard"
			Comp.MOUSE: return "mouse"
			Comp.SOFTWARE: return "applications"

		return ""

func _process(_delta):
	if Input.is_action_just_pressed("add_problem"):
		current_problems.append(Problem.new())
		describe_problem.emit(current_problems)

	if Input.is_action_just_pressed("clear_problems"):
		current_problems = []
		describe_problem.emit(current_problems)
