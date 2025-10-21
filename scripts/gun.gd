class_name Gun
extends Node3D
var player
func _ready():
	player = get_node("/root/main/PlayerCharacter")

@export var shooting_range: float = 1000.0
var shoot_direction: Vector3 = Vector3.FORWARD
@export var is_aiming = false

func _process(_delta: float) -> void:
	pass

func _aim():
	var ray_start = global_position
	var ray_end = ray_start + shoot_direction  * shooting_range
	
	draw_debug_line(ray_start, ray_end, Color.GREEN) 

func _shoot():
	var space_state = get_world_3d().direct_space_state
	var ray_start = global_position
	var ray_end = ray_start + shoot_direction  * shooting_range
	
	var query = PhysicsRayQueryParameters3D.create(ray_start, ray_end)
	var result = space_state.intersect_ray(query)
	
	# Draw the ray
	if result:
		draw_debug_line(ray_start, result.position, Color.RED)  # Hit something
	else:
		draw_debug_line(ray_start, ray_end, Color.BLUE)  # Missed
	
	if result:
		print("Hit: ", result.collider.name)

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
