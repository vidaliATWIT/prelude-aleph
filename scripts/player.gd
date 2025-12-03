extends CharacterBody3D 
const SPEED = 5.0

@onready var meshes = $Meshes  # Reference to your Meshes node
@onready var weapon = $Gun
@onready var SFXPlayer = $PlayerSFX
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
@export var max_hp = 10
@export var max_ammo = 12
@export var max_sway = 12

var hp = max_hp:
	set(value):
		hp = value
		health_changed.emit()
var ammo = max_ammo:
	set(value):
		ammo = value
		ammo_changed.emit()
var sway = max_sway
var has_ammo = ammo>0
# signals
signal health_changed
signal ammo_changed
signal player_died

func _ready() -> void:
	hp=max_hp
	facing_direction_changed.connect(weapon._on_facing_direction_changed)
	add_to_group("player")
# Physics update
func _physics_process(delta: float) -> void:
	var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = Vector3(direction.x, 0, direction.y) * 10
	if (velocity.x!=0 or velocity.z!=0):
		player_state=State.MOVING
		SFXPlayer.startStepTimer()
	else:
		player_state=State.IDLE
		SFXPlayer.stopStepTimer()
	move_and_slide()
	
	
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
			if (has_ammo):
				player_state=State.SHOOTING
				weapon._shoot()
				reduce_ammo()
				SFXPlayer.playShot()
			else:
				SFXPlayer.playDryfire()
				
			
			
func heal(heal_amt):
	hp=min((hp+heal_amt), max_hp)
	SFXPlayer.playHeal()

func increase_ammo(ammo_amt):
	ammo = min(ammo+ammo_amt, max_ammo)
	has_ammo=true
	SFXPlayer.playReload() 

func take_damage(damage):
	print("took damage: ", damage)
	hp = hp-damage
	if hp<=0:
		die()
	else:
		SFXPlayer.playDamage()

func reduce_ammo():
	if has_ammo:
		ammo = ammo -1
		if ammo<=0:
			has_ammo=false
		

func die():
	player_died.emit()
	set_physics_process(false)
	set_process_input(false)	
	
func is_aiming():
	return player_state==State.AIMING

func _aim():
	pass
func _shoot():
	pass
func _move():
	pass
