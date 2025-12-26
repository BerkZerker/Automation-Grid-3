extends Resource
class_name TerrainGenerator

@export var world_seed: int = 0
@export var frequency: float = 0.01
@export var octaves: int = 4

var noise: FastNoiseLite

func setup(_seed: int):
	world_seed = _seed
	noise = FastNoiseLite.new()
	noise.seed = world_seed
	noise.frequency = frequency
	noise.fractal_octaves = octaves
	noise.noise_type = FastNoiseLite.TYPE_PERLIN

func get_height(x: int, z: int) -> int:
	if not noise:
		setup(world_seed)
	# Map -1..1 to something like 0..30
	var val = noise.get_noise_2d(x, z)
	return int((val + 1.0) * 15.0) + 1
