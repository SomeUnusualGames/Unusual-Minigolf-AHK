Class Wall {
  __New(startPosX, startPosY, endPosX, endPosY) {
    This.startPosX := startPosX
    This.startPosY := startPosY
    This.endPosX := endPosX
    This.endPosY := endPosY
    ;This.normal := (3.141592/2) + Utils.ATan2(This.endPosY-This.startPosY, This.endPosX-This.startPosX)
    This.angle := Utils.ATan2(This.endPosY-This.startPosY, This.endPosX-This.startPosX)
    ;distX := This.endPosX - This.startPosX
    ;distY := This.endPosY - This.startPosY
    ;ang := Utils.ATan2(distY, distX)
    ;This.normalVec := Vector2(This.startPosX+(distX/2)*Cos(ang), This.startPosY+(distY/2)*Sin(ang))
  }

  draw() {
    rl.DrawLine(This.startPosX, This.startPosY, This.endPosX, This.endPosY, Color(255, 255, 255))
  }
}