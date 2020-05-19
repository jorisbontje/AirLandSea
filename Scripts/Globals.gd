extends Node

const VERSION = "AirLandSea 0.1.6"
const DEAL_COUNT = 6
const BATTLE_SCORE = 6
const WIN_SCORE = 12
const FACEDOWN_STRENGTH = 2

enum THEATERS {NONE, AIR = 1, LAND, SEA}
enum PLAYERS {P1 = 1, P2}
enum SIDES {OPPONENT, PLAYER}
enum ACTIONS {NONE, PLAY_FACEUP, PLAY_FACEDOWN}

var theater_ids = {'air': THEATERS.AIR, 'land': THEATERS.LAND, 'sea': THEATERS.SEA}
