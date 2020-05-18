tool
extends VBoxContainer

export var player_nr = 0 setget set_player_nr
export var score = 0 setget set_score
export var show_hand = true setget set_show_hand

onready var CardRowContainer = find_node("CardRowContainer")
onready var UnitCard = preload("res://Scenes/UnitCard.tscn")

var hand = []

func set_player_nr(new_player_nr):
  player_nr = new_player_nr
  $HBoxContainer/PlayerLabel.text = "Player " + str(player_nr)
  print("Setting player_nr to ", player_nr)
#  if player_nr == 1:
#    $CardRow.color = Color.aliceblue
#  elif player_nr == 2:
#    $CardRow.color = Color.aqua
#  else:
#    $CardRow.color = Color.black

func set_score(new_score):
  if score != new_score:
    score = new_score
    $HBoxContainer/ScoreLabel.text = str(score) + " of 12 points"
    print("Setting score to ", score)

func set_show_hand(new_show_hand):
  if show_hand != new_show_hand:
    show_hand = new_show_hand
    $CardRow.visible = show_hand

func clear():
  for c in CardRowContainer.get_children():
    c.queue_free()
  hand.clear()

func select_card(nr):
  if nr > hand.size():
    print("Card #" + str(nr) + " not in hand")
    return
  hand[nr - 1].obj._on_UnitCard_pressed()

func deal_card(card):
#  print("Dealing card ", card)
  var c = UnitCard.instance()
  card.faceup = true
  c.card = card
  card.obj = c
  CardRowContainer.add_child(c)
  hand.append(card)

func take_card(card):
  print("HAND: ", hand)
  var idx = hand.find(card)
  if idx != -1:
    hand[idx].obj.queue_free()
    hand.remove(idx)
    return true
  return false
