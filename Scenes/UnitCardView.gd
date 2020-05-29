extends Control

const Constants = preload("res://Scripts/Constants.gd")

var card = null setget set_card

func _update_view():
  if card and card.faceup:
    $AbilityLabel.visible = true
    $Background.color = Constants.THEATER_COLORS[card.type]
    $StrengthLabel.text = str(card.strength)
    $AbilityLabel.text = card.get("ability", "")
    $"DescriptionBox/Description".text = card.get("description", "")
    if "duration" in card:
      $"DescriptionBox/DurationLabel".visible = true
      $"DescriptionBox/DurationLabel".text = card.duration
      if card.duration == "ongoing":
        $AbilityLabel.set("custom_colors/font_color", Color.white)
      elif card.duration == "instant":
        $AbilityLabel.set("custom_colors/font_color", Color.black)
    else:
      $"DescriptionBox/DurationLabel".visible = false
    $BackLabel.visible = false
    $DescriptionBox.visible = true
  else:
    $Background.color = Constants.THEATER_COLORS[Constants.THEATERS.NONE]
    $StrengthLabel.text = "2"
    $AbilityLabel.visible = false
    $"DescriptionBox/DurationLabel".visible = false
    $BackLabel.visible = true
    $DescriptionBox.visible = false

func _ready():
  _update_view()

func set_card(new_card):
  card = new_card
  _update_view()
