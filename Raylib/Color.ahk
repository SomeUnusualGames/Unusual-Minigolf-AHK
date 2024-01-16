; Source: https://www.autohotkey.com/docs/v1/Objects.htm#Dynamic_Properties

Class Color {
  __New(r, g, b, a:=255) {
    This.RGBA := (a << 24) + (b << 16) + (g << 8) + r
  }

  Static Shift := {A: 24, B: 16, G: 8, R: 0}

  __Item[col] {
    Set => This.RGBA := (Value << Color.Shift.%col%) | (This.RGBA & ~(0xff << Color.Shift.%col%))
    Get => (This.RGBA >> Color.Shift.%col%) & 0xff
  }
}

; Atari 2600 color palette
; Source: https://en.wikipedia.org/wiki/List_of_video_game_console_palettes#NTSC
COLORS := [
  [Color(0, 0, 0), Color(68, 68, 0), Color(112, 40, 0), Color(132, 24, 0), Color(136, 0, 0), Color(120, 0, 92), Color(72, 0, 120), Color(20, 0, 132), Color(0, 0, 136), Color(0, 24, 124), Color(0, 44, 92), Color(0, 60, 44), Color(0, 60, 0), Color(20, 56, 0), Color(44, 48, 0), Color(68, 40, 0), Color(64, 64, 64)],
  [Color(100, 100, 16), Color(132, 68, 20), Color(152, 52, 24), Color(156, 32, 32), Color(140, 32, 116), Color(96, 32, 144), Color(48, 32, 152), Color(28, 32, 156), Color(28, 56, 144), Color(28, 76, 120), Color(28, 92, 72), Color(32, 92, 32), Color(52, 92, 28), Color(76, 80, 28), Color(100, 72, 24), Color(108, 108, 108)],
  [Color(132, 132, 36), Color(152, 92, 40), Color(172, 80, 48), Color(176, 60, 60), Color(160, 60, 136), Color(120, 60, 164), Color(76, 60, 172), Color(56, 64, 176), Color(56, 84, 168), Color(56, 104, 144), Color(56, 124, 100), Color(64, 124, 64), Color(80, 124, 56), Color(104, 112, 52), Color(132, 104, 48), Color(144, 144, 144)],
  [Color(160, 160, 52), Color(172, 120, 60), Color(192, 104, 72), Color(192, 88, 88), Color(176, 88, 156), Color(140, 88, 184), Color(104, 88, 192), Color(80, 92, 192), Color(80, 112, 188), Color(80, 132, 172), Color(80, 156, 128), Color(92, 156, 92), Color(108, 152, 80), Color(132, 140, 76), Color(160, 132, 68), Color(176, 176, 176)],
  [Color(184, 184, 64), Color(188, 140, 76), Color(208, 128, 92), Color(208, 112, 112), Color(192, 112, 176), Color(160, 112, 204), Color(124, 112, 208), Color(104, 116, 208), Color(104, 136, 204), Color(104, 156, 192), Color(104, 180, 148), Color(116, 180, 116), Color(132, 180, 104), Color(156, 168, 100), Color(184, 156, 88), Color(200, 200, 200)],
  [Color(208, 208, 80), Color(204, 160, 92), Color(224, 148, 112), Color(224, 136, 136), Color(208, 132, 192), Color(180, 132, 220), Color(148, 136, 224), Color(124, 140, 224), Color(124, 156, 220), Color(124, 180, 212), Color(124, 208, 172), Color(140, 208, 140), Color(156, 204, 124), Color(180, 192, 120), Color(208, 180, 108), Color(220, 220, 220)],
  [Color(232, 232, 92), Color(220, 180, 104), Color(236, 168, 128), Color(236, 160, 160), Color(220, 156, 208), Color(196, 156, 236), Color(168, 160, 236), Color(144, 164, 236), Color(144, 180, 236), Color(144, 204, 232), Color(144, 228, 192), Color(164, 228, 164), Color(180, 228, 144), Color(204, 212, 136), Color(232, 204, 124), Color(236, 236, 236)],
  [Color(252, 252, 104), Color(236, 200, 120), Color(252, 188, 148), Color(252, 180, 180), Color(236, 176, 224), Color(212, 176, 252), Color(188, 180, 252), Color(164, 184, 252), Color(164, 200, 252), Color(164, 224, 252), Color(164, 252, 212), Color(184, 252, 184), Color(200, 252, 164), Color(224, 236, 156), Color(252, 224, 140)]
]