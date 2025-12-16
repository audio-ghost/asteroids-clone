class_name Asteroid extends CharacterBody2D

enum AsteroidSize {
	SMALL,
	MEDIUM,
	LARGE
}

const SPEED_RANGES := {
	AsteroidSize.LARGE: Vector2(25, 50),
	AsteroidSize.MEDIUM: Vector2(50, 100),
	AsteroidSize.SMALL: Vector2(100, 200)
}

@export var size := AsteroidSize.LARGE
@export var rotation_speed := 25
@export var rotation_direction := CLOCKWISE

signal request_spawn(size: AsteroidSize, position: Vector2)

func _on_ready() -> void:
	initialize(Vector2.ZERO)

func _physics_process(delta: float) -> void:
	pass
	#Get it rotating. Random speed. Random direction.

func initialize(start_position: Vector2) -> void:
	global_position = start_position
	
	var dir = Vector2.RIGHT.rotated(randf() * TAU)
	var s_range = SPEED_RANGES[size]
	var speed = randf_range(s_range.x, s_range.y)
	velocity = speed * dir
	
	generate_shape()

func generate_shape():
	pass

func destroy():
	match size:
		AsteroidSize.LARGE:
			spawn_children(AsteroidSize.MEDIUM, randi_range(2, 3))
			spawn_children(AsteroidSize.SMALL, randi_range(0, 2))
		AsteroidSize.MEDIUM:
			spawn_children(AsteroidSize.SMALL, randi_range(3, 4))

func spawn_children(child_size: AsteroidSize, count: int):
	for i in count:
		emit_signal("request_spawn", child_size, global_position)
