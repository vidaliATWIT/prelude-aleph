extends Node

# Path to your sprite sheet texture
@export var sprite_sheet_path: String = "res://art/cursors/cursor.png"

# Sprite dimensions
const SPRITE_WIDTH = 32
const SPRITE_HEIGHT = 32
const COLUMNS = 20
const ROWS = 6

var sprite_sheet: Texture2D

func _ready():
	sprite_sheet = load(sprite_sheet_path)
	reset_crosshair()

# Load a cursor from the sprite sheet by row and column
func set_cursor_from_sheet(row: int, column: int, hotspot: Vector2 = Vector2.ZERO):
	if row < 0 or row >= ROWS:
		push_error("Row %d out of bounds (0-%d)" % [row, ROWS - 1])
		return
	
	if column < 0 or column >= COLUMNS:
		push_error("Column %d out of bounds (0-%d)" % [column, COLUMNS - 1])
		return
	
	# Create an AtlasTexture to extract the specific sprite
	var atlas = AtlasTexture.new()
	atlas.atlas = sprite_sheet
	
	# Calculate the region for this sprite
	var x = column * SPRITE_WIDTH
	var y = row * SPRITE_HEIGHT
	atlas.region = Rect2(x, y, SPRITE_WIDTH, SPRITE_HEIGHT)
	
	var image = atlas.get_image()
	
	Input.set_custom_mouse_cursor(image, Input.CURSOR_ARROW, hotspot)

# Helper function to get a specific sprite as a Texture2D (useful for other purposes)
func get_sprite_from_sheet(row: int, column: int) -> Texture2D:
	var atlas = AtlasTexture.new()
	atlas.atlas = sprite_sheet
	
	var x = column * SPRITE_WIDTH
	var y = row * SPRITE_HEIGHT
	atlas.region = Rect2(x, y, SPRITE_WIDTH, SPRITE_HEIGHT)
	
	return atlas

func reset_crosshair():
	set_cursor_from_sheet(1, 0)

func update_crosshair(x):
	set_cursor_from_sheet(2,x)
	
