#Include Menu/Button.ahk

Class MainMenu {  
  __New() {
    This.menuState := {
      main: 0,
      originalLvlSelect: 1,
      customLvlSelect: 2
    }
    This.state := This.menuState.main
    This.play := Button("Play", 600, 400, 40)
    This.customLvl := Button("Custom", 600, 550, 30)
    This.exit := Button("Exit", 600, 700, 40)
    This.logoY := 0
    This.exitGame := False
  }

  update() {
  }

  drawBackground(mapTexture) {
    Loop 15 {
      y := A_Index
      Loop 20 {
        x := A_Index
        rl.DrawTexturePro(
          mapTexture,
          Rectangle(0, 0, 16, 16),
          Rectangle((x-1)*64, (y-1)*64, 64, 64),
          Vector2(0, 0), 0.0, Color(255, 255, 255)
        )
      }
    }
  }

  draw(mapTexture) {
    This.drawBackground(mapTexture)
    Switch This.state {
      Case This.menuState.main:
        This.logoY := Sin(Abs(10*A_Sec))
        rl.DrawTexturePro(
          mapTexture,
          Rectangle(0, 64, 496, 126),
          Rectangle(450, 50+This.logoY, 2*496, 2*126),
          Vector2(0, 0), 0.0, Color(255, 255, 255)
        )
        This.play.draw()
        This.customLvl.draw()
        This.exit.draw()    
    }
  }
}