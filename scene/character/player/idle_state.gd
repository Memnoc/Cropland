extends NodeState

@export var player: CharacterBody2D
@export var animated_sprite_2d: AnimatedSprite2D

var direction: Vector2

const DIRECTION_ANIMATIONS: Dictionary = {
	Vector2.LEFT: "idle_left",
	Vector2.RIGHT: "idle_right",
	Vector2.UP: "idle_back",
	Vector2.DOWN: "idle_front"
}


func _on_process(_delta: float) -> void:
	pass


func _on_physics_process(_delta: float) -> void:
	direction = _get_input_direction()
	animated_sprite_2d.play(DIRECTION_ANIMATIONS.get(direction, "idle_front"))

func _get_input_direction() -> Vector2:
	var input := Input.get_vector("walk_left", "walk_right", "walk_up", "walk_down")
	if input == Vector2.ZERO:
		return Vector2.ZERO
	if abs(input.x) >= abs(input.y):
		return Vector2(sign(input.x), 0.0)
	return Vector2(0.0, sign(input.y))

func _on_next_transitions() -> void:
	pass


func _on_enter() -> void:
	pass


func _on_exit() -> void:
	pass
