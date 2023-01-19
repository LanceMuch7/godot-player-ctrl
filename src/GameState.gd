extends Node

enum DIFFICULTY {
	SimpleLooter,
	MakerLooter,
	MakerExtended,
	Engineer
}

var difficulty = DIFFICULTY.SimpleLooter

const COMP_ICO = {
	"gear": preload("res://assets/Sprites/Items/gear.png"),
	"circuit": preload("res://assets/Sprites/Items/circuits.png"),
	"battery": preload("res://assets/Sprites/Items/battery.png"),
	"wire": preload("res://assets/Sprites/Items/wire.png"),
}

var CurrentScene

