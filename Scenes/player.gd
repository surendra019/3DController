extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5
@onready var animation_tree = $AnimationTree
@onready var armature = $character/Armature

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	pass

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("left", "right", "forward", "backward")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	direction =  direction.rotated(Vector3.UP, get_tree().get_nodes_in_group('camera_pivot')[0].rotation.y)
	var sprint_factor = 1
	if direction:
		if Input.is_action_pressed("sprint"):
			sprint_factor = 2
		armature.rotation.y = lerp_angle(armature.rotation.y, atan2(velocity.x, velocity.z), 0.15)
		velocity.x = direction.x * SPEED*sprint_factor
		velocity.z = direction.z * SPEED*sprint_factor
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
	handle_animations(input_dir)

func handle_animations(input_dir):
	animation_tree.set("parameters/conditions/idle", input_dir==Vector2.ZERO && is_on_floor() && !Input.is_action_pressed("sprint"))
	animation_tree.set("parameters/conditions/walking", input_dir!=Vector2.ZERO && is_on_floor() && !Input.is_action_pressed("sprint"))
	animation_tree.set("parameters/conditions/jump", Input.is_action_just_pressed("jump"))
	animation_tree.set("parameters/conditions/running", Input.is_action_pressed("sprint") && input_dir!=Vector2.ZERO)
