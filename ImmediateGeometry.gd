extends ImmediateGeometry


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var vertices = PoolVector3Array()
var count = 0
var interval = 10

# Called when the node enters the scene tree for the first time.
func _ready():
	vertices.push_back(self.global_transform.origin)
	pass # Replace with function body.


func _process(delta):
	count += 1
	if count >= interval:
		count = 0
		vertices.push_back(self.global_transform.origin)
	self.clear()
	self.begin(Mesh.PRIMITIVE_LINE_STRIP)
	self.set_color(Color.white)
	for vert in vertices:
		self.add_vertex(to_local(vert))
	self.add_vertex(Vector3.ZERO)
	self.end()
		
