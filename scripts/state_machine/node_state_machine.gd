# NodeStateMachine is the COORDINATOR. It owns all states (as child nodes in the scene tree),
# routes execution to whichever state is currently active, and handles transitions between them.
#
# Architecture recap:
#   NodeStateMachine (this script)
#   ├── IdleState   (extends NodeState)
#   ├── RunState    (extends NodeState)
#   └── JumpState   (extends NodeState)
#
# The machine is intentionally dumb about WHAT each state does — it only knows HOW to switch
# between them. All game logic lives inside the individual state scripts.
class_name NodeStateMachine

# Extending plain Node keeps the machine itself free of physics/visual baggage.
# It is a pure coordinator; it doesn't move, render, or collide with anything.
extends Node

# @export makes this field visible and editable in the Godot Inspector.
# You drag the desired starting state node here at design time.
# This decouples the hardcoded starting state from the script itself — you can change it
# per scene without touching code.
@export var initial_node_state : NodeState

# A Dictionary mapping lowercase state names (String) → NodeState instances.
# Built automatically at runtime from the scene tree children.
# Using lowercase keys everywhere prevents mismatches from capitalisation differences.
var node_states : Dictionary = {}

# The NodeState instance that is currently running.
# The machine delegates all per-frame calls to this reference.
var current_node_state : NodeState

# Cached lowercase String of the current state's name.
# Stored separately so name lookups don't require calling .name.to_lower() every frame.
var current_node_state_name : String


func _ready() -> void:
	# Iterate over every direct child of this node in the scene tree.
	for child in get_children():
		# Only register children that are NodeState instances.
		# This is a type check — non-state utility nodes won't be picked up accidentally.
		if child is NodeState:
			# Store the state in the dictionary keyed by its lowercase node name.
			# Node name comes from the Godot scene tree (the label you see in the editor).
			# to_lower() is applied once here so all lookups are case-insensitive by default.
			node_states[child.name.to_lower()] = child
			
			# Connect this state's `transition` signal to the machine's transition_to() method.
			# When any state calls transition.emit("run"), transition_to("run") fires here.
			# This is the entire inter-state communication mechanism — states never talk to
			# each other directly, only through this signal→slot bridge.
			child.transition.connect(transition_to)
	
	# If a starting state was assigned in the Inspector, activate it immediately.
	if initial_node_state:
		# Manually call the enter hook — _ready() in the state itself would have already
		# run before this point, so this is a deliberate second-phase initialisation.
		initial_node_state._on_enter()
		current_node_state = initial_node_state
		# Note: current_node_state_name is NOT set here, only in transition_to().
		# This is a minor inconsistency in the tutorial code worth knowing about.


func _process(delta : float) -> void:
	# Every visual frame, forward execution to the active state's process hook.
	# The guard `if current_node_state` prevents a crash during the single frame before
	# _ready() finishes, or if initial_node_state was left empty in the Inspector.
	if current_node_state:
		current_node_state._on_process(delta)


func _physics_process(delta: float) -> void:
	if current_node_state:
		# Run physics logic first (movement, velocity, etc.)...
		current_node_state._on_physics_process(delta)
		# ...then evaluate transition conditions AFTER physics has updated state.
		# Order matters: checking conditions before physics would read stale values from
		# the previous frame (e.g. is_on_floor() wouldn't reflect the just-resolved collision).
		current_node_state._on_next_transitions()
		print("Current State: ", current_node_state_name)


# Called via the `transition` signal emitted by any active state.
# node_state_name: the lowercase (or any-case) name of the destination state.
func transition_to(node_state_name : String) -> void:
	# Bail out if the requested state is already active.
	# Prevents redundant _on_exit/_on_enter cycles and infinite signal loops.
	if node_state_name == current_node_state.name.to_lower():
		return
	
	# Look up the destination state in the pre-built dictionary.
	# .get() returns null if the key doesn't exist, rather than crashing.
	var new_node_state = node_states.get(node_state_name.to_lower())
	
	# If the requested state name doesn't match any registered child, silently abort.
	# In production you'd likely want a push_error() or assert() here to catch typos.
	if !new_node_state:
		return
	
	# Notify the current state it's being deactivated so it can clean up.
	if current_node_state:
		current_node_state._on_exit()
	
	# Activate the new state.
	new_node_state._on_enter()
	
	# Update the machine's active state references.
	current_node_state = new_node_state
	current_node_state_name = current_node_state.name.to_lower()
	
	# Debug output — useful during development, typically removed or gated behind a
	# debug flag before shipping.
	print("Current State: ", current_node_state_name)
