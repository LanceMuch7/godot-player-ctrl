extends Node
class_name Health

export var godmode = false
export var dead = false
export (float) var max_health = 100
export (float) var health = 100

signal died
signal health_changed


####	Builtin Functions		################################################
####	Public Functions		################################################
func Damage(amount:float):
	if dead or (godmode and amount > 0): return
	var delta = health - clamp(health - amount, -0.01, max_health)
	
	health -= delta
	emit_signal("health_changed", self, delta)
	if health - delta <= 0:
		dead = true
		emit_signal("died", self)

func Reset():
	health = max_health
	dead = false
	emit_signal("health_changed", self, max_health)


####	Private Functions		################################################
