extends Control

const Constants = preload("res://Scripts/Constants.gd")

var card = null setget set_card

func _update_view():
  if not card:
    return
  $"unit-cards".frame = card.sprite_id
  $Background.visible = true
  $StrengthLabel.visible = true
  if card.faceup:
    $AbilityLabel.visible = true
    $Background.color = Constants.THEATER_COLORS[card.type]
    $StrengthLabel.text = str(card.strength)
    $AbilityLabel.text = card.get("ability", "")
    $"DescriptionBox/Description".text = card.get("description", "")
    # TODO replace with icons
    if "duration" in card:
      if card.duration == "ongoing":
        $AbilityLabel.text = "∞ " + $AbilityLabel.text
        $AbilityLabel.set("custom_colors/font_color", Color.white)
      elif card.duration == "instant":
        $AbilityLabel.text = "! " + $AbilityLabel.text
        $AbilityLabel.set("custom_colors/font_color", Color.black)
    $BackLabel.visible = false
    $DescriptionBox.visible = true
  else:
    $Background.color = Constants.THEATER_COLORS[Constants.THEATERS.NONE]
    $StrengthLabel.text = "2"
    $AbilityLabel.visible = false
    $BackLabel.visible = true
    $DescriptionBox.visible = false

func set_card(new_card):
  card = new_card
  _update_view()
