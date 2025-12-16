class_name ScreenWrap

static func wrap(node: Node2D):
	var screen_size = node.get_viewport_rect().size
	var position = node.global_position
	position.x = wrapf(position.x, 0, screen_size.x)
	position.y = wrapf(position.y, 0, screen_size.y)
	node.global_position = position
