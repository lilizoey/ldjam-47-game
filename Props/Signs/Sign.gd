extends Node2D

export var background: Texture
export var glow: Texture
export var light_source: Texture
export var glow_color: Color = Color(1.5,1.5,1.5)

func _ready():
	$Sprite.texture = background
	$Glow.texture = glow
	$Light.texture = light_source
	$Light.modulate(glow_color)
