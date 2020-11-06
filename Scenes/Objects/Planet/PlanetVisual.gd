tool
extends Spatial

export var radius : float = 1.0
export var noise : OpenSimplexNoise = OpenSimplexNoise.new()
export var elevation_curve : Curve = Curve.new()
export var elevation : float = 0.2
export var regenerate : bool = false setget set_regenerate


# Called when the node enters the scene tree for the first time.
func set_regenerate(value : bool):
	if value == true:
		#self.index_mesh()
		self.generate()

func get_normalized_elevation(point : Vector3) -> float:
	return elevation_curve.interpolate((noise.get_noise_3dv(point*radius) + 1)/2)

func index_mesh():
	var base_mesh : ArrayMesh = load("res://Resources/Meshes/PlanetBase.mesh")
	var surface_tool := SurfaceTool.new()
	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	surface_tool.add_smooth_group(true)
	surface_tool.append_from(base_mesh, 0, Transform.IDENTITY)
	surface_tool.index()
	base_mesh = surface_tool.commit()
	ResourceSaver.save("res://Resources/Meshes/PlanetBase.mesh", base_mesh)
	

func generate():
	var base_mesh : ArrayMesh = load("res://Resources/Meshes/PlanetBase.mesh")
	var ocean := MeshDataTool.new()
	ocean.create_from_surface(base_mesh, 0)
	var planet := MeshDataTool.new()
	planet.create_from_surface(base_mesh, 0)
	
	for i in planet.get_vertex_count():
		var vertex = planet.get_vertex(i).normalized()
		var normalized_elevation := get_normalized_elevation(vertex)
		planet.set_vertex(i, vertex*(radius + elevation*(2*normalized_elevation - 1)))
		ocean.set_vertex_color(i, Color(normalized_elevation, normalized_elevation, normalized_elevation))
	
	var planet_mesh := ArrayMesh.new()
	var ocean_mesh := ArrayMesh.new()
	planet.commit_to_surface(planet_mesh)
	ocean.commit_to_surface(ocean_mesh)
	
	var planet_surface := SurfaceTool.new()
	planet_surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	planet_surface.add_smooth_group(true)
	planet_surface.append_from(planet_mesh, 0, Transform.IDENTITY)
#	planet_surface.index()
	planet_surface.generate_normals()
#	planet_surface.generate_tangents()
	planet_mesh = planet_surface.commit()
	$Planet.mesh = planet_mesh
	$Ocean.mesh = ocean_mesh
	pass

