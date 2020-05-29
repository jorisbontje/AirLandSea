extends Node

signal card_focussed
signal card_selected

const Constants = preload("res://Scripts/Constants.gd")
const RandomAI = preload("res://Scripts/RandomAI.gd")

var theaters = [
  Constants.THEATERS.AIR, Constants.THEATERS.LAND, Constants.THEATERS.SEA]
var deck: Array
var default_deck: Array
var theater_lanes = []
var player_hands = []
var players = [Constants.PLAYERS.P1, Constants.PLAYERS.P2]
var player_names = []
var scores = [0, 0]
var ai_player = RandomAI.new(self)

var game_state = Constants.STATES.PLAYING
var current_player = Constants.PLAYERS.P1
var current_side = Constants.SIDES.PLAYER

var selected_action = Constants.ACTIONS.NONE
var selected_card = null
var selected_theater = Constants.THEATERS.NONE

onready var NewGameButton = find_node("NewGameButton")
onready var LogLabel = find_node("LogLabel")
onready var VersionLabel = find_node("VersionLabel")
onready var ActionPrompt = find_node("ActionPrompt")

onready var OpponentHand = find_node("OpponentHand")
onready var PlayerHand = find_node("PlayerHand")

onready var TheaterLane1 = find_node("TheaterLane1")
onready var TheaterLane2 = find_node("TheaterLane2")
onready var TheaterLane3 = find_node("TheaterLane3")

onready var UnitCardZoom = find_node("UnitCardZoom")
onready var WithdrawButton = find_node("WithdrawButton")
onready var PlayFaceupButton = find_node("PlayFaceupButton")
onready var PlayFacedownButton = find_node("PlayFacedownButton")

func _load_cards() -> Array:
  var file := File.new()
  var err = file.open("res://cards.json", file.READ)
  if err:
    push_error("Can't open cards.json")
    return []

  var text = file.get_as_text()
  file.close()
  return parse_json(text)

func _new_game():
  LogLabel.clear()
  log_text("NEW GAME")
  theaters.shuffle()
  players.shuffle()
  scores = [0, 0]
  _new_round()

func _next_battle():
  LogLabel.clear()
  log_text("NEXT BATTLE")
  players.push_front(players.pop_back())
  theaters.push_front(theaters.pop_back())

func _new_round():
  log_text("READY PLAYER ONE")
  deck = default_deck.duplicate()
  deck.shuffle()

  for lane_nr in range(3):
    theater_lanes[lane_nr].theater_type = theaters[lane_nr]
    theater_lanes[lane_nr].clear()

  UnitCardZoom.deselect()
  OpponentHand.clear()
  PlayerHand.clear()

  OpponentHand.is_first = players[Constants.SIDES.OPPONENT] == Constants.PLAYERS.P1
  PlayerHand.is_first = players[Constants.SIDES.PLAYER] == Constants.PLAYERS.P1

  current_player = Constants.PLAYERS.P1
  if current_player == players[Constants.SIDES.PLAYER]:
    current_side = Constants.SIDES.PLAYER
  else:
    current_side = Constants.SIDES.OPPONENT

  OpponentHand.show_hand = current_side == Constants.SIDES.OPPONENT
  PlayerHand.show_hand = current_side == Constants.SIDES.PLAYER

  OpponentHand.score = scores[Constants.SIDES.OPPONENT]
  PlayerHand.score = scores[Constants.SIDES.PLAYER]

  # Deal cards
  for _i in range(Constants.DEAL_COUNT):
    OpponentHand.deal_card(deck.pop_back())
    PlayerHand.deal_card(deck.pop_back())

  game_state = Constants.STATES.PLAYING
  NewGameButton.text = "Restart Game"
  ActionPrompt.text = "Select a card from your hand to play."
  WithdrawButton.disabled = false
  var withdraw_score = calc_withdraw_score(current_player, Constants.DEAL_COUNT)
  WithdrawButton.text = "Withdraw (-" + str(withdraw_score) + " pt)"

  if current_side == Constants.SIDES.OPPONENT:
    call_deferred("_auto_play")

func _other_side(side):
  return 1 - side

func _other_player(player):
  return 3 - player

func _score_points(side, score):
  scores[side] += score
  player_hands[side].score = scores[side]

func _find_winner_side():
  var opponent_wins = 0
  var player_wins = 0
  for theater_lane in theater_lanes:
    if theater_lane.opponent_strength > theater_lane.player_strength:
      opponent_wins += 1
    elif theater_lane.player_strength > theater_lane.opponent_strength:
      player_wins += 1
    else:
      if OpponentHand.is_first:
        opponent_wins += 1
      else:
        player_wins += 1

  if opponent_wins >= 2:
    return Constants.SIDES.OPPONENT
  elif player_wins >= 2:
    return Constants.SIDES.PLAYER
  else:
    push_error("No winner")
    return

func game_over():
  var winner_side = _find_winner_side()
  log_text(player_names[winner_side] + " controls at least 2 theaters and scores " + str(Constants.BATTLE_SCORE) + " points.")
  _score_points(winner_side, Constants.BATTLE_SCORE)

  PlayerHand.show_hand = false
  OpponentHand.show_hand = false

  should_play_next_battle()

func _deselect_all():
  selected_action = Constants.ACTIONS.NONE
  selected_theater = Constants.THEATERS.NONE
  card_selected(null)

  for theater_lane in theater_lanes:
    theater_lane.deselect()

func _next_turn():
  ActionPrompt.text = "Select a card from your hand to play."
  current_player = _other_player(current_player)
  current_side = _other_side(current_side)
  OpponentHand.show_hand = current_side == Constants.SIDES.OPPONENT
  PlayerHand.show_hand = current_side == Constants.SIDES.PLAYER

  _deselect_all()

  var cards_left = player_hands[current_side].hand.size()
  if cards_left == 0:
    log_text("End of battle... counting scores")
    game_over()
    return

  var withdraw_score = calc_withdraw_score(current_player, cards_left)
  WithdrawButton.text = "Withdraw (-" + str(withdraw_score) + " pt)"

  if current_side == Constants.SIDES.OPPONENT:
    call_deferred("_auto_play")

func log_text(line):
  print(line)
  LogLabel.add_text(line)
  LogLabel.newline()

func _ready():
  VersionLabel.text = Constants.VERSION
  randomize()

  player_hands = [OpponentHand, PlayerHand]
  player_names = [OpponentHand.player_name, PlayerHand.player_name]
  theater_lanes = [TheaterLane1, TheaterLane2, TheaterLane3]
  default_deck = _load_cards()
  _new_game()

func _select_theater_lane(theater_type, select=true):
  for theater_lane in theater_lanes:
    if theater_lane.theater_type == theater_type:
      if select:
        theater_lane.select()
      else:
        theater_lane.deselect()

func card_focussed(card):
  emit_signal("card_focussed", card)

func card_selected(card):
  emit_signal("card_selected", card)
  if selected_card:
    selected_card.obj.deselect()

  selected_card = card

  if card == null:
    ActionPrompt.text = "Select a card from your hand to play."
    PlayFaceupButton.disabled = true
    PlayFacedownButton.disabled = true
  else:
    ActionPrompt.text = "Play this card faceup or facedown?"
    PlayFaceupButton.disabled = false
    PlayFacedownButton.disabled = false

func theater_selected(theater_type):
  if selected_theater:
    _select_theater_lane(selected_theater, false)

  selected_theater = theater_type

  if theater_type:
    if selected_action:
      play_card(selected_action, selected_card, selected_theater)
    elif selected_card:
      ActionPrompt.text = "Play this card faceup or facedown?"
    else:
      ActionPrompt.text = "Select a card from your hand to play."

func is_action_playable(action, card, theater_id):
  if action == Constants.ACTIONS.PLAY_FACEDOWN:
    return true
  elif action == Constants.ACTIONS.PLAY_FACEUP and Constants.THEATER_IDS[card.type] == theater_id:
    return true
  return false

func play_card(action, card, theater):
  # check if it can be played
  if not is_action_playable(action, card, theater):
    log_text("Can't play this action here...")
    _deselect_all()
    return

  # remove card from hand
  var card_in_hand = player_hands[current_side].take_card(card)
  if not card_in_hand:
    log_text("Couldn't find card in hand...")
    return

  if action == Constants.ACTIONS.PLAY_FACEUP:
    log_text(player_names[current_side] + " plays " + card.type.to_upper() + " " + str(card.strength) + " on " + Constants.THEATERS.keys()[theater])
  else:
    log_text(player_names[current_side] + " plays face down on " + Constants.THEATERS.keys()[theater])

  card.faceup = (action == Constants.ACTIONS.PLAY_FACEUP)

  # add card to board
  for theater_lane in theater_lanes:
    if theater == theater_lane.theater_type:
      theater_lane.play_card(current_side, card)

  # TODO if played faceup perform tactical abilities

  _next_turn()

func _auto_play():
  if game_state == Constants.STATES.PLAYING:
    log_text("Beep boop boop...")
    ai_player.play()

func calc_withdraw_score(player, cards_left):
#  print(player, " ", cards_left)
  if player == Constants.PLAYERS.P1:
    if cards_left >= 4:
      return 2
    elif cards_left >= 2:
      return 3
    elif cards_left == 1:
      return 4
    else:
      return 6
  else:
    if cards_left >= 5:
      return 2
    elif cards_left >= 3:
      return 3
    elif cards_left == 2:
      return 4
    else:
      return 6

func show_winner():
  var winning_side
  if scores[Constants.SIDES.PLAYER] >= Constants.WIN_SCORE:
    winning_side = Constants.SIDES.PLAYER
  else:
    winning_side = Constants.SIDES.OPPONENT
  log_text(player_names[winning_side] + " wins the game!")

func should_play_next_battle():
  if scores[Constants.SIDES.OPPONENT] >= Constants.WIN_SCORE or scores[Constants.SIDES.PLAYER] >= Constants.WIN_SCORE:
    show_winner()
    game_state = Constants.STATES.END_GAME
    NewGameButton.text = "New Game"
    ActionPrompt.text = "Ready for a new game?"
  else:
    game_state = Constants.STATES.END_BATTLE
    NewGameButton.text = "Next Battle"
    ActionPrompt.text = "Ready for the next battle?"

  WithdrawButton.disabled = true
  PlayFaceupButton.disabled = true
  PlayFacedownButton.disabled = true

func play_withdraw():
  var cards_left = player_hands[current_side].hand.size()
  log_text(player_names[current_side] + " withdraws with " + str(cards_left) + " cards left.")

  var score = calc_withdraw_score(current_player, cards_left)
  log_text(player_names[_other_side(current_side)] + " scores " + str(score) + " from withdraw.")

  _score_points(_other_side(current_side), score)
  _deselect_all()
  should_play_next_battle()


func _on_NewGameButton_pressed():
  if game_state == Constants.STATES.END_BATTLE:
    _next_battle()
    _new_round()
  else:
    _new_game()

func _on_PlayFaceupButton_pressed():
  selected_action = Constants.ACTIONS.PLAY_FACEUP
  if selected_theater:
    play_card(selected_action, selected_card, selected_theater)
  else:
    ActionPrompt.text = "Select a matching theater to play"

func _on_PlayFacedownButton_pressed():
  selected_action = Constants.ACTIONS.PLAY_FACEDOWN
  if selected_theater:
    play_card(selected_action, selected_card, selected_theater)
  else:
    ActionPrompt.text = "Select any theater to play"

func _on_WithdrawButton_pressed():
  play_withdraw()

func _input(_event):
  if Input.is_action_pressed("ui_cancel"):
    get_tree().quit()
  elif Input.is_action_pressed("ui_select_1"):
    player_hands[current_side].select_card(1)
  elif Input.is_action_pressed("ui_select_2"):
    player_hands[current_side].select_card(2)
  elif Input.is_action_pressed("ui_select_3"):
    player_hands[current_side].select_card(3)
  elif Input.is_action_pressed("ui_select_4"):
    player_hands[current_side].select_card(4)
  elif Input.is_action_pressed("ui_select_5"):
    player_hands[current_side].select_card(5)
  elif Input.is_action_pressed("ui_select_6"):
    player_hands[current_side].select_card(6)
  elif Input.is_action_pressed("ui_select_air"):
    _select_theater_lane(Constants.THEATERS.AIR)
  elif Input.is_action_pressed("ui_select_land"):
    _select_theater_lane(Constants.THEATERS.LAND)
  elif Input.is_action_pressed("ui_select_sea"):
    _select_theater_lane(Constants.THEATERS.SEA)
  elif Input.is_action_pressed("ui_auto_play"):
    call_deferred("_auto_play")

func _on_CenterContainer_gui_input(event):
  if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.pressed:
    card_selected(null)
