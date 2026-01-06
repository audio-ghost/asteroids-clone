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

const POINT_COUNT_RANGE := Vector2i(8, 14)
const RADIUS_VARIANCE := 0.3
const SIZE_RADIUS := {
	AsteroidSize.LARGE: 40.0,
	AsteroidSize.MEDIUM: 25.0,
	AsteroidSize.SMALL: 15.0
}

@export var size := AsteroidSize.LARGE
@export var rotation_speed := 0.0

signal request_spawn(size: AsteroidSize, position: Vector2)

@onready var sprite: Polygon2D = $Sprite
@onready var body: CollisionPolygon2D = $Body
@onready var hitbox: Area2D = $Hitbox
@onready var hitbox_shape: CollisionPolygon2D = $Hitbox/HitboxShape

func _ready() -> void:
	add_to_group(GameConstants.GROUP_ASTEROIDS)
	hitbox.add_to_group(GameConstants.GROUP_ASTEROID_HITBOX)
	initialize(Vector2.ZERO)
	hitbox.area_entered.connect(_on_hitbox_area_entered)

func _physics_process(delta: float) -> void:
	rotation += rotation_speed * delta
	move_and_slide()
	ScreenWrap.wrap(self)

func initialize(start_position: Vector2) -> void:
	global_position = start_position
	
	var dir = Vector2.RIGHT.rotated(randf() * TAU)
	var s_range = SPEED_RANGES[size]
	var speed = randf_range(s_range.x, s_range.y)
	velocity = speed * dir
	
	rotation_speed = randf_range(-2.0, 2.0)
	
	generate_shape()

func generate_shape():
	var points: PackedVector2Array = []
	var point_count = randi_range(
		POINT_COUNT_RANGE.x,
		POINT_COUNT_RANGE.y
	)
	var base_radius = SIZE_RADIUS[size]
	
	for i in range(point_count):
		var angle = (TAU / point_count) * i
		var radius = base_radius * randf_range(
			1.0 - RADIUS_VARIANCE,
			1.0 + RADIUS_VARIANCE
		)
		var point = Vector2.RIGHT.rotated(angle) * radius
		points.append(point)
	
	sprite.polygon = points
	body.polygon = points
	hitbox_shape.polygon = points

func _on_hitbox_area_entered(area):
	if area.is_in_group(GameConstants.GROUP_PROJECTILES):
		destroy()

func destroy():
	call_deferred("_spawn_children_and_free")

func _spawn_children_and_free():
	match size:
		AsteroidSize.LARGE:
			spawn_children(AsteroidSize.MEDIUM, randi_range(2, 3))
			spawn_children(AsteroidSize.SMALL, randi_range(0, 2))
		AsteroidSize.MEDIUM:
			spawn_children(AsteroidSize.SMALL, randi_range(3, 4))
	queue_free()

func spawn_children(child_size: AsteroidSize, count: int):
	for i in count:
		emit_signal("request_spawn", child_size, global_position)
