extends NodeState

@export var player: Player
@export var animated_sprite_2d: AnimatedSprite2D

const DIRECTION_ANIMATIONS: Dictionary = {
	Vector2.LEFT: "idle_left",
	Vector2.RIGHT: "idle_right",
	Vector2.UP: "idle_back",
	Vector2.DOWN: "idle_front"
}


func _on_process(_delta: float) -> void:
	pass


func _on_physics_process(_delta: float) -> void:
	GameInputEvent.movement_input()
	animated_sprite_2d.play(DIRECTION_ANIMATIONS.get(player.player_direction, "idle_front"))


func _on_next_transitions() -> void:
	GameInputEvent.is_movement_input()
	
	if GameInputEvent.is_movement_input():
		transition.emit("Walk")

	if player.current_tool == DataTypes.Tools.Axewood && GameInputEvent.use_tool():
		transition.emit("Chopping")
		
	
	if player.current_tool == DataTypes.Tools.TillGround && GameInputEvent.use_tool():
		transition.emit("Tilling")


func _on_enter() -> void:
	pass


func _on_exit() -> void:
	animated_sprite_2d.stop()
