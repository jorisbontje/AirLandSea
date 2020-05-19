extends Node

signal card_focussed
signal card_selected


const VERSION = "AirLandSea 0.1.2"
const DEAL_COUNT = 6
const WIN_SCORE = 12

enum THEATERS {NONE, AIR = 1, LAND, SEA}
enum PLAYERS {P1 = 1, P2}
enum SIDES {OPPONENT, PLAYER}
enum ACTIONS {NONE, PLAY_FACEUP, PLAY_FACEDOWN}

var theater_ids = {'air': THEATERS.AIR, 'land': THEATERS.LAND, 'sea': THEATERS.SEA}
var theaters = [THEATERS.AIR, THEATERS.LAND, THEATERS.SEA]
var deck: Array
var default_deck: Array
var theater_lanes = []
var player_hands = []
var players = [PLAYERS.P1, PLAYERS.P2]
var scores = [0, 0]
var current_player = PLAYERS.P1
var current_side = SIDES.PLAYER
var selected_action = ACTIONS.NONE
var selected_card = null
var selected_theater = THEATERS.NONE

onready var LogLabel = find_node("LogLabel")
onready var VersionLabel = find_node("VersionLabel")
onready var ActionPrompt = find_node("ActionPrompt")

onready var OpponentHand = find_node("OpponentHand")
onready var PlayerHand = find_node("PlayerHand")

onready var TheaterLane1 = find_node("TheaterLane1")
onready var TheaterLane2 = find_node("TheaterLane2")
onready var TheaterLane3 = find_node("TheaterLane3")

onready var UnitCardView = find_node("UnitCardView")
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
  log_text("NEW GAME")
  theaters.shuffle()
  players.shuffle()
  scores = [0, 0]
  _new_round()

func _next_battle():
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

  UnitCardView.deselect()
  OpponentHand.clear()
  PlayerHand.clear()

  OpponentHand.is_first = players[SIDES.OPPONENT] == PLAYERS.P1
  PlayerHand.is_first = players[SIDES.PLAYER] == PLAYERS.P1

  current_player = PLAYERS.P1
  if current_player == players[SIDES.PLAYER]:
    current_side = SIDES.PLAYER
  else:
    current_side = SIDES.OPPONENT

  OpponentHand.show_hand = current_side == SIDES.OPPONENT
  PlayerHand.show_hand = current_side == SIDES.PLAYER

  # Deal cards
  for _i in range(DEAL_COUNT):
    OpponentHand.deal_card(deck.pop_back())
    PlayerHand.deal_card(deck.pop_back())

func _other_side(side):
  return 1 - side

func _other_player(player):
  return 3 - player

func _next_turn():
#  ActionPrompt.text = "Select a card from your hand to play."
  current_player = _other_player(current_player)
  current_side = _other_side(current_side)
  OpponentHand.show_hand = current_side == SIDES.OPPONENT
  PlayerHand.show_hand = current_side == SIDES.PLAYER

  # deselect
  selected_action = ACTIONS.NONE
  selected_card = null
  selected_theater = THEATERS.NONE

  card_selected(null)

  for theater_lane in theater_lanes:
    theater_lane.deselect()

func log_text(line):
  print(line)
  LogLabel.add_text(line)
  LogLabel.newline()

func _ready():
  VersionLabel.text = VERSION
  randomize()

  player_hands = [OpponentHand, PlayerHand]
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

func card_nr_focussed(card_nr):
  emit_signal("card_focussed", card_nr)

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
  print(card, theater_id)
  if action == ACTIONS.PLAY_FACEDOWN:
    return true
  elif action == ACTIONS.PLAY_FACEUP and theater_ids[card.type] == theater_id:
    return true
  return false

func play_card(action, card, theater):
#  print("PLAY: ", ACTIONS.keys()[action], " ", card, " ", THEATERS.keys()[theater])

  # check if it can be played
  if not is_action_playable(action, card, theater):
    log_text("Can't play this action here...")
    return

  # remove card from hand
  var card_in_hand = player_hands[current_side].take_card(card)
  if not card_in_hand:
    log_text("Couldn't find card in hand...")
    return

  card.faceup = (action == ACTIONS.PLAY_FACEUP)

  # add card to board
  for theater_lane in theater_lanes:
    if theater == theater_lane.theater_type:
      theater_lane.play_card(current_side, card)

  # if played faceup perform tactical abilities
  # TODO

  # next turn
  _next_turn()

func calc_withdraw_score(player, cards_left):
  print(player, " ", cards_left)
  if player == PLAYERS.P1:
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
  if scores[SIDES.PLAYER] >= WIN_SCORE:
    log_text("Player wins!")
  else:
    log_text("Opponent wins!")

func play_withdraw():
  var cards_left = player_hands[current_side].hand.size()
  print("CARDS LEFT ", cards_left)

  var score = calc_withdraw_score(current_player, cards_left)
  log_text("Player " + str(_other_player(current_player)) + " scores " + str(score) + " from withdraw.")
  scores[_other_side(current_side)] += score
  player_hands[_other_side(current_side)].score = scores[_other_side(current_side)]
  if scores[_other_side(current_side)] >= WIN_SCORE:
    show_winner()
  else:
    _next_battle()
    _new_round()


func _on_NewGameButton_pressed():
  _new_game()

func _on_PlayFaceupButton_pressed():
  log_text("PLAY FACEUP")
  selected_action = ACTIONS.PLAY_FACEUP
  if selected_theater:
    play_card(selected_action, selected_card, selected_theater)
  else:
    ActionPrompt.text = "Select a matching theater to play"

func _on_PlayFacedownButton_pressed():
  log_text("PLAY FACEDOWN")
  selected_action = ACTIONS.PLAY_FACEDOWN
  if selected_theater:
    play_card(selected_action, selected_card, selected_theater)
  else:
    ActionPrompt.text = "Select any theater to play"

func _on_WithdrawButton_pressed():
  log_text("WITHDRAW")
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
    _select_theater_lane(THEATERS.AIR)
  elif Input.is_action_pressed("ui_select_land"):
    _select_theater_lane(THEATERS.LAND)
  elif Input.is_action_pressed("ui_select_sea"):
    _select_theater_lane(THEATERS.SEA)

func _on_CenterContainer_gui_input(event):
  if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.pressed:
    card_selected(null)
