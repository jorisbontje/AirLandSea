extends Node

const Constants = preload("res://Scripts/Constants.gd")

var game

func _init(_game):
  game = _game

# Called when the node enters the scene tree for the first time.
func play():
  var card = game.player_hands[game.current_side].hand[0]
  print("Random AI selected card: ", card)

  var theater_id = Constants.THEATERS[card.type.to_upper()]
  game.play_card(Constants.ACTIONS.PLAY_FACEUP, card, theater_id)
