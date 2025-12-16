class_name Bullet extends Area2D

var SPEED := 600
var direction

@onready var self_destruct_timer: Timer = $SelfDestructTimer

func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	translate(direction * SPEED * delta)
	ScreenWrap.wrap(self)

func _on_self_destruct_timer_timeout() -> void:
	queue_free()
