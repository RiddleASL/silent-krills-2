extends CharacterBody3D
# moon smells

@export var walkSpeed := 500
@export var runSpeed := 800
@export var sensitivity := 0.001
@onready var firstPersonCamera := $Camera_FP_Root/Camera_FP
@onready var thirdPersonCamera := $SpringArm3D/Node3D/Camera_TP
@onready var thirdPersonCameraRoot := $SpringArm3D # third person camera root
@onready var firstPersonCameraRoot := $Camera_FP_Root
@onready var GFX := $GFX

var LERP_SLOW := 0.1
var SPEED
var dir: Vector2
var isFirstPerson

func _ready():
	SPEED = walkSpeed
	isFirstPerson = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(delta: float):
	if isFirstPerson:
		dir = Input.get_vector("left", "right", "forward", "backward").normalized().rotated(-firstPersonCamera.global_rotation.y)
	else: # third person direction
		dir = Input.get_vector("left", "right", "forward", "backward").normalized().rotated(-thirdPersonCameraRoot.rotation.y)
	velocity.x = lerp(velocity.x, dir.x * SPEED * delta, LERP_SLOW)
	velocity.z = lerp(velocity.z, dir.y * SPEED * delta, LERP_SLOW)
	move_and_slide()
	
	handleGFXRot()

func _input(event: InputEvent):
	if event is InputEventMouseMotion:
		if isFirstPerson:
			firstPersonCameraRoot.rotation.y += -event.relative.x * sensitivity
			firstPersonCamera.rotation.x += -event.relative.y * sensitivity
			firstPersonCamera.rotation.x = clamp(firstPersonCamera.rotation.x, deg_to_rad(-90), deg_to_rad(90))
		else:
			thirdPersonCameraRoot.rotation.y += -event.relative.x * sensitivity
			thirdPersonCameraRoot.rotation.x += -event.relative.y * sensitivity
			thirdPersonCameraRoot.rotation.x = clamp(thirdPersonCameraRoot.rotation.x, deg_to_rad(-45), deg_to_rad(45))
	
	if Input.is_action_just_pressed("view"): # swap cameras
		isFirstPerson = !isFirstPerson
		firstToThirdPerson()

func handleGFXRot():
	#var lookDir = position + Vector3(dir.x, 0, dir.y)
	#var angle = dir.angle()
	if dir.length() > .1:
		#GFX.rotation.y = lerp(GFX.rotation.y, thirdPersonCameraRoot.rotation.y, LERP_SLOW/2)
		#GFX.look_at(lookDir)
		GFX.rotation.y = lerp_angle(GFX.rotation.y,atan2(-dir.x, -dir.y), LERP_SLOW/2)

func firstToThirdPerson():
	if isFirstPerson:
		firstPersonCamera.current = true
	else:
		thirdPersonCamera.current = true
