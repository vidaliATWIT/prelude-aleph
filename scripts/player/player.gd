extends CharacterBody3D 
@export var WALK_SPEED = 8.0
@export var RUN_SPEED = 10.0
var speed = WALK_SPEED
const WALK_STEP_SIZE=0.4
const RUN_STEP_SIZE=0.8

@onready var meshes = $Meshes  # Reference to your Meshes node
@onready var weapon = $Gun
@onready var SFXPlayer = $PlayerSFX
@onready var camera = $GameCamera
@onready var trapped_timer = $TrappedTimer
@onready var sprint_timer = $SprintTimer
@onready var fatigue_timer = $FatigueTimer
@onready var ammo_model = $Gun/SAA4/AmmoParent

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
# Stats
@export var max_hp = 10
@export var max_ammo = 12
@export var max_sway = 12
@export var max_fatigue = 10

@export var show_debug = false
@onready var can_move=true
@onready var can_sprint=true
@onready var is_sprinting=false
@onready var blood_splash = $VFX/Blood


var hp = max_hp:
	set(value):
		hp = value
		health_changed.emit()
var ammo = max_ammo:
	set(value):
		ammo = value
		ammo_changed.emit(max_ammo-ammo)
var fatigue = max_fatigue:
	set(value):
		fatigue=value
		fatigue_changed.emit()
var sway = max_sway
var has_ammo = ammo>0
# signals
signal health_changed
signal ammo_changed
signal fatigue_changed
signal player_died
signal player_trapped
signal player_freed

var aiming=false

func _ready() -> void:
	hp=max_hp
	facing_direction_changed.connect(weapon._on_facing_direction_changed)
	ammo_changed.connect(weapon._on_ammo_changed)
	SFXPlayer.updateStepTime(WALK_STEP_SIZE)
	add_to_group("player")
# Physics update
func _physics_process(delta: float) -> void:
	var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	# Handle sprinting
	if (is_sprinting and can_sprint):
		if sprint_timer.is_stopped():
			fatigue_timer.stop()
			sprint_timer.start()
		speed=RUN_SPEED
		SFXPlayer.updateStepTime(WALK_STEP_SIZE)
	else:
		if fatigue<max_fatigue and fatigue_timer.is_stopped():
			sprint_timer.stop()
			fatigue_timer.start()
		speed=WALK_SPEED
		SFXPlayer.updateStepTime(RUN_STEP_SIZE)
	if (can_move):
		velocity = Vector3(direction.x, 0, direction.y) * speed
	else:
		velocity = Vector3(0, 0, 0)
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
				
	if Input.is_action_pressed("sprint"):
		is_sprinting=true
	else:
		is_sprinting=false
			
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
	blood_splash.emitting=true
	if hp<=0:
		die()
	else:
		SFXPlayer.playDamage()
		camera_shake()
	

func camera_shake():
	var shake_strength = 0.075
	var shake_duration = 0.2
	var shake_interval = 0.05
	
	var original_position = camera.position
	var elapsed = 0.0
	
	while elapsed < shake_duration:
		camera.position = original_position + Vector3(
			randf_range(-shake_strength, shake_strength),
			randf_range(-shake_strength, shake_strength),
			randf_range(-shake_strength, shake_strength)
		)
		await get_tree().create_timer(shake_interval).timeout
		elapsed += shake_interval
	
	camera.position = original_position

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
	aiming=player_state==State.AIMING
	return player_state==State.AIMING
	
func stop_movement(rand_num):
	player_trapped.emit()
	SFXPlayer.playTrapped()
	trapped_timer.wait_time=rand_num*.01
	can_move=false
	can_sprint=false
	trapped_timer.start()
	

func _aim():
	pass
func _shoot():
	pass
func _move():
	pass


func _on_trapped_timer_timeout() -> void:
	player_freed.emit()
	trapped_timer.stop()
	can_move=true
	print("FREE")

func _on_sprint_timer_timeout() -> void:
	fatigue=max(fatigue-1, 0.0)
	print("Fatigue Increasing: ", fatigue)
	if fatigue<=0:
		SFXPlayer.playBreathing()
		can_sprint=false


func _on_fatigue_timer_timeout() -> void:
	fatigue=min(fatigue+1, max_fatigue)
	print("Fatigue Decreasing: ", fatigue)
	if fatigue>5:
		can_sprint=true
