#Include Menu.ahk
#Include Map.ahk
#Include Ball.ahk

State := {
  menu: 0,
  play: 1,
  playWon: 2
}

Global mapNames := [
  "Question Mark",
  "Groffer",
  "Spikes!",
  "Two Holes!?",
  "Portals"
]

Global customNames := []

Class Game {
  __New() {
    This.currentMap := GolfMap(20, 15, 1, "assets/graphics/tiles2.png", False)
    This.currentBall := Ball(This.currentMap.ballSpawnX, This.currentMap.ballSpawnY)
    This.menu := MainMenu()
    This.hitLevels := [0, 0, 0, 0, 0]
    This.hitSum := 0
    This.state := State.menu
    This.customMaps := []
  }

  update() {
    Switch This.state {
      Case State.menu:
        If This.menu.play.clicked() {
          This.currentBall.resetPosition(This.currentMap)
          This.state := State.play
        }
        If This.menu.customLvl.clicked() {
          This.customMaps := []
          Global customNames := []
          Loop Files "custom/*" {
            customNames.Push(A_LoopFileName)
            This.customMaps.Push(A_LoopFilePath)
          }
          This.currentBall.resetPosition(This.currentMap)
          This.currentMap := GolfMap(20, 15, 1, "assets/graphics/tiles2.png", True)
          This.currentBall := Ball(This.currentMap.ballSpawnX, This.currentMap.ballSpawnY)
          This.state := State.play
        }
        If This.menu.exit.clicked() {
          This.menu.exitGame := True
        }
      Case State.play:
        This.currentBall.update(This.currentMap)
        This.currentMap.update(This.currentBall.moving)
        If This.currentBall.hits == 8 {
          This.currentBall.levelDone := True
        }
        If This.currentBall.levelDone {
          This.hitSum := 0
          This.hitLevels[This.currentMap.currentLvl] := This.currentBall.hits
          For n In This.hitLevels {
            This.hitSum += n
          }
          This.state := State.playWon
        }
      Case State.playWon:
        This.currentMap.update(This.currentBall.moving)
        If rl.IsMouseButtonPressed(1) {
          If This.currentMap.isCustom And This.currentMap.currentLvl == This.currentMap.mapNames.Length {
            This.currentMap.currentLvl := 5
          }
          If This.currentMap.currentLvl == 5 {
            This.currentMap := GolfMap(20, 15, 1, "assets/graphics/tiles2.png", False)
            This.currentBall.levelDone := False
            This.currentBall.hits := 0
            This.hitLevels := [0, 0, 0, 0, 0]
            This.state := State.menu
            Return
          }
          This.currentMap := GolfMap(20, 15, This.currentMap.currentLvl+1, "assets/graphics/tiles2.png", This.currentMap.isCustom)
          This.currentBall.resetPosition(This.currentMap)
          This.currentBall.hits := 0
          This.state := State.play
        }
    }
  }

  drawScore() {
    x := 350
    y := 300
    rl.DrawRectangleRec(Rectangle(x-60, y-30, 640, 270), Color(64, 31, 37))
    rl.DrawText("Hole", x-50, y, 60, Color(255, 255, 255))
    rl.DrawText("Hits", x-50, y+150, 60, Color(255, 255, 255))
    rl.DrawLine(x-60, y+100, (x-60)+640, y+100, Color(0, 0, 0))
    rl.DrawLine(x+90, y-30, x+90, (y-30)+270, Color(0, 0, 0))
    If This.currentMap.currentLvl == 5 Or This.currentMap.isCustom And This.currentMap.currentLvl == This.currentMap.mapNames.Length {
      rl.DrawText("Final score: " . This.hitSum, x, y+300, 80, Color(255, 255, 255))
      rl.DrawText("Thank you for playing!", x, y+500, 80, Color(255, 255, 255))
    } Else If This.currentBall.hits == 8 {
      rl.DrawText("Loser", x, y+300, 80, Color(255, 0, 0))
    }
    For i, n In This.hitLevels {
      rl.DrawText(String(i), x+i*100, y, 80, Color(255, 255, 255))
      rl.DrawText(String(n), x+i*100, y+150, 80, Color(255, 255, 255))
    }
  }

  draw() {
    Switch This.state {
      Case State.menu:
        This.menu.draw(This.currentMap.texture)
      Case State.play:
        This.currentMap.draw(This.currentBall)
        This.currentBall.draw()
      Case State.playWon:
        This.currentMap.draw(This.currentBall)
        This.currentBall.draw()
        This.drawScore()
    }
  }
}