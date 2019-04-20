extends Sprite

var is_looking_at:bool = false
var looking_at_direction:Vector2 = Vector2(0,0)
var moving:bool = false
var direction:Vector2 = Vector2(0,0)
export var speed:float = 300

func _ready():
	pass

func _process(delta):
	if moving:
		position += direction * delta  * speed
	if is_looking_at:
		rotation = looking_at_direction.angle() + PI/2

func _on_VirtualAnalog_analog_touch(touching):
	moving = touching

func _on_VirtualAnalog_analog_move(direction):
	self.direction = direction

func _on_VirtualAnalog2_analog_move(direction):
	looking_at_direction = direction

func _on_VirtualAnalog2_analog_touch(touching):
	is_looking_at = touching



