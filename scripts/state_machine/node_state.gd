# NodeState is the BASE CLASS (blueprint) that every concrete state inherits from.
# A "state" in a state machine represents one mode of behaviour — e.g. Idle, Run, Jump.
# You never place this script on a node directly in a real game; you extend it.
#
# Pattern: each state is a child node of the NodeStateMachine node in the scene tree.
# The machine discovers these children automatically at runtime (see node_state_machine.gd).
class_name NodeState

# Extending Node (not Node2D, CharacterBody2D, etc.) keeps this class lightweight and
# purely logical — it carries no transform, no physics body, no visual representation.
extends Node

# This signal is the ONLY communication channel a state has with the outside world.
# When a state decides it's time to leave (e.g. "player hit the ground, go to Land state"),
# it emits this signal with the name of the target state as a String argument.
# The machine listens for it and performs the actual swap (see transition_to() in the machine).
#
# @warning_ignore("unused_signal") suppresses a GDScript editor warning that fires when a
# signal is declared but never emitted directly inside THIS file. The signal IS emitted from
# subclasses, so the warning is a false positive — this annotation silences it cleanly.
@warning_ignore("unused_signal")
signal transition 


# Called every visual frame. Override in subclasses to run frame-rate-dependent logic:
# animations, UI updates, non-physics visual feedback.
# The leading underscore on _delta is a GDScript convention meaning "this parameter exists
# to match the expected signature, but this base implementation ignores it."
# Subclasses that DO use delta should rename it to delta (no underscore).
func _on_process(_delta : float) -> void:
	pass


# Called every physics tick (default 60Hz, independent of frame rate).
# Override for movement, velocity changes, collision queries — anything that must be
# deterministic and frame-rate-independent.
func _on_physics_process(_delta : float) -> void:
	pass


# Called every physics tick, AFTER _on_physics_process, by the machine.
# Its sole purpose is to evaluate transition conditions: check input, velocity, timers, etc.,
# and emit `transition.emit("target_state_name")` if a switch is warranted.
# Keeping transition logic in its own method instead of inside _on_physics_process enforces
# a clean separation: "do the physics" vs "decide whether to leave."
func _on_next_transitions() -> void:
	pass


# Called once when the machine switches INTO this state.
# Use it for setup: reset timers, play enter animations, set initial velocity, enable hitboxes.
# Equivalent in concept to _ready(), but triggered on demand rather than at scene load.
func _on_enter() -> void:
	pass


# Called once when the machine switches OUT OF this state.
# Use it for teardown: stop animations, disable hitboxes, clear flags.
# Mirrors _on_enter() — whatever you set up there, you clean up here.
func _on_exit() -> void:
	pass
