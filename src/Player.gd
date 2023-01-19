# ORIGINAL SOURCE: Jeremy Bullock, provided under MIT license
extends KinematicBody
class_name Player

##		Class Variables			################################################
export var character : PackedScene
var cameraRay : RayCast
var HUD : Control
var hovering : Spatial
# Camera
const SCREEN_PADDING = 100 # border region for mouse panning
export(float) var mouse_sensitivity = 12.0
export(NodePath) var head_path
export(NodePath) var cam_path
export(float) var height = 0.9
export(float) var FOV = 70.0
export(float) var max_angle = 95.0
var ScreenPadding = Vector2(100, 100)
var mouse_axis := Vector2()
onready var head: Spatial = get_node(head_path)
onready var cam: Camera = get_node(cam_path)
# Move
var Movement_Enabled := true
var velocity := Vector3()
var direction := Vector3()
var move_axis := Vector2()
var can_sprint := true
var sprinting := false
# Walk
const FLOOR_NORMAL := Vector3(0, 1, 0)
const FLOOR_MAX_ANGLE: float = deg2rad(46.0)
export(float) var gravity = 25.0
export(int) var walk_speed = 3
export(int) var sprint_speed = 5
export(int) var acceleration = 8
export(int) var deacceleration = 10
export(float, 0.0, 1.0, 0.05) var air_control = 0.3
export(int) var jump_height = 8
# Fly
export(float) var fly_speed = 10
export(float) var fly_accel = 5
var flying := false
var cam_delta = Vector2()
var camera_angle = 0

var camLimits = [6.0, 0.3] # @TODO: make step size a quadratic increase, not linear


##		Built-in Functions		################################################
# Called when the node enters the scene tree
func _ready() -> void:
	cameraRay = cam.get_node("MouseRay")
	HUD = get_node("HUD")
	_on_screen_changed()
	get_viewport().connect("size_changed", self, "_on_screen_changed")
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	cam.fov = FOV
	SetCharacter()

# Called every frame. 'delta' is the elapsed time since the previous frame
func _process(_delta: float) -> void:
	if not Movement_Enabled:
		var mPos = get_viewport().get_mouse_position()
		var scrSize = get_viewport().size
		
		if mPos.x < ScreenPadding.x:
			mouse_axis.x = mPos.x - ScreenPadding.x
		elif mPos.x > scrSize.x - ScreenPadding.x:
			mouse_axis.x = mPos.x - (scrSize.x - ScreenPadding.x)
			
		if mPos.y < ScreenPadding.y:
			mouse_axis.y = mPos.y - ScreenPadding.y
		elif mPos.y > scrSize.y - ScreenPadding.y:
			mouse_axis.y = mPos.y - (scrSize.y - ScreenPadding.y)
		
		mouse_axis *= _delta
		camera_rotation()
		return
	
	if cameraRay.is_colliding():
		var hoverObj = cameraRay.get_collider()
		var canInteract = hoverObj.visible and hoverObj.has_method("GetHoverTip")
		
		if canInteract and hovering != hoverObj:
			ObjectEntered(hoverObj)
		elif not canInteract and hovering:
			ObjectExited()
	elif hovering:
		ObjectExited()
	
	move_axis.x = Input.get_action_strength("move_forward") - Input.get_action_strength("move_backward")
	move_axis.y = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")

# Called every physics tick. 'delta' is constant
func _physics_process(delta: float) -> void:
	if flying:
		_climb(delta)
	else:
		_walk(delta)

# Called when there is an input event
func _input(event: InputEvent) -> void:
	if Movement_Enabled and event is InputEventMouseMotion:
		mouse_axis = event.relative
		camera_rotation()
	elif Movement_Enabled and event is InputEventMouseButton and event.pressed:
		var colObj = cameraRay.get_collider()
		if colObj and colObj.has_method("Interact"):
			colObj.Interact(self)
	elif event.is_action_pressed("restart"):
		get_tree().reload_current_scene()
	elif event.is_action("scroll_up"):
		head.spring_length = clamp(head.spring_length - camLimits[1], 0.0, camLimits[0])
		head.translation.y = 0.65 + head.spring_length/10.0
	elif event.is_action("scroll_dn"):
		head.spring_length = clamp(head.spring_length + camLimits[1], 0.0, camLimits[0])
		head.translation.y = 0.65 + head.spring_length/10.0


##		Public Functions		################################################
func Pickup(item:Spatial) -> bool:
	return $HUD/Inventory.AddItem(item)

func ObjectEntered(emitter):
	HUD.SetCursorHint(emitter.GetHoverTip())
	hovering = emitter

func ObjectExited():
	HUD.ClearCursorHint()
	hovering = null

func SetCharacter():
#	head.translation.y = height/2
#	$CollisionShape.shape.set_height(height)
	pass


##		Private Functions		################################################
func _walk(delta: float) -> void:
	var aim: Basis = get_global_transform().basis
	
	direction = (aim.x*move_axis.y - aim.z*move_axis.x).normalized()
	
	# Jump
	var _snap: Vector3
	if is_on_floor():
		_snap = Vector3(0, -1, 0)
		if Input.is_action_just_pressed("jump"):
			_snap = Vector3(0, 0, 0)
			velocity.y = jump_height
	else:
		# Apply Gravity
		velocity.y -= gravity * delta
	
	# Sprint
	var _speed:int
	if (Input.is_action_pressed("sprint") and can_sprint and move_axis.x >= 0.5):
		_speed = sprint_speed
		cam.set_fov(lerp(cam.fov, FOV * 1.05, delta * 8))
		sprinting = true
	else:
		_speed = walk_speed
		cam.set_fov(lerp(cam.fov, FOV, delta * 8))
		sprinting = false
	
	# Acceleration and Deacceleration
	# where would the player go
	var temp_vel:Vector3 = velocity
	var temp_accel:float
	
	temp_vel.y = 0
	if direction.dot(temp_vel) > 0:
		temp_accel = acceleration
	else:
		temp_accel = deacceleration
	if not is_on_floor():
		temp_accel *= air_control
	# interpolation
	temp_vel = temp_vel.linear_interpolate(direction*_speed, temp_accel*delta)
	velocity.x = temp_vel.x
	velocity.z = temp_vel.z
	# clamping (to stop on slopes)
	if direction.dot(velocity) == 0:
		var vel_clamp := 0.25
		if abs(velocity.x) < vel_clamp:
			velocity.x = 0
		if abs(velocity.z) < vel_clamp:
			velocity.z = 0
	
	# Move
	var moving = move_and_slide_with_snap(velocity, _snap, FLOOR_NORMAL, true, 4, FLOOR_MAX_ANGLE, false)
	if is_on_wall():
		velocity = moving
	else:
		velocity.y = moving.y

func _climb(delta: float) -> void:
	var aim = head.get_global_transform().basis
	
	direction = (aim.x*move_axis.y - aim.z*move_axis.x).normalized()
	velocity = velocity.linear_interpolate(direction * fly_speed, fly_accel * delta) # Accel & Deaccel
	velocity = move_and_slide(velocity) # Move

# Gets the new screen size, averages the lengths, and uses 1/5 of that.
func _on_screen_changed():
	ScreenPadding = get_viewport().size/5

func camera_rotation() -> void:
#	if Input.get_mouse_mode() != Input.MOUSE_MODE_CAPTURED:
#		return
	if mouse_axis.length() > 0:
		rotate_y(deg2rad(-mouse_axis.x * (mouse_sensitivity / 100.0)))
		head.rotate_x(deg2rad(-mouse_axis.y * (mouse_sensitivity / 100.0)))
		mouse_axis = Vector2()
		
		# Clamp mouse rotation
		if max_angle >= 0:
			head.rotation_degrees.x = clamp(head.rotation_degrees.x, -max_angle, max_angle)

# Handles the character and camera rotations needed to look around
func _aim():
	if cam_delta.length() > 0:
		rotate_y(deg2rad(-cam_delta.x * mouse_sensitivity))
		var d = -cam_delta.y * mouse_sensitivity
		
		if d + camera_angle > -90 and d + camera_angle < 90:
			head.rotate_x(deg2rad(d))
			camera_angle += d
		cam_delta = Vector2()
