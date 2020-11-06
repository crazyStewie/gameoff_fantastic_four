tool
extends MeshInstance

export var subdivisions : int = 2

export var regenerate : bool = false setget set_regenerate

func set_regenerate(value : bool):
	if value == true:
		generate()

func generate():
	print("generating")
	var phi : float = (1 + sqrt(5))/2
	var arrays := []
	arrays.resize(ArrayMesh.ARRAY_MAX)
	var vertices : Array = [
		Vector3(0,phi, 1).normalized(),
		Vector3(0,phi, -1).normalized(),
		Vector3(phi,1, 0).normalized(),
		Vector3(-phi,1, 0).normalized(),
		Vector3(1,0, phi).normalized(),
		Vector3(1,0, -phi).normalized(),
		Vector3(-1,0, -phi).normalized(),
		Vector3(-1,0, phi).normalized(),
		Vector3(0,-phi, 1).normalized(),
		Vector3(0,-phi, -1).normalized(),
		Vector3(phi,-1, 0).normalized(),
		Vector3(-phi,-1, 0).normalized(),
	]
	var indices : Array = [
		0, 1, 2,
		0, 3, 1,
		0, 2, 4,
		0, 4, 7,
		0, 7, 3,
		3, 6, 1,
		1, 6, 5,
		1, 5, 2,
		2, 5, 10,
		2, 10, 4,
		3, 11, 6,
		3, 7, 11,
		7, 4, 8,
		4, 10, 8,
		11, 7, 8,
		8, 10, 9,
		8, 9, 11,
		9, 10, 5,
		9, 6, 11,
		9, 5, 6,
	]
	for i in subdivisions:
		subdivide(vertices, indices)
	
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	st.add_smooth_group(true)
	for v in vertices:
		st.add_normal(v.normalized())
		st.add_vertex(v.normalized())
	for i in indices:
		st.add_index(i)
#	st.generate_normals()
	
	if not self.mesh:
		self.mesh = ArrayMesh.new()
	elif self.mesh.get_surface_count():
		self.mesh.surface_remove(0)
	st.generate_normals()
	st.commit(self.mesh)
	pass

func subdivide(vertices : Array, indices : Array):
	var middle_point = []
	middle_point.resize(vertices.size())
	var idx = vertices.size()
	for i in middle_point.size():
		middle_point[i] = []
		middle_point[i].resize(vertices.size())
		for j in middle_point[i].size():
			middle_point[i][j] = 0
	var triangle_count = indices.size()/3
	for tri in triangle_count:
		var a = indices[3*tri]
		var b = indices[3*tri + 1]
		var c = indices[3*tri + 2]
		if not middle_point[a][b]:
			var vertex = (vertices[a] + vertices[b]).normalized()
			middle_point[a][b] = idx;
			middle_point[b][a] = idx;
			vertices.append(vertex)
			idx += 1
		if not middle_point[b][c]:
			var vertex = (vertices[b] + vertices[c]).normalized()
			middle_point[b][c] = idx;
			middle_point[c][b] = idx;
			vertices.append(vertex)
			idx += 1
		if not middle_point[a][c]:
			var vertex = (vertices[a] + vertices[c]).normalized()
			middle_point[a][c] = idx;
			middle_point[c][a] = idx;
			vertices.append(vertex)
			idx += 1
		#corner A:
		indices[3*tri + 1] = middle_point[a][b]
		indices[3*tri + 2] = middle_point[a][c]
		#corner B:
		indices.push_back(middle_point[a][b])
		indices.push_back(b)
		indices.push_back(middle_point[b][c])
		#corner C:
		indices.push_back(middle_point[b][c])
		indices.push_back(c)
		indices.push_back(middle_point[c][a])
		#middle:
		indices.push_back(middle_point[a][b])
		indices.push_back(middle_point[b][c])
		indices.push_back(middle_point[c][a])
	pass
