extends NodeState

@export var player: CharacterBody2D
@export var animated_sprite_2d: AnimatedSprite2D
@export var speed: int = 50

const DIRECTION_ANIMATIONS: Dictionary = {
	Vector2.LEFT: "walk_left",
	Vector2.RIGHT: "walk_right",
	Vector2.UP: "walk_back",
	Vector2.DOWN: "walk_front"
}

func _on_process(_delta : float) -> void:
	pass

func _on_physics_process(_delta : float) -> void:
	var direction: Vector2 = GameInputEvent.movement_input()
	animated_sprite_2d.play(DIRECTION_ANIMATIONS.get(direction, "walk_front"))
	player.velocity = direction * speed
	player.move_and_slide()

func _on_next_transitions() -> void:
	if !GameInputEvent.is_movement_input():
		transition.emit("Idle")

func _on_enter() -> void:
	pass
func _on_exit() -> void:
	pass
