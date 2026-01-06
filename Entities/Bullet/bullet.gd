class_name Bullet extends Area2D

var SPEED := 600
var direction

@onready var self_destruct_timer: Timer = $SelfDestructTimer

func _ready() -> void:
	add_to_group(GameConstants.GROUP_PROJECTILES)
	area_entered.connect(_on_area_entered)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	translate(direction * SPEED * delta)
	ScreenWrap.wrap(self)

func _on_self_destruct_timer_timeout() -> void:
	queue_free()

func _on_area_entered(area):
	if area.is_in_group(GameConstants.GROUP_ASTEROID_HITBOX):
		queue_free()
