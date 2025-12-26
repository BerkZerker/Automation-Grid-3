extends MeshInstance3D

const CHUNK_SIZE = 16
var chunk_x: int
var chunk_z: int
var generator: Resource # TerrainGenerator

func init(x: int, z: int, gen: Resource):
	chunk_x = x
	chunk_z = z
	generator = gen
	# Shift position
	position = Vector3(x * CHUNK_SIZE, 0, z * CHUNK_SIZE)

func generate():
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	# Simple material (placeholder) - enable vertex colors
	var mat = StandardMaterial3D.new()
	mat.vertex_color_use_as_albedo = true
	st.set_material(mat)
	
	# Enable shadow casting
	cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON

	for x in range(CHUNK_SIZE):
		for z in range(CHUNK_SIZE):
			var global_x = chunk_x * CHUNK_SIZE + x
			var global_z = chunk_z * CHUNK_SIZE + z
			var h = generator.get_height(global_x, global_z)
			
			# Generate the top block
			_add_cube(st, Vector3(x, h, z))
			
			# Ideally we fill down, but for MVP just the surface
			# If we want to mine, we need data, not just mesh.
			# For now, just surface.

	st.generate_normals()
	mesh = st.commit()
	create_trimesh_collision()

func _add_cube(st: SurfaceTool, pos: Vector3):
	# Top (green like grass)
	st.set_color(Color(0.2, 0.8, 0.2))
	st.set_uv(Vector2(0, 0)); st.add_vertex(pos + Vector3(0, 1, 0))
	st.set_uv(Vector2(1, 0)); st.add_vertex(pos + Vector3(1, 1, 0))
	st.set_uv(Vector2(1, 1)); st.add_vertex(pos + Vector3(1, 1, 1))
	
	st.set_uv(Vector2(0, 0)); st.add_vertex(pos + Vector3(0, 1, 0))
	st.set_uv(Vector2(1, 1)); st.add_vertex(pos + Vector3(1, 1, 1))
	st.set_uv(Vector2(0, 1)); st.add_vertex(pos + Vector3(0, 1, 1))

	# Front (brown like dirt)
	st.set_color(Color(0.55, 0.35, 0.2))
	st.set_uv(Vector2(0, 0)); st.add_vertex(pos + Vector3(0, 0, 1))
	st.set_uv(Vector2(1, 0)); st.add_vertex(pos + Vector3(1, 0, 1))
	st.set_uv(Vector2(1, 1)); st.add_vertex(pos + Vector3(1, 1, 1))
	
	st.set_uv(Vector2(0, 0)); st.add_vertex(pos + Vector3(0, 0, 1))
	st.set_uv(Vector2(1, 1)); st.add_vertex(pos + Vector3(1, 1, 1))
	st.set_uv(Vector2(0, 1)); st.add_vertex(pos + Vector3(0, 1, 1))

	# Right (brown like dirt)
	st.set_color(Color(0.55, 0.35, 0.2))
	st.set_uv(Vector2(0, 0)); st.add_vertex(pos + Vector3(1, 0, 0))
	st.set_uv(Vector2(1, 0)); st.add_vertex(pos + Vector3(1, 0, 1))
	st.set_uv(Vector2(1, 1)); st.add_vertex(pos + Vector3(1, 1, 1))
	
	st.set_uv(Vector2(0, 0)); st.add_vertex(pos + Vector3(1, 0, 0))
	st.set_uv(Vector2(1, 1)); st.add_vertex(pos + Vector3(1, 1, 1))
	st.set_uv(Vector2(0, 1)); st.add_vertex(pos + Vector3(1, 1, 0))

	# Back (brown like dirt)
	st.set_color(Color(0.55, 0.35, 0.2))
	st.set_uv(Vector2(0, 0)); st.add_vertex(pos + Vector3(0, 0, 0))
	st.set_uv(Vector2(1, 0)); st.add_vertex(pos + Vector3(1, 0, 0))
	st.set_uv(Vector2(1, 1)); st.add_vertex(pos + Vector3(1, 1, 0))
	
	st.set_uv(Vector2(0, 0)); st.add_vertex(pos + Vector3(0, 0, 0))
	st.set_uv(Vector2(1, 1)); st.add_vertex(pos + Vector3(1, 1, 0))
	st.set_uv(Vector2(0, 1)); st.add_vertex(pos + Vector3(0, 1, 0))
	
	# Left (brown like dirt)
	st.set_color(Color(0.55, 0.35, 0.2))
	st.set_uv(Vector2(0, 0)); st.add_vertex(pos + Vector3(0, 0, 1))
	st.set_uv(Vector2(1, 0)); st.add_vertex(pos + Vector3(0, 0, 0))
	st.set_uv(Vector2(1, 1)); st.add_vertex(pos + Vector3(0, 1, 0))
	
	st.set_uv(Vector2(0, 0)); st.add_vertex(pos + Vector3(0, 0, 1))
	st.set_uv(Vector2(1, 1)); st.add_vertex(pos + Vector3(0, 1, 0))
	st.set_uv(Vector2(0, 1)); st.add_vertex(pos + Vector3(0, 1, 1))

	# Bottom (brown like dirt)
	st.set_color(Color(0.45, 0.3, 0.15))
	st.set_uv(Vector2(0, 0)); st.add_vertex(pos + Vector3(0, 0, 0))
	st.set_uv(Vector2(1, 0)); st.add_vertex(pos + Vector3(1, 0, 0))
	st.set_uv(Vector2(1, 1)); st.add_vertex(pos + Vector3(1, 0, 1))

	st.set_uv(Vector2(0, 0)); st.add_vertex(pos + Vector3(0, 0, 0))
	st.set_uv(Vector2(1, 1)); st.add_vertex(pos + Vector3(1, 0, 1))
	st.set_uv(Vector2(0, 1)); st.add_vertex(pos + Vector3(0, 0, 1))
