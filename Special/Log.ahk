#Include Movable.ahk

Class Log Extends Movable {
  __New(rect, direction) {
    Super.__New(rect, direction, 1.7)
  }
}

Class Logs {
  __New(originRect, spawnX, spawnY, direction) {
    This.originRect := originRect
    This.logsList := []
    Loop 4 {
      i := A_Index
      This.logsList.Push(
        Log(Rectangle(spawnX+350*i*direction, spawnY, 128, 64), direction)
      )
    }
  }
  
  update(mapWidth, ballX, ballY, ballRadius) {
    collides := 0
    For i, l In This.logsList {
      l.move(mapWidth)
      If l.collides(ballX, ballY, ballRadius) {
        collides := i
      }
    }
    Return collides > 0 ? This.logsList[collides] : 0
  }

  draw(texture) {
    For l In This.logsList {
      l.drawTexture(texture, This.originRect, l.rect,
        Vector2(0, 0),
        0.0, Color(255, 255, 255)
      )
      ;l.draw()
    }
  }
}