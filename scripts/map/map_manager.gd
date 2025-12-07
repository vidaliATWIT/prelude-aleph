extends Node

@onready var player = %PlayerCharacter
# Stores visible chunks from 0,0, to 2,2
# Center is @ 1,1
var visible_chunks: Dictionary[Vector2, Node3D]
# Stores all created chunks, dynamically expands in either direction
# Center is @ 0,0
var created_chunks: Dictionary[Vector2, Node3D]
# Current center chunk in 3x3 grid of visible chunks
@export var terrain_chunk: PackedScene
var home_chunk: PackedScene
@export var chunk_size: float
# Practically half of a chunk
var half_chunk = 73.0
# Center index
var center_pos: Vector3 = Vector3(0, 0, 0)


# Pseudocode for trivial map gen
'''
1) Set a home chunk at world origin
2) Create all surrounding chunks and store into created chunks and visible chunks
'''

# On start, create a new map
func _ready():
	generate_chunks_around_center(0,0)
		
func generate_chunks_around_center(center_x: int, center_z: int):
	print("cx and cz: ", center_x, " ", center_z)
	var row = center_x - 1
	var col = center_z - 1
	var end_row = center_x + 2
	var end_col = center_z + 2
	
	while row < end_row:
		col = center_z - 1
		while col < end_col:
			var chunk_key = Vector2(row, col)
			
			# Skip if chunk already exists
			if created_chunks.has(chunk_key):
				print("Chunk [", row, ", ", col, "] already exists, skipping")
				col += 1
				continue
			
			var x = row * chunk_size
			var y = col * chunk_size
			print("row,col: " + str(row) + " " + str(col))
			print("x,y: " + str(x) + " " + str(y))
			var instance = terrain_chunk.instantiate()
			add_child(instance)
			instance.global_position = Vector3(x, 0, y)
			# Wire the signals
			var area3d = instance.get_node("ChunkArea")
			area3d.chunk_index_x = row
			area3d.chunk_index_z = col
			area3d.player_entered_chunk.connect(_on_player_entered_chunk)
			
			
			# Add to created chunks dictionary
			created_chunks[chunk_key] = instance
			
			col += 1
		row += 1
	
func _on_terrain_body_entered(body: Node3D) -> void:
	pass
			
func _on_terrain_body_exited(body: Node3D) -> void:
	pass
		
func _on_player_entered_chunk(chunk_x: int, chunk_z: int) -> void:
	print("MapManager received: Player in chunk [", chunk_x, ", ", chunk_z, "]")
	center_pos.x=chunk_x
	center_pos.z=chunk_z
	generate_chunks_around_center(chunk_x, chunk_z)
	
	# Manage chunk visibility
	update_chunk_visibility()
func update_chunk_visibility():
	for chunk_pos in created_chunks.keys():
		var chunk_instance = created_chunks[chunk_pos]
		var distance_x = abs(chunk_pos.x - center_pos.x)
		var distance_z = abs(chunk_pos.y - center_pos.z)
		
		if distance_x <= 1 and distance_z <= 1:
			if not chunk_instance.is_inside_tree():
				add_child(chunk_instance)
				print("Loaded chunk [", chunk_pos.x, ", ", chunk_pos.y, "]")
		else:
			# Unload if in scene
			if chunk_instance.is_inside_tree():
				remove_child(chunk_instance)
				print("Unloaded chunk [", chunk_pos.x, ", ", chunk_pos.y, "]")
