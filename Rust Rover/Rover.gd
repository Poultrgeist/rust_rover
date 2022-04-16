extends KinematicBody2D

export(int) var SPEED : int = 40 * 60
var velocity : Vector2 = Vector2.ZERO

var targets : Array = [] # vec2s of global position targets
var path : Array = [] # Contains destination positions
onready var levelNavigation : Navigation2D = get_node_or_null("/root/Game/Planet/Navigation2D")
onready var line2d = $Line2D


func _ready():
	yield(get_tree(), "idle_frame")
	var tree = get_tree()
	targets.append(Vector2(400,200))
	targets.append(Vector2(690,300))

func _physics_process(delta):
	line2d.global_position = Vector2.ZERO
	if targets.size() > 0:
		generate_path()
		navigate(delta)
		move()

func generate_path():	# It's obvious
	if levelNavigation != null:
		path = levelNavigation.get_simple_path(global_position, targets[0], false)
		line2d.points = path

func navigate(delta):	# Define the next position to go to
	if path.size() > 0:
		velocity = global_position.direction_to(path[1]) * SPEED * delta
		print(path[0], path[1])
		# If reached the destination, remove this point from path array
		if global_position == path[0]:
			path.pop_front()
			print(path.size())
			if path.size() == 1 and (path[0] - global_position).length_squared() <= 0.07:
				targets.pop_front()
				global_position = path[0]
				print("pop goes the weasel")
				print(targets.size())

func move():
	velocity = move_and_slide(velocity)
