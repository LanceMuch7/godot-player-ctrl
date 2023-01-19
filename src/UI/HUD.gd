extends Control

signal MenuClosed

##		Constants				################################################
##		Variables				################################################

##		Built-in Functions		################################################
func _ready():
	pass


##		Public Functions		################################################
func OpenMenu(path : String) -> void:
	var menu = get_node_or_null(path)
	
	if menu:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		get_parent().Movement_Enabled = false
		menu.visible = true

func CloseMenu(path : String) -> void:
	var menu = get_node_or_null(path)
	if menu:
		_on_Exit_pressed(menu)

func SetCursorHint(newMessage:String):
	$Center/Cursor/Tooltip.text = newMessage
	$Center/Cursor/Tooltip/AnimationPlayer.play("TooltipSwipe")

func ClearCursorHint():
	$Center/Cursor/Tooltip.text = ""
	$Center/Cursor/Tooltip/AnimationPlayer.play("TipSwipeEnd")


##		Private Functions		################################################
func _countTypes(partsList:Dictionary) -> int:
	var sum = 0
	
	for idx in partsList:
		sum += 1
	return sum

func _on_Exit_pressed(menu : Control):
	menu.visible = false
	get_parent().Movement_Enabled = true
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	emit_signal("MenuClosed", get_parent())
