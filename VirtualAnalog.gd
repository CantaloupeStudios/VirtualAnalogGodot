extends Node2D

enum ScreenSide {LEFT, RIGHT}

var index:int = -1
export var max_distance:float = 55.0
export(ScreenSide) var screen_side = ScreenSide.LEFT

signal analog_touch(touching)
signal analog_move(direction)

func ready():
	hide()

# func _process(delta):
#	pass

func correct_side(touch_position):
	var screen_midpoint = get_viewport_rect().size.x / 2
	return (
		(screen_side == ScreenSide.LEFT && touch_position.x < screen_midpoint) ||
		(screen_side == ScreenSide.RIGHT && touch_position.x > screen_midpoint)
	)

func _input(event):
	if !(event is InputEventScreenTouch || event is InputEventScreenDrag):
		return

	# Only set index if there is nothing assigned
	if index == -1:
		if event is InputEventScreenTouch && event.pressed && correct_side(event.position):
			index = event.index
			$OuterAnalog.position = event.position
			visible = true
			emit_signal('analog_touch', true)

	# Return early so we don't process unecessary events.
	if index == -1 || event.index != index:
		return

	# Finish the drag
	if event is InputEventScreenTouch && !event.pressed:
		index = -1
		$OuterAnalog/InnerAnalog.position = Vector2(0,0)
		emit_signal('analog_touch', false)
		visible = false
		return

	# Follow the touch
	$OuterAnalog/InnerAnalog.position = (event.position - $OuterAnalog.position).clamped(max_distance)

	# this will set the intensity between 0 and 1
	var intensity = $OuterAnalog/InnerAnalog.position.length() / max_distance
	var direction = $OuterAnalog/InnerAnalog.position.normalized()

	emit_signal('analog_move', direction * intensity)