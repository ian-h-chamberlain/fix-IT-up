extends Control
class_name Main

signal describe_problem(problem: Array[Problem])

var current_problems: Array[Problem] = []
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
	var problem_type: ProblemType

	var dialogue_text: String:
		get:
			return "I've been having some problems with my computer. %s" % self._problem_str()

	func _init():
		self.problem_type = _rande(ProblemType)

	func _to_string() -> String:
		return ProblemType.find_key(self.component)

	func _rande(enum_dict):
		return enum_dict[enum_dict.keys().pick_random()]

	func _problem_str() -> String:
		match self.problem_type:
			ProblemType.CD_STUCK:
				return [
					"I keep seeing an error"
				].pick_random()

		return ""

func _ready():
	pass

func _process(_delta):
	if Input.is_action_just_pressed("add_problem"):
		current_problems.append(Problem.new())
		describe_problem.emit(current_problems)

	if Input.is_action_just_pressed("clear_problems"):
		current_problems = []
		describe_problem.emit(current_problems)
