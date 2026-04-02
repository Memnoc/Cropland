extends NodeState

@export var player: Player
@export var animated_sprite_2d: AnimatedSprite2D

const DIRECTION_ANIMATIONS: Dictionary = { 
	Vector2.LEFT: "watering_left",
	Vector2.RIGHT: "watering_right",
	Vector2.UP: "watering_back",
	Vector2.DOWN: "watering_front",
}

func _on_process(_delta : float) -> void:
	pass

func _on_physics_process(_delta : float) -> void:
	pass

func _on_next_transitions() -> void:
	if !animated_sprite_2d.is_playing():
		transition.emit("Idle")


func _on_enter() -> void:
	animated_sprite_2d.play(DIRECTION_ANIMATIONS.get(player.player_direction, "watering_front"))

func _on_exit() -> void:
	animated_sprite_2d.stop()
