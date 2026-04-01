class_name GameInputEvent
extends Node

static var direction: Vector2

static func movement_input() -> Vector2:
	var input := Input.get_vector("walk_left", "walk_right", "walk_up", "walk_down")
	if input == Vector2.ZERO:
		direction = Vector2.ZERO
		return direction
	if abs(input.x) >= abs(input.y):
		direction = Vector2(sign(input.x), 0.0)
	else:
		direction = Vector2(0.0, sign(input.y))
	return direction

static func is_movement_input() -> bool:
	return direction != Vector2.ZERO
