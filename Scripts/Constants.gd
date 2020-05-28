extends Node

const VERSION = "AirLandSea 0.1.8"
const DEAL_COUNT = 6
const BATTLE_SCORE = 6
const WIN_SCORE = 12
const FACEDOWN_STRENGTH = 2

enum THEATERS {NONE, AIR = 1, LAND, SEA}
enum PLAYERS {P1 = 1, P2}
enum SIDES {OPPONENT, PLAYER}
enum ACTIONS {NONE = 0, PLAY_FACEUP = 1, PLAY_FACEDOWN = 2}
enum STATES {PLAYING, END_BATTLE, END_GAME}

const THEATER_IDS = {'air': THEATERS.AIR, 'land': THEATERS.LAND, 'sea': THEATERS.SEA}
const THEATER_COLORS = {
  THEATERS.NONE: Color.black,
  THEATERS.AIR: Color("#0091B2"),
  "air": Color("#0091B2"),
  THEATERS.LAND: Color("#F37F29"),
  "land": Color("#F37F29"),
  THEATERS.SEA: Color("#89BD2E"),
  "sea": Color("#89BD2E")}
