extends Node2D

@export var player_scene: PackedScene
@export var asteroid_scene: PackedScene

@onready var asteroids: Node2D = $Asteroids
@onready var wave_label: Label = $UI/WaveLabel
@onready var score_label: Label = $UI/ScoreLabel
@onready var lives_label: Label = $UI/LivesLabel

var player: Node2D
var current_wave := 1
var asteroids_remaining := 0
var is_wave_starting := false
var score := 0

func _ready() -> void:
	spawn_player()
	start_wave()

func spawn_player():
	player = player_scene.instantiate()
	player.global_position = get_viewport_rect().size / 2
	add_child(player)
	player.player_death.connect(_on_player_death)
	player.game_over.connect(_on_game_over)

func spawn_child_asteroid(size: Asteroid.AsteroidSize, pos: Vector2):
	var dir = Vector2.RIGHT.rotated(randf() * TAU)
	spawn_asteroid(size, pos, dir, true)

func spawn_asteroid(size: Asteroid.AsteroidSize, pos: Vector2, dir: Vector2, allow_wrap: bool):
	var asteroid = asteroid_scene.instantiate()
	asteroids.add_child(asteroid)
	asteroid.allow_screen_wrap = allow_wrap
	asteroid.initialize(size, pos, dir)
	asteroid.request_spawn.connect(spawn_child_asteroid)
	asteroid.destroyed.connect(_on_asteroid_destroyed)
	asteroids_remaining += 1

func start_wave():
	is_wave_starting = true
	await show_wave_ui()
	start_wave_spawning()

func show_wave_ui():
	wave_label.text = "WAVE %d" % current_wave
	wave_label.visible = true
	await get_tree().create_timer(1.5).timeout
	wave_label.visible = false

func start_wave_spawning():
	var asteroids_to_spawn = current_wave + 1
	is_wave_starting = false
	for i in asteroids_to_spawn:
		var pos = get_random_offscreen_spawn_position()
		var dir = get_offscreen_velocity_direction(pos)
		spawn_asteroid(Asteroid.AsteroidSize.LARGE, pos, dir, false)
		await get_tree().create_timer(1).timeout

func get_random_offscreen_spawn_position() -> Vector2:
	var viewport_size = get_viewport_rect().size
	var buffer = 40
	var spawn_point
	var side = randi() % 4
	match side:
		0: # left
			spawn_point = Vector2(-buffer, randf_range(0, viewport_size.y))
		1: # right
			spawn_point = Vector2(viewport_size.x + buffer, randf_range(0, viewport_size.y))
		2: # top
			spawn_point = Vector2(randf_range(0, viewport_size.x), -buffer)
		3: # bottom
			spawn_point = Vector2(randf_range(0, viewport_size.x), viewport_size.y + buffer)
	return  spawn_point

func get_offscreen_velocity_direction(pos: Vector2) -> Vector2:
	var center = get_viewport_rect().size * 0.5
	var direction = (center - pos).normalized()
	var angle_variance = deg_to_rad(25)
	return direction.rotated(randf_range(-angle_variance, angle_variance))

func _on_asteroid_destroyed(size: Asteroid.AsteroidSize):
	match size:
		Asteroid.AsteroidSize.LARGE:
			score += 20
		Asteroid.AsteroidSize.MEDIUM:
			score += 30
		Asteroid.AsteroidSize.SMALL:
			score += 50
	score_label.text = "%d" % score
	asteroids_remaining -= 1
	if asteroids_remaining <= 0:
		call_deferred("wave_complete")

func wave_complete():
	wave_label.text = "WAVE COMPLETE!"
	wave_label.visible = true
	await get_tree().create_timer(1.5).timeout
	wave_label.visible = false
	await get_tree().create_timer(1).timeout
	current_wave += 1
	start_wave()

func _on_player_death(lives: int):
	lives_label.text = "LIVES: %d" % lives

func _on_game_over():
	wave_label.text = "GAME OVER"
	wave_label.visible = true
