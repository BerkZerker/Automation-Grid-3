extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const GRAVITY = 9.8
const MOUSE_SENSITIVITY = 0.002

@onready var camera = $Camera3D
@onready var sync = $MultiplayerSynchronizer
var ray: RayCast3D

func _enter_tree():
	set_multiplayer_authority(name.to_int())

func _ready():
	if is_multiplayer_authority():
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		camera.current = true
		position = Vector3(0, 50, 0) # Spawn high
		
		# Setup Raycast
		ray = RayCast3D.new()
		camera.add_child(ray)
		ray.target_position = Vector3(0, 0, -10)
		ray.enabled = true
	
	# Setup replication if not done in editor
	var config = SceneReplicationConfig.new()
	config.add_property(".:position")
	config.add_property(".:rotation")
	sync.replication_config = config

func _physics_process(delta):
	if not is_multiplayer_authority():
		return

	if not is_on_floor():
		velocity.y -= GRAVITY * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()

func _unhandled_input(event):
	if not is_multiplayer_authority():
		return

	if event.is_action_pressed("ui_cancel"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * MOUSE_SENSITIVITY)
		camera.rotate_x(-event.relative.y * MOUSE_SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-89), deg_to_rad(89))

	if event.is_action_pressed("build"): # Space or Enter usually, but let's use Click if mapped, or define 'fire'
		# For MVP let's use 'ui_accept' (Space) for jump, so we need a build key.
		# Let's assume 'ui_focus_next' (Tab) or just check Mouse Button.
		pass
		
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if ray.is_colliding():
			var point = ray.get_collision_point()
			var norm = ray.get_collision_normal()
			# Place ON the face
			var place_pos = point + norm * 0.5
			var grid_pos = Vector3i(floor(place_pos.x), floor(place_pos.y), floor(place_pos.z))
			
			# Call RPC on GameWorld. GameWorld is 2 levels up (Player -> Players -> GameWorld)
			# Or use group.
			var world = get_node("/root/GameWorld") # Absolute path might fail if scene name changes
			if not world:
				world = get_node("../..")
			
			if world.has_method("request_place_building"):
				world.request_place_building.rpc_id(1, grid_pos, "base")
