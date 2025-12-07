extends Area3D

signal player_entered_chunk(chunk_x: int, chunk_z: int)

var chunk_index_x
var chunk_index_z

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		print("Player entered chunk: [", chunk_index_x, ", ", chunk_index_z, "]")
		player_entered_chunk.emit(chunk_index_x, chunk_index_z)
