tool
extends VBoxContainer

export var player_nr = 0 setget set_player_nr
export var score = 0 setget set_score

func set_player_nr(new_player_nr):
  if player_nr != new_player_nr:
    player_nr = new_player_nr
    $HBoxContainer/PlayerLabel.text = "Player " + str(player_nr)
    print("Setting player_nr to ", player_nr)
    if player_nr == 1:
      $CardRow.color = Color.aliceblue
    elif player_nr == 2:
      $CardRow.color = Color.aqua
    else:
      $CardRow.color = Color.black

func set_score(new_score):
  if score != new_score:
    score = new_score
    $HBoxContainer/ScoreLabel.text = str(score) + " of 12 points"
    print("Setting score to ", score)
