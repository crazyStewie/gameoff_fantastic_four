extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

onready var vector := self.translation
var angle := 0.0
var max_angular_speed = 2.0
var angular_speed = 0.0
var accel = 6.0
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _physics_process(delta):
	var target_speed = (Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"))*max_angular_speed
	angular_speed = lerp(angular_speed, target_speed, accel*delta)
	angle += angular_speed*delta
	
	self.translation = vector.rotated(Vector3.FORWARD, angle)
	
