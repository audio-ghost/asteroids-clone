extends Node2D

@export var player_scene: PackedScene
@export var asteroid_scene: PackedScene

@onready var asteroids: Node2D = $Asteroids

var player: Node2D

func _ready() -> void:
	spawn_player()
	spawn_initial_asteroid()

func spawn_player():
	player = player_scene.instantiate()
	player.global_position = get_viewport_rect().size / 2
	add_child(player)

func spawn_asteroid(size: Asteroid.AsteroidSize, pos: Vector2):
	var asteroid = asteroid_scene.instantiate()
	asteroid.size = size
	asteroids.add_child(asteroid)
	asteroid.initialize(pos)
	asteroid.request_spawn.connect(spawn_asteroid)

func spawn_initial_asteroid():
	var asteroid = asteroid_scene.instantiate()
	asteroid.size = Asteroid.AsteroidSize.LARGE
	
	var viewport_size = get_viewport_rect().size
	var spawn_point = Vector2(
		randf_range(0, viewport_size.x),
		randf_range(0, viewport_size.y)
	)
	
	asteroids.add_child(asteroid)
	asteroid.initialize(spawn_point)
	asteroid.request_spawn.connect(spawn_asteroid)
