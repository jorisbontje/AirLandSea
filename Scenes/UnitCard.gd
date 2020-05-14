tool
extends Control

export var card_nr = 7 setget set_card_nr

onready var Game = get_node("/root/Game")

var card setget set_card
var selected = false
var entered = false

func set_card(new_card):
  card = new_card
  set_card_nr(card.sprite_id)

func set_card_nr(new_card_nr):
  if card_nr != new_card_nr:
    card_nr = new_card_nr
    $"unit-cards".frame = card_nr

func _update_border():
  if selected:
    $"Border".color = Color.yellow
  elif entered:
    $"Border".color = Color.white
  else:
    $"Border".color = Color.gray

func _on_UnitCard_pressed():
  print("card clicked")
  selected = not selected
  _update_border()

  if Game:
    if selected:
      Game.card_selected(card_nr)
    else:
      Game.card_selected(null)

func _on_UnitCard_mouse_entered():
#  print("entered")
  entered = true
  _update_border()

  if Game:
    Game.card_focussed(card_nr)

func _on_UnitCard_mouse_exited():
#  print("exited")
  entered = false
  _update_border()

  if Game:
    Game.card_focussed(null)
