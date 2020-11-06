extends ImmediateGeometry


export var camera : NodePath;
onready var camera_node : Camera = get_node(camera);

var spawn_positions := Curve3D.new()
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var min_time = 2.0;
var max_time = 4.0;
var min_speed = 6.0;
var max_speed = 8.0;
var wait_time = 5.0;
onready var asteroid_pck = preload("res://Asteroid.tscn")

# Called when the node enters the scene tree for the first time.
func set_spawn_positions():
	var screen_size = get_viewport().size
	var spawn_corners := PoolVector3Array()
	spawn_corners.push_back(camera_node.project_position(Vector2(0, 0), 4) + Vector3(-1, 1, 0))
	spawn_corners.push_back(camera_node.project_position(Vector2(screen_size.x, 0), 4) + Vector3(1, 1, 0))
	spawn_corners.push_back(camera_node.project_position(Vector2(screen_size.x, screen_size.y), 4) + Vector3(1, -1, 0))
	spawn_corners.push_back(camera_node.project_position(Vector2(0, screen_size.y), 4) + Vector3(-1, -1, 0))
	
	self.spawn_positions.clear_points()
	for point in spawn_corners:
		self.spawn_positions.add_point(Vector3(point.x ,point.y, 0))
	self.spawn_positions.add_point(Vector3(spawn_corners[0].x ,spawn_corners[0].y, 0))
	
	self.clear()
	self.begin(Mesh.PRIMITIVE_LINE_LOOP)
	self.set_color(Color.white)
	for vert in spawn_corners:
		self.add_vertex(to_local(Vector3(vert.x ,vert.y, 0)))
	self.end()

func _ready():
	randomize()
	spawn_entities()
	pass # Replace with function body.

func spawn_entities():
	while true:
		print("waiting ", wait_time)
		yield(get_tree().create_timer(wait_time), "timeout")
		set_spawn_positions()
		var speed = lerp(min_speed, max_speed, randf())
		var position := spawn_positions.interpolate_baked(randf()*spawn_positions.get_baked_length())
		var asteroid = asteroid_pck.instance()
		self.add_child(asteroid)
		asteroid.linear_velocity = -position.normalized()*speed
		asteroid.translation = position
		print("spawned at ", position, ", with velocity ", asteroid.linear_velocity)
		wait_time = lerp(min_time, max_time, randf())
