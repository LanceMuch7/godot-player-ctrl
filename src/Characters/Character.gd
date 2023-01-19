extends Spatial
class_name Character

enum MOOD {
	Neutral,	# 
	Refreshed,	# Slept <= 18 hours ago (+/- char bonus)
	Fatigued,	# hauling limit reached for this shift
	Calm,		# More than ?? hours since last negative state
	Soothed,	# Calm state active for > ?? hours
	Sad,		# within distance/time proximity to a death
	Horrified,	# within proximity to a corpse
	Pained,		# 
	Anxious,	# 
	Satisfied,	# 
	Hungry,		# 
	Thirsty,	# 
	Wounded,	# 
	Angry,		# 
	Dead		# 
}
class StateNode:
	var connections = Array()
	var conditions = Dictionary()
	var name:String

export (MOOD) var mentalState = MOOD.Neutral
var activeStates = {
	"positive": {
		"Refreshed": 	true,	# Slept <= 18 hours ago (+/- char bonus)
		"Calm": 		false,	# More than ?? hours since last negative state
		"Soothed": 		false,	# Calm state active for > ?? hours
		"Satisfied": 	false,	# Ate/drank < 4 hours ago
	},
	"negative": {
		"Fatigued": 	false,	# hauling limit reached for this shift
		"Sad": 			false,	# within distance/time proximity to a death
		"Horrified": 	false,	# within proximity to a corpse
		"Pained": 		false,	# 
		"Anxious": 		false,	# 
		"Hungry": 		false,	# 
		"Thirsty": 		false,	# 
		"Wounded": 		false,	# 
		"Angry": 		false,	# 
	},
}
var stats = {
	"sleep": 0,
	
}


####	Builtin Functions		################################################
####	Public Functions		################################################
####	Private Functions		################################################
func _checkStates():
	match mentalState:
		MOOD.Neutral:
			return
		MOOD.Refreshed:
			if stats.sleep > 18:
				pass
