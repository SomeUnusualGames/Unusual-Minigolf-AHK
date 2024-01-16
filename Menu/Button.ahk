#Include ../Utils.ahk

Class Button {
  __New(label, x, y, size) {
    This.label := label
    This.x := x
    This.y := y
    This.size := size
    w := 2*(rl.MeasureText(This.label) + This.size)
    h := 2*This.size
    This.bgRect := Rectangle(This.x, This.y, w, h)
  }

  clicked() {
    mouseX := rl.GetMouseX()
    mouseY := rl.GetMouseY()
    coll := Utils.collisionPointRec(This.bgRect, mouseX, mouseY)
    Return rl.IsMouseButtonPressed(0) And coll
  }

  draw() {
    mouseX := rl.GetMouseX()
    mouseY := rl.GetMouseY()
    coll := Utils.collisionPointRec(This.bgRect, mouseX, mouseY)
    bgColor := Color(120, 120, 120)
    If coll {
      bgColor := Color(160, 160, 160)
    }
    rl.DrawRectangleRec(This.bgRect, bgColor)
    rl.DrawText(This.label, This.x+(This.size/2), This.y+(This.size/2), This.size, Color(255, 255, 255))
  }
}