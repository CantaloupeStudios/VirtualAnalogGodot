# Touch Screen Analog tutorial.

Steps: 

 0. Introduction / Setup
 1. understanding the touch/mouse input system
 2. Implement
 3. Track the movement using the drag
 4. understanding how to integrate with the game.
 5. Integrate with the game.
 6. Implementing multitouch.

## 0 - Introduction
Hello and welcome to this tutorial on how to implement
virtual analogic controlls to your mobile game using
the godot engine 3.1.
This guide assumes that you understand some programming
and knows how the godot engine works, but any advices and 
questions are welcome in the Issues section.

 * [Assets for this tutorial](https://drive.google.com/file/d/17ccGCXtCH6i9lLMqRfkTd7QygE3b1hHX/view?usp=sharing)
 * [FullProject](https://github.com/CantaloupeStudios/VirtualAnalogGodot)

### 0.1 - The setup
<!-- Create the assets for this part -->
So first we need to create a new scene. It will be a 
Node2D as the root. Using the assets provided
drag the **outer analog** and then 
add the **inner analog** inside the outer analog node.

Rename the nodes to `OuterAnalog` and `InnerAnalog` this
will be important later when adding logic to the scene.

Now i will add a script to the root scene, and i am calling
it `VirtualAnalog.gd`.
Also set the inner analog position to 0,0.

![Scene Structure](https://github.com/CantaloupeStudios/VirtualAnalogGodot/blob/master/SceneStructure01.png?raw=true)
## 1 - understanding the touch input system
Before we start coding i would like to explain the
input system for the touch and dragging events inside the godot engine.

The `_input(event):` method in godot receives every input
event, so we need to filter the events that we want by ourselves.

### 1.1 - InputEventScreenTouch

First lets understand how the `InputEventScreenTouch` works.

```
| type    | property |
----------------------
| bool    | pressed  |
| Vector2 | position |
| int     | index    |
```

Keep in mind that this event triggers both when the user touches
and releases the screen. 
So this will tell us when the player started or finished dragging, 
the property `pressed` will be used for that .
The `position` is where the event happend and it is pretty self explanatory.

And last but not least the `index` property, 
it defines wich finger is this touch
associated with, this is a very important 
information for dealing with multi touch input.

### 1.2 - InputEventScreenDrag

So now that we know when the user touched or released the screen,
we need to track his fingers movement on screen, and for this we 
will need to use the `InputEventScreenDrag`.

```
| type    | property |
----------------------
| int     | index    |
| Vector2 | position |
| Vector2 | relative |
| Vector2 | speed    |
```


For this tutorial it is only necessary to know the index and the
position of the drag, the index, so we know if attention is needed
on this input. And position, so we move the analog stick accordingly.

## 2 - Implementing
Now with that explained, we are ready to start coding.
Add a method `_input(event):` and then, lets verify
if the input is a screen touch, if it is 
then we can register some things first.

The node will need to remember wich finger it is
actually listening to, so lets store the `index`
on the `index` property, adding `var index = -1`
to its properties.

By saying that the index is -1, we are representing
that we are not listening to no one right now.

Also we should only set the index if we know for
sure that the touch is pressed.

So, your code should be looking like this right now

```gd
extends Node2D

var index:int = -1

# func ready():
#	pass

# func _process(delta):
#	pass

func _input(event):
	if event is InputEventScreenTouch && event.pressed:
		index = event.index
```

Now that we have the index set, make sure that we only respond to this index
for now on, also that we should only set it if it is -1.

```gd
func _input(event):

	# Only set index if there is nothing assigned
	if index == -1:
		if event is InputEventScreenTouch && event.pressed:
			index = event.index

	# return early so we don't process unecessary events.
	if index == -1 || event.index != index:
		return
```

This method should only listen to `InputEventScreenTouch` 
 or `InputEventScreenDrag`, so everything else can be ignored.

```gd
func _input(event):
	if !(event is InputEventScreenTouch || event is InputEventScreenDrag):
		return

	# Only set index if there is nothing assigned
	if index == -1:
		if event is InputEventScreenTouch && event.pressed:
			index = event.index

	# return early so we don't process unecessary events.
	if index == -1 || event.index != index:
		return
```

## 3 - Track the movement using the drag

Lets track the movement of the touch with our analog stick, 
right now everything is looking static, thats the
part where we add some movement to the screen.

The type of analog stick that we are going to implement is the
one where you can touch anywhere on screen and it will start the
dragging movement, i am choosing this over the statically placed
analog movement because it has a better feel and it is easier
for the player.

First we will need to set the position of the analog where
the user touched, and then only move the center piece by itself.
This will be placed inside the condition that the touch just started.

```gd
func _input(event):
	if !(event is InputEventScreenTouch || event is InputEventScreenDrag):
		return

	# Only set index if there is nothing assigned
	if index == -1:
		if event is InputEventScreenTouch && event.pressed:
			index = event.index
			$OuterAnalog.position = event.position

	# return early so we don't process unecessary events.
	if index == -1 || event.index != index:
		return
```

Since i need to test this on a computer environment during
development, i need to make sure that the Emulate touch from mouse
is enabled in the configuration, to do this go to project settings
on the `Input devices/Pointing` make sure `Emulate Touch From Mouse`
is checked.

So after testing it out, the circle should be where you click
everytime.

Now the tracking part will be placed at the end of our 
`_input` method.

```gd
func _input(event):
	if !(event is InputEventScreenTouch || event is InputEventScreenDrag):
		return

	# Only set index if there is nothing assigned
	if index == -1:
		if event is InputEventScreenTouch && event.pressed:
			index = event.index
			$OuterAnalog.position = event.position

	# return early so we don't process unecessary events.
	if index == -1 || event.index != index:
		return

	$OuterAnalog/InnerAnalog.position = event.position
```

After testing now we have 3 problems that are needed to be solved.
 1. The Analog is stuck at the position of the first touch.
 2. The center of the Analog is folowing the cursor, but it is really far away.
 3. The center of the Analog gets out of the circle.

### 3.1 - The Analog is stuck at the position of the first touch.
To solve the position of the analog being stuck at the first position
we need to track when the touch has ended. When it ends, we need to reset the index
to -1, i will also reset the inner analog stick position, so it doesnt look off.

```gd
func _input(event):
	if !(event is InputEventScreenTouch || event is InputEventScreenDrag):
		return

	# Only set index if there is nothing assigned
	if index == -1:
		if event is InputEventScreenTouch && event.pressed:
			index = event.index
			$OuterAnalog.position = event.position

	# return early so we don't process unecessary events.
	if index == -1 || event.index != index:
		return

	# Finish the drag
	if event is InputEventScreenTouch && !event.pressed:
		index = -1
		$OuterAnalog/InnerAnalog.position = Vector2(0,0)
		return

	# Follow the touch
	$OuterAnalog/InnerAnalog.position = event.position
```

### 3.2 - The center of the Analog is folowing the cursor, but it is really far away.
So now we need to solve the Analog really far away from the touch
this happens because it is inside another node, to fix this
we just need to remove the difference from its parent
position. By rewriting it to
`$OuterAnalog/InnerAnalog.position = event.position - $OuterAnalog.position`

```gd
func _input(event):
	if !(event is InputEventScreenTouch || event is InputEventScreenDrag):
		return

	# Only set index if there is nothing assigned
	if index == -1:
		if event is InputEventScreenTouch && event.pressed:
			index = event.index
			$OuterAnalog.position = event.position

	# Return early so we don't process unecessary events.
	if index == -1 || event.index != index:
		return

	# Finish the drag
	if event is InputEventScreenTouch && !event.pressed:
		index = -1
		$OuterAnalog/InnerAnalog.position = Vector2(0,0)
		return

	# Follow the touch
	$OuterAnalog/InnerAnalog.position = event.position - $OuterAnalog.position
```

### 3.3 - The center of the Analog gets out of the circle.
Now we need to limit the inner circle from going out,
to do this we are going to add a `max_distance` to the class
properties, this should be a export variable
so it can be tuned on directly on the editor as we test it.
Now we can use the very usefull method of the Vector2 called
`clamped`, so it limits the distance to our max value.

```gd
extends Node2D

var index:int = -1
export var max_distance:float = 55.0

# func ready():
#	pass

# func _process(delta):
#	pass

func _input(event):
	if !(event is InputEventScreenTouch || event is InputEventScreenDrag):
		return

	# Only set index if there is nothing assigned
	if index == -1:
		if event is InputEventScreenTouch && event.pressed:
			index = event.index
			$OuterAnalog.position = event.position

	# Return early so we don't process unecessary events.
	if index == -1 || event.index != index:
		return

	# Finish the drag
	if event is InputEventScreenTouch && !event.pressed:
		index = -1
		$OuterAnalog/InnerAnalog.position = Vector2(0,0)
		return

	# Follow the touch
	$OuterAnalog/InnerAnalog.position = (event.position - $OuterAnalog.position).clamped(max_distance)
```

After testing, now we have a pretty convincing analog stick by itself.

## 5 - Integrate with the game.
Now that we have the looks of the analog stick working propperly, lets
integrate it with the game, to do this, we are going to use signals,
they are going to be really usefull to comunicate with other nodes.


### 5.1 - Sending Signals
I recommend using 2 signals, one to tell if the analog started or stopped
and the other it is going to send the current direction of the analog stick.

Add these 2 signals near the top of the code:
```gd
signal analog_touch(touching)
signal analog_move(direction)
```

Lets start integrating those events on our code.
First add the analog_touch() to the start and end
of the dragging behaviour.

```gd
func _input(event):
	if !(event is InputEventScreenTouch || event is InputEventScreenDrag):
		return

	# Only set index if there is nothing assigned
	if index == -1:
		if event is InputEventScreenTouch && event.pressed:
			index = event.index
			$OuterAnalog.position = event.position
			emit_signal('analog_touch', true)

	# Return early so we don't process unecessary events.
	if index == -1 || event.index != index:
		return

	# Finish the drag
	if event is InputEventScreenTouch && !event.pressed:
		index = -1
		$OuterAnalog/InnerAnalog.position = Vector2(0,0)
		emit_signal('analog_touch', false)
		return

	# Follow the touch
	$OuterAnalog/InnerAnalog.position = (event.position - $OuterAnalog.position).clamped(max_distance)
```

Lets add the analog_move event at the end of the `_input` method.
To tell the direction and intensity i am going to limit the value of
the event to between 0 and 1, so it can emulate a joystick better.
To get the intesity we get the position length and divide by the
`max_distance`. So, to get the direction, we use the normalized method of the Vector2 class,
it returns a directional vector limited to 0 and 1.
Then we multiply the intensity with the direction, this value
is what we will send in the signal `analgo_move`.

```gd
# this will set the intensity between 0 and 1
var intensity = $OuterAnalog/InnerAnalog.position.length() / max_distance
var direction = $OuterAnalog/InnerAnalog.position.normalized()

emit_signal('analog_move', direction * intensity)
```

Now the `VirtualAnalog.gd` is looking like this:

```gd
extends Node2D

var index:int = -1
export var max_distance:float = 55.0

signal analog_touch(touching)
signal analog_move(direction)

# func ready():
#	pass

# func _process(delta):
#	pass

func _input(event):
	if !(event is InputEventScreenTouch || event is InputEventScreenDrag):
		return

	# Only set index if there is nothing assigned
	if index == -1:
		if event is InputEventScreenTouch && event.pressed:
			index = event.index
			$OuterAnalog.position = event.position
			emit_signal('analog_touch', true)

	# Return early so we don't process unecessary events.
	if index == -1 || event.index != index:
		return

	# Finish the drag
	if event is InputEventScreenTouch && !event.pressed:
		index = -1
		$OuterAnalog/InnerAnalog.position = Vector2(0,0)
		emit_signal('analog_touch', false)
		return

	# Follow the touch
	$OuterAnalog/InnerAnalog.position = (event.position - $OuterAnalog.position).clamped(max_distance)

	# this will set the intensity between 0 and 1
	var intensity = $OuterAnalog/InnerAnalog.position.length() / max_distance
	var direction = $OuterAnalog/InnerAnalog.position.normalized()

	emit_signal('analog_move', direction * intensity)
```

### 5.2 - Example Scene
Now we are ready to implement this to a game, 
I am going to create a new scene called `SampleGame`, and add the godot logo as
the player character.
Drag the icon.png into the scene and add a script called `Player.gd`, then
rename the sprite node to `Player` too.
I am going to set the `SampleGame` scene as the main scene for our game,
to do this go to the Project Settings, Under the Application/Run change the main
scene to be our `SampleGame` scene. Run the game to make sure that our scene is
now the main scene of the project.

Lets add two variables to our `Player.gd` class file 
`var moving:bool = false` and `var direction:Vector2 = Vector2(0,0)`.

Back on the editor we need to create a CanvasLayer node 
to add our analog stick to the screen.
Drag the Virtual Analog Scene file to inside the CanvasLayer node of the tree.
Now we need to connect our Analog Stick signals to the `Player` node, 
click on the VirutalAnalog node, and then change the Inspector to Node.
Double click on the `analog_touch` signal, make sure that the method in node is set to:
`_on_VirtualAnalog_analog_touch` and the Make Function is checked and then click **Connect**.
Repeat this with the `analog_move` signal too, the method name should be `_on_VirtualAnalog_analog_move`.

Your `Player.gd` should be looking like this.

```gd
extends Sprite

var moving:bool = false
var direction:Vector2 = Vector2(0,0)

func _ready():
	pass

func _process(delta):
	pass

func _on_VirtualAnalog_analog_touch(touching):
	pass

func _on_VirtualAnalog_analog_move(direction):
	pass
```

Edit the `_on_VirtualAnalog_analog_touch` method by setting the
moving variable to touching like this `moving = touching`,
and the `_on_VirtualAnalog_analog_move` by `self.direction = direction`.

```gd
func _on_VirtualAnalog_analog_touch(touching):
	moving = touching

func _on_VirtualAnalog_analog_move(direction):
	self.direction = direction
```

With this set we are ready to make some player movement.
Add a `export var speed:float = 300.0` after the already set variables.
Then on the `_process` method lets add this code:

```gd
if moving:
	position += direction * delta * speed
```

By hitting run, we can now see that the player is moving according to the
analog stick. It is recommended that you add a blindspot to your analog controlls,
we are not going to cover this, since it is not crucial to this guide.

## 6 - Implementing multitouch

Now that we got a single analog stick working, lets configure
a dual stick support, so the player can move, and look at
different directions.

First lets hide the VirtualAnalog node when it is not being dragged
around. On the editor, click on the eye by the Scene tree on the VirtualAnalog node,
so it doesn't show up from the begining, then modify 
the `_input` method so it shows on touch down, and hides on touch up, by using the
`visible` property of the Node2D class.

```gd
func _input(event):
	if !(event is InputEventScreenTouch || event is InputEventScreenDrag):
		return

	# Only set index if there is nothing assigned
	if index == -1:
		if event is InputEventScreenTouch && event.pressed:
			index = event.index
			$OuterAnalog.position = event.position
			emit_signal('analog_touch', true)
			visible = true

	# Return early so we don't process unecessary events.
	if index == -1 || event.index != index:
		return

	# Finish the drag
	if event is InputEventScreenTouch && !event.pressed:
		index = -1
		$OuterAnalog/InnerAnalog.position = Vector2(0,0)
		visible = false
		emit_signal('analog_touch', false)
		return

	# Follow the touch
	$OuterAnalog/InnerAnalog.position = (event.position - $OuterAnalog.position).clamped(max_distance)

	# this will set the intensity between 0 and 1
	var intensity = $OuterAnalog/InnerAnalog.position.length() / max_distance
	var direction = $OuterAnalog/InnerAnalog.position.normalized()

	emit_signal('analog_move', direction * intensity)
```

To add a dual stick support, i am going to limit each joystick to a side
of the screen, if the user drags the left joystick, the player should move,
if the right one is dragged, the player should look at the direction.

Let's add a enum called `ScreenSide` with the values `LEFT, RIGHT` so
we can use it as a type to our export variable.
Create a export variable like this `export(ScreenSide) var screen_side = ScreenSide.LEFT`
this way you can choose wich screen side this VirtualAnalog responds to from the editor.
The begining of your file should be looking like this right now:

```gd
enum ScreenSide {LEFT, RIGHT}
export(ScreenSide) var screen_side = ScreenSide.LEFT,RIGHT
```

With this added, we need to make sure that we only start a drag when the touch happens
on the side chosen. To know wich side of the screen we are touching, i am going to use
this `get_viewport_rect().size.x` to get the screen width, and then compare if it's half
greater or smaller than the touching position x, the value being smaller means the touch
happened on the left, greater means it happend on the right.

Since this is a big condition to be added on the code, i am going to
transform it into a isolated method and then call it by itself.

```gd
func correct_side(touch_position):
	var screen_midpoint = get_viewport_rect().size.x / 2
	return (
		(screen_side == ScreenSide.LEFT && touch_position.x < screen_midpoint) ||
		(screen_side == ScreenSide.RIGHT && touch_position.x > screen_midpoint)
	)
```

Now i am going to integrate it back into the `_input` method.

```gd
if index == -1:
	if event is InputEventScreenTouch && event.pressed && correct_side(event.position):
		index = event.index
		$OuterAnalog.position = event.position
		visible = true
		emit_signal('analog_touch', true)
```

Our `VirtualAnalog.gd` file is looking like this right now:

```gd
extends Node2D

enum ScreenSide {LEFT, RIGHT}

var index:int = -1
export var max_distance:float = 55.0
export(ScreenSide) var screen_side = ScreenSide.LEFT

signal analog_touch(touching)
signal analog_move(direction)

#func ready():
#	pass

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
```

Now we are done with this class, we don't need to edit it anymore.
Lets integrate it to our SampleGame.
Add a Second VirtualAnalog to our CanvasLayer and on the Inspector change
the `Screen Side` property to RIGHT, by testing our game, a analog stick should 
appear whe touched on the right side of the screen, but nothing happens
to the player. To add functionality to this analog stick, lets connect its signals
to the Player node. Connect the VirtualAnalog2 `analog_move` signal to the player
and name the connected method as `_on_VirtualAnalog2_analog_move`. The `analog_touch` event
should be connected to `_on_VirtualAnalog2_analog_touch` on the player.

Our player class is looking like this right now.

```gd
extends Sprite

var moving:bool = false
var direction:Vector2 = Vector2(0,0)
export var speed:float = 300

func _ready():
	pass

func _process(delta):
	if moving:
		position += direction * delta  * speed

func _on_VirtualAnalog_analog_touch(touching):
	moving = touching

func _on_VirtualAnalog_analog_move(direction):
	self.direction = direction

func _on_VirtualAnalog2_analog_move(direction):
	pass # Replace with function body.

func _on_VirtualAnalog2_analog_touch(touching):
	pass # Replace with function body.

```

Lets add two properties to this class at the begining,
the `is_looking_at:bool` and the `looking_at_direction:Vector2` like this:

```gd
var is_looking_at:bool = false
var looking_at_direction:Vector2 = Vector2(0,0)
```

Now set those variables on the signal methods, like this:

```gd
func _on_VirtualAnalog2_analog_move(direction):
	looking_at_direction = direction

func _on_VirtualAnalog2_analog_touch(touching):
	is_looking_at = touching
```

Now i am going to rotate the player to the direction of the joystick
only if the `looking_at_direction` is true.

```gd
func _process(delta):
	if moving:
		position += direction * delta  * speed
	if is_looking_at:
		# Added the PI/2 so the top of the sprite is looking
		# at the right direction
		rotation = looking_at_direction.angle() + PI/2
```

The `Player.gd` file should be looking like this:

```gd
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
```

By trying it out, the player should be moving using the left
analog stick and looking at the direction of the right analog stick.

Thats it, we are done for this tutorial, thanks a lot for following this tutorial,
if you enjoyed it, consider giving a star on github,
and follow me here for more content. If you are interested in checking out 
the game that i am currently developing, please follow me on twitter. 

[Twitter @cantaloupestud1](https://twitter.com/cantaloupestud1)
[Itch.io Cantaloupe Studios](cantaloupestudios.itch.io)
[Youtube Channel](https://www.youtube.com/channel/UCZQKs1k6apG5ULMck3N14fg)
