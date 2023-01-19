extends CollisionObject
class_name Interactible

var touching = Array()
export (String) var HoverTip
export (String) var title = "INVALID_OBJ"

func Interact(character) -> bool:
	return touching.has(character.name)

# Getter for other classes to use
func GetHoverTip() -> String:
	return HoverTip

# Add an object to the list of objects in range.
#  Called by child class signal functions
func add_touching(body):
	if not touching.has(body.name):
		touching.append(body.name)

# Remove an object from the list of objects in range.
#  Called by child class signal functions
func remove_touching(body):
	if touching.has(body.name):
		touching.erase(body.name)
