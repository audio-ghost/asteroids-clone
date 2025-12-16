extends CharacterBody2D

@export var max_speed := 500.0
@export var rotation_speed := 125.0
@export var acceleration := 300.0
@export var deceleration := 100.0
@export var use_drag := true

@onready var screen_size = get_viewport_rect().size
@onready var starting_position = global_position

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	apply_rotation(delta)
	handle_acceleration(delta)
	move_and_slide()
	screen_wrap()

func apply_rotation(delta):
	var input_axis := Input.get_axis("rotate_left", "rotate_right")
	rotation_degrees = rotation_degrees + input_axis * rotation_speed * delta

func handle_acceleration(delta):
	if Input.is_action_pressed("fire_thruster"):
		var direction = Vector2.UP.rotated(rotation)
		velocity += direction * acceleration * delta
		if velocity.length() > max_speed:
			velocity = velocity.normalized() * max_speed
	elif use_drag:
		velocity = velocity.move_toward(Vector2.ZERO, deceleration * delta)

func screen_wrap():
	position.x = wrapf(position.x, 0, screen_size.x)
	position.y = wrapf(position.y, 0, screen_size.y)

func _on_ship_collider_body_entered(body) -> void:
	if body is PhysicsBody2D:
		handle_crash()
	
func handle_crash():
	pass
