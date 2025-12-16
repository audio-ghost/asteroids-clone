extends CharacterBody2D

var BULLET_SCENE = preload("res://Entities/Bullet/bullet.tscn")

@export var max_speed := 400.0
@export var rotation_speed := 125.0
@export var acceleration := 300.0
@export var deceleration := 100.0
@export var use_drag := true
@export var fire_rate := 0.25

var can_fire = true

@onready var starting_position = global_position
@onready var fire_bullet_timer: Timer = $FireBulletTimer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	apply_rotation(delta)
	handle_acceleration(delta)
	if Input.is_action_just_pressed(("fire_projectile")) and can_fire:
		fire_bullet()
	move_and_slide()
	ScreenWrap.wrap(self)

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

func fire_bullet() -> void:
	var bullet = BULLET_SCENE.instantiate()
	get_tree().current_scene.get_parent().add_child(bullet)
	bullet.global_position = global_position
	bullet.direction = Vector2.UP.rotated(rotation)
	fire_bullet_timer.start(fire_rate)
	can_fire = false

func _on_fire_bullet_timer_timeout() -> void:
	can_fire = true

func _on_ship_collider_body_entered(body) -> void:
	if body is PhysicsBody2D:
		handle_crash()
	
func handle_crash():
	pass
