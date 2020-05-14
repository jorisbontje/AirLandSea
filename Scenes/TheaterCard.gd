tool
extends Control

export var theater_type = 0 setget set_theater_type

onready var Game = get_node("/root/Game")

var selected = false
var entered = false

func set_theater_type(new_theater_type):
  if theater_type != new_theater_type:
    theater_type = new_theater_type
    $"theater-cards".frame = new_theater_type

func _update_border():
  if selected:
    $"Border".color = Color.yellow
  elif entered:
    $"Border".color = Color.white
  else:
    $"Border".color = Color.gray

func _on_TheaterCard_pressed():
  print("theater card clicked")
  selected = not selected
  _update_border()

  if Game:
    if selected:
      Game.theater_selected(theater_type)
    else:
      Game.theater_selected(null)

func _on_TheaterCard_mouse_entered():
#  print("entered")
  entered = true
  _update_border()

func _on_TheaterCard_mouse_exited():
#  print("exited")
  entered = false
  _update_border()
