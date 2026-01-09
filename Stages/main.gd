extends Node2D

@export var player_scene: PackedScene
@export var asteroid_scene: PackedScene

@onready var asteroids: Node2D = $Asteroids

var player: Node2D
var current_wave := 1
var asteroids_remaining := 0

func _ready() -> void:
	spawn_player()
	start_wave()

func spawn_player():
	player = player_scene.instantiate()
	player.global_position = get_viewport_rect().size / 2
	add_child(player)

func spawn_asteroid(size: Asteroid.AsteroidSize, pos: Vector2):
	var asteroid = asteroid_scene.instantiate()
	asteroids.add_child(asteroid)
	asteroid.initialize(size, pos)
	asteroid.request_spawn.connect(spawn_asteroid)
	asteroid.destroyed.connect(_on_asteroid_destroyed)
	asteroids_remaining += 1
	print("Asteroids Remaining: ", asteroids_remaining)

func start_wave():
	var asteroids_to_spawn = current_wave + 2
	
	for i in asteroids_to_spawn:
		spawn_asteroid(
			Asteroid.AsteroidSize.LARGE,
			get_random_spawn_position()
		)

func get_random_spawn_position() -> Vector2:
	var viewport_size = get_viewport_rect().size
	var spawn_point = Vector2(
		randf_range(0, viewport_size.x),
		randf_range(0, viewport_size.y)
	)
	return  spawn_point

func _on_asteroid_destroyed():
	asteroids_remaining -= 1
	print("Asteroids Remaining: ", asteroids_remaining)
	if asteroids_remaining <= 0:
		call_deferred("start_next_wave")

func start_next_wave():
	current_wave += 1
	start_wave()
