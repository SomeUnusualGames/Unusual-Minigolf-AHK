#Requires AutoHotkey v2.0.3

; This example shows how to detect collision between a circle and a line in any direction and length

#Include ../Raylib/Raylib.ahk
#Include ../Raylib/Color.ahk

Global rl := Raylib("raylib.dll")
rl.InitWindow(1280, 960, "Collision")
rl.SetTargetFPS(60)

wallX1 := 400
wallY1 := 400
wallX2 := 700
wallY2 := 100

ballX := 0
ballY := 0
ballR := 7.0

textX := 550
textY := 500

While (!rl.WindowShouldClose()) {
  ballX := rl.GetMouseX()
  ballY := rl.GetMouseY()

  dx := wallX2 - wallX1
  dy := wallY2 - wallY1
  ex := ballX - wallX1
  ey := ballY - wallY1

  dotProduct := ex * dx + ey * dy
  lineLength := Sqrt(dx**2 + dy**2)
  projection := dotProduct / lineLength
  projection := Max(0, Min(projection, lineLength))

  closestPointX := wallX1 + (dx * projection) / lineLength
  closestPointY := wallY1 + (dy * projection) / lineLength

  distance := Sqrt((closestPointX - ballX)**2 + (closestPointY - ballY)**2)

  collides := (Floor(distance) <= ballR) ? "True" : "False"

  rl.BeginDrawing()
  rl.ClearBackground(Color(0, 0, 0))
  rl.DrawCircle(ballX, ballY, ballR, Color(255, 255, 255))
  

  rl.DrawLine(ballX, ballY, closestPointX, closestPointY, Color(255, 0, 255))
  ;rl.DrawLine(wallX1, wallY1, dx-projection, dy-projection, Color(255, 0, 255))
  ;rl.DrawLine(wallX1, wallY1, wallX2-projection, wallY2-projection, Color(255, 0, 0))

  rl.DrawLine(wallX1, wallY1, wallX2, wallY2, Color(255, 255, 255))
  
  rl.DrawText("dx", wallX1+dx/2, wallY1, 20.0, Color(255, 255, 0))
  rl.DrawLine(wallX1, wallY1, wallX1+dx, wallY1, Color(255, 255, 0))
  rl.DrawText("dy", wallX2, wallY1+dy/2, 20.0, Color(255, 255, 0))
  rl.DrawLine(wallX2, wallY1, wallX2, wallY1+dy, Color(255, 255, 0))

  rl.DrawText("ex", wallX1+ex/2, wallY1, 20.0, Color(255, 0, 0))
  rl.DrawLine(wallX1, wallY1, wallX1+ex, wallY1, Color(255, 0, 0))
  rl.DrawText("ey", ballX, wallY1+ey/2, 20.0, Color(255, 0, 0))
  rl.DrawLine(ballX, wallY1, ballX, wallY1+ey, Color(255, 0, 0))
  rl.DrawLine(wallX1, wallY1, wallX1+ex, ballY, Color(0, 0, 255))

  rl.DrawCircle(closestPointX, closestPointY, 6.0, Color(0, 255, 255))

  rl.DrawText("dx dy: " . dx . " " . dy, textX, textY, 20, Color(255, 255, 0))
  rl.DrawText("ex ey: " . ex . " " . ey, textX, textY+20, 20, Color(255, 0, 0))
  rl.DrawText("Dot product: " . dotProduct, textX, textY+40, 20, Color(255, 255, 255))
  rl.DrawText("Line length (dx dy): " . lineLength, textX, textY+60, 20, Color(255, 255, 255))
  rl.DrawText("Projection (dot / length): " . projection, textX, textY+80, 20, Color(255, 255, 255))
  rl.DrawText("Closest point: " . closestPointX . " " . closestPointY, textX, textY+100, 20, Color(0, 255, 255))
  rl.DrawText("Distance (ball to closest point): " . distance, textX, textY+120, 20.0, Color(255, 0, 255))
  rl.DrawText("Ball radius: " . ballR, textX, textY+140, 20.0, Color(0, 0, 255))
  rl.DrawText("Collides (Floor(distance) <= ballR): " . collides, textX, textY+160, 20, Color(255, 255, 255))

  rl.EndDrawing()
}
rl.CloseWindow()
ExitApp 0