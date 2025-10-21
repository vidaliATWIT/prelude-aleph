extends CharacterBody3D 
const SPEED = 5.0

@onready var meshes = $Meshes  # Reference to your Meshes node
@onready var weapon = $Gun
# facing direction
signal facing_direction_changed(new_direction: Vector3)

var facing_direction: Vector3 = Vector3.FORWARD
var last_facing_direction: Vector3 = Vector3.FORWARD
# States
var player_state = State.IDLE
enum State {
	IDLE,
	MOVING,
	AIMING,
	SHOOTING
}

func _ready() -> void:
	facing_direction_changed.connect(weapon._on_facing_direction_changed)
# Physics update
func _physics_process(delta: float) -> void:
	var direction = Input.get_vector("move_down", "move_up", "move_left", "move_right")
	velocity = Vector3(direction.x, 0, direction.y) * 10
	if (velocity.x!=0 or velocity.z!=0):
		player_state=State.MOVING
	else:
		player_state=State.IDLE
	move_and_slide()
	#print(velocity)
	
	
func _process(delta: float) -> void:
	var camera = get_viewport().get_camera_3d()
	if camera == null:
		return
	
	var mouse_pos = get_viewport().get_mouse_position()
	var from = camera.project_ray_origin(mouse_pos)
	var to = from + camera.project_ray_normal(mouse_pos) * 1000
	var plane = Plane(Vector3.UP, global_position.y)
	var intersection = plane.intersects_ray(from, to - from)
	
	if intersection:
		facing_direction = (intersection - global_position).normalized()
		
		# Only emit signal if direction actually changed
		if facing_direction.distance_to(last_facing_direction) > 0.01:  # Small threshold
			facing_direction_changed.emit(facing_direction)
			last_facing_direction = facing_direction
		
		meshes.look_at(intersection, Vector3.UP)
		meshes.rotate_y(PI)
		weapon.look_at(intersection, Vector3.UP)
		weapon.rotate_y(PI)
		_handle_input()

func _handle_input():
	if (player_state!=State.MOVING and player_state!=State.SHOOTING):
		if Input.is_action_pressed("aim"):
			player_state=State.AIMING
			weapon._aim()
		if Input.is_action_just_pressed("shoot") and player_state==State.AIMING:
			player_state=State.SHOOTING
			weapon._shoot()

func _aim():
	pass
func _shoot():
	pass
func _move():
	pass
