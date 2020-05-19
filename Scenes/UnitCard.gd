tool
extends Control

const FACEDOWN_SPRITE = 7
export var card_nr = FACEDOWN_SPRITE setget set_card_nr
export var is_selectable = true

onready var Game = get_node("/root/Game")


var card setget set_card
var selected = false
var entered = false

func set_card(new_card):
  card = new_card
  if card.get('faceup', false):
    set_card_nr(card.sprite_id)
  else:
    set_card_nr(FACEDOWN_SPRITE)

func set_card_nr(new_card_nr):
  if card_nr != new_card_nr:
    card_nr = new_card_nr
    $"unit-cards".frame = card_nr

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
#  print("card clicked")
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
    Game.card_nr_focussed(card_nr)

func _on_UnitCard_mouse_exited():
#  print("exited")
  entered = false
  _update_border()

  if Game:
    Game.card_nr_focussed(null)
