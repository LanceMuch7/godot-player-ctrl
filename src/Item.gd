extends Interactible

export (PackedScene) var itemResource


# Return true if the player was able to pick up the item
func Interact(character) -> bool:
	if not visible:
		return false
	var success = false
	visible = false
	
	if .Interact(character):
		success = character.Pickup(self)
		if not success:
			visible = true
	
	return success

func GetHoverTip() -> String:
	return "Take:\n" + HoverTip

# Spawn a physical instance of the item
func createItem():
	pass


func _on_Trigger_body_entered(body):
	.add_touching(body)

func _on_Trigger_body_exited(body):
	.remove_touching(body)
