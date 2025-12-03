extends Node3D
enum PROP {HEALTH,AMMO,TRAP, TREE}
@export var prop_scenes:Array[PackedScene]
@export var prop_spawn_points: Array[Node3D]
@export var jitter_range = 2.0
@export var rotation_range = 360.0
@export var skip_rate = 12
func _ready():
	spawn_props()

# Iterate through spawn points and randomly choose a prop for it
func spawn_props():
	var has_at_least_one_prop = false
	for prop_spawn in prop_spawn_points:
		var rand =  randi()%len(prop_scenes)
		var chance_to_skip = randi()%skip_rate
		if has_at_least_one_prop and chance_to_skip==0:
			pass
		else:
			var prop_scene = prop_scenes[rand]
			var instance = prop_scene.instantiate()
			var jitter_x = (randf_range(-jitter_range, jitter_range))
			var jitter_z = (randf_range(-jitter_range, jitter_range))
			instance.position = prop_spawn.position + Vector3(jitter_x, 0, jitter_z)
			var random_y_rotation = randf_range(0, rotation_range) * deg_to_rad(1)  # Convert to radians
			instance.rotation = Vector3(0, random_y_rotation, 0)  # Set only Y-axis rotation
			add_child(instance)
			has_at_least_one_prop=true
