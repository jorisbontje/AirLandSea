tool
extends Control

const Constants = preload("res://Scripts/Constants.gd")

export var is_selectable = true

onready var Game = get_node_or_null("/root/Game")

var card setget set_card
var selected = false
var entered = false

func set_card(new_card):
  card = new_card
  $UnitCardView.card = card

func deselect():
  selected = false
  _update_border()

func _update_border():
  if selected:
    $"Border".color = Color.yellow
  elif entered:
    $"Border".color = Color.white
  else:
    $"Border".color = Color.gray

func _on_UnitCard_pressed():
  if Game and Game.game_state != Constants.STATES.PLAYING:
    print("Can't select theater card when not playing")
    return

  # print("card clicked")
  selected = is_selectable and not selected
  _update_border()

  if Game:
    if selected:
      Game.card_selected(card)
    else:
      Game.card_selected(null)

func _on_UnitCard_mouse_entered():
#  print("entered")
  entered = true
  _update_border()

  if Game:
    Game.card_focussed(card)

func _on_UnitCard_mouse_exited():
#  print("exited")
  entered = false
  _update_border()

  if Game:
    Game.card_focussed(null)
