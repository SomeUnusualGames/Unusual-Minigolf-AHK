#Include ../Raylib/Rectangle.ahk
#Include ../Raylib/Color.ahk
#Include ../Raylib/Vector2.ahk

Class Movable {
  __New(rect, direction, speed) {
    This.rect := rect
    This.direction := direction
    This.speed := speed
  }

  move(mapWidth) {
    This.rect["x"] += This.direction * This.speed
    If This.rect["x"] < -132 {
      This.rect["x"] := mapWidth+132
    } Else If This.rect["x"] > mapWidth+132 {
      This.rect["x"] := -132
    }
  }

  collides(x, y, radius) {
    Return rl.CheckCollisionCircleRec(Vector2(x, y), radius, This.rect)
  }

  draw() {
    rl.DrawRectangleRec(
      This.rect, Color(255, 255, 255, 150)
    )
  }

  drawTexture(texture, source, dest, origin, rotation, color) {
    rl.DrawTexturePro(texture, source, dest, origin, rotation, color)
  }
}