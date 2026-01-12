class_name Player extends CharacterBody2D

var BULLET_SCENE = preload("res://Entities/Bullet/bullet.tscn")

@export var max_speed := 400.0
@export var rotation_speed := 125.0
@export var acceleration := 300.0
@export var deceleration := 100.0
@export var use_drag := true
@export var fire_rate := 0.25

signal player_death(lives: int)
signal game_over

var can_fire := true
var lives := 3

@onready var starting_position = global_position
@onready var fire_bullet_timer: Timer = $FireBulletTimer
@onready var sprite: Polygon2D = $Sprite
@onready var hurtbox: Area2D = $Hurtbox

func _ready() -> void:
	add_to_group(GameConstants.GROUP_PLAYER)
	hurtbox.area_entered.connect(_on_hurtbox_area_entered)

func _physics_process(delta: float) -> void:
	# Replace with proper pause logic when global pause state is created
	if get_parent().is_wave_starting:
		return
	
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

func _on_hurtbox_area_entered(area):
	if area.is_in_group(GameConstants.GROUP_ASTEROID_HITBOX):
		die()

func die():
	lives -= 1
	emit_signal("player_death", lives)
	if lives > 0:
		respawn()
	else:
		emit_signal("game_over")
		queue_free()

func respawn():
	velocity = Vector2.ZERO
	rotation = 0
	global_position = get_viewport_rect().size / 2
	
	sprite.modulate = Color(1, 0, 0)
	await get_tree().create_timer(0.2).timeout
	sprite.modulate = Color(1, 1, 1)
