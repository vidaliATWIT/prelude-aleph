class_name Gun
extends Node3D
var player
var damage = 3
@onready var gun_model = %SAA4
func _ready():
	player = get_node("/root/main/PlayerCharacter")
	max_sway = .2
@export var shooting_range: float = 1000.0
var shoot_direction: Vector3 = Vector3.FORWARD
var swayed_direction = shoot_direction
@export var is_aiming = false
@export var max_sway = .2
var sway = max_sway

func _process(_delta: float) -> void:
	if (not player.is_aiming()):
		sway=max_sway

func _aim():
	var ray_start = global_position
	calculate_swayed_direction()
	var ray_end = ray_start + swayed_direction  * shooting_range
	
	#ddraw_debug_line(ray_start, ray_end, Color.GREEN) 

func _shoot():
	var space_state = get_world_3d().direct_space_state
	var ray_start = global_position
	calculate_swayed_direction()
	var ray_end = ray_start + swayed_direction  * shooting_range
	
	var query = PhysicsRayQueryParameters3D.create(ray_start, ray_end)
	var result = space_state.intersect_ray(query)
	
	# Draw the ray
	if result:
		print(result)
		print(query)
		#draw_debug_line(ray_start, result.position, Color.RED)  # Hit something
		var hit_object = result.collider
		print(hit_object)
		if hit_object.has_method("_on_hit"):
			hit_object._on_hit(damage)
	##else:
		#draw_debug_line(ray_start, ray_end, Color.BLUE)  # Missed
	
	if result:
		print("Hit: ", result.collider.name)
	sway=max_sway
		
func calculate_swayed_direction():
	var local_sway = randf()*sway
	swayed_direction = Vector3(shoot_direction.x+local_sway, shoot_direction.y, shoot_direction.z+local_sway)
	if gun_model:
		gun_model.rotation_degrees.x = local_sway * 100  # Adjust multiplier for desired shake intensity
		gun_model.rotation_degrees.z = local_sway * 100

func _on_facing_direction_changed(new_direction: Vector3):
	shoot_direction = new_direction

func draw_debug_line(start: Vector3, end: Vector3, color: Color):
	var immediate_mesh = ImmediateMesh.new()
	var material = StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = color
	
	immediate_mesh.surface_begin(Mesh.PRIMITIVE_LINES, material)
	immediate_mesh.surface_add_vertex(start)
	immediate_mesh.surface_add_vertex(end)
	immediate_mesh.surface_end()
	
	var mesh_instance = MeshInstance3D.new()
	mesh_instance.mesh = immediate_mesh
	get_tree().root.add_child(mesh_instance)
	
	# Auto-remove after 0.1 seconds
	await get_tree().create_timer(0.1).timeout
	mesh_instance.queue_free()


func _on_sway_timer_timeout() -> void:
	if (player.is_aiming()):
		sway = max(sway-.1, 0.0)
	else:
		sway=max_sway
