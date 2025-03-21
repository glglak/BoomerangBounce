extends Node2D
class_name InfiniteGround

@export var ground_texture: Texture2D
@export var ground_width: float = 540.0
@export var ground_height: float = 120.0
@export var scroll_speed: float = 300.0

var ground_segments: Array = []
var segment_pool: Array = []
var max_segments: int = 4
var segment_count: int = 0
var offset_x: float = 0.0

func _ready() -> void:
	# Create initial ground segments
	for i in range(max_segments):
		var segment = _create_ground_segment()
		segment.position.x = i * ground_width
		ground_segments.append(segment)
		add_child(segment)

func _process(delta: float) -> void:
	# Scroll existing segments
	offset_x += scroll_speed * delta
	
	# If we've scrolled past a segment, recycle it
	if offset_x >= ground_width:
		_recycle_segment()
		offset_x -= ground_width
	
	# Update positions of all segments
	for i in range(ground_segments.size()):
		ground_segments[i].position.x = i * ground_width - offset_x

func _create_ground_segment() -> Node2D:
	# Create a new ground segment
	var segment = Node2D.new()
	
	# Add visual
	var sprite = Sprite2D.new()
	sprite.texture = ground_texture
	sprite.position.y = ground_height / 2
	sprite.scale = Vector2(ground_width / sprite.texture.get_width(), 
	                       ground_height / sprite.texture.get_height())
	segment.add_child(sprite)
	
	# Add collision
	var static_body = StaticBody2D.new()
	static_body.collision_layer = 1  # Layer 1: Ground
	static_body.collision_mask = 0   # Does not detect collisions
	
	var collision_shape = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	shape.size = Vector2(ground_width, ground_height / 2)
	collision_shape.shape = shape
	collision_shape.position.y = ground_height / 4
	
	static_body.add_child(collision_shape)
	segment.add_child(static_body)
	
	return segment

func _recycle_segment() -> void:
	# Move the first segment to the end
	var segment = ground_segments.pop_front()
	ground_segments.push_back(segment)

func set_scroll_speed(speed: float) -> void:
	scroll_speed = speed

func reset() -> void:
	# Reset position of all segments
	offset_x = 0.0
	for i in range(ground_segments.size()):
		ground_segments[i].position.x = i * ground_width
