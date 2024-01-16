#Requires AutoHotkey v2.0.3
#Include Raylib.ahk
#Include Rectangle.ahk
#Include Color.ahk

Global rl := Raylib("../raylib.dll")

rl.InitWindow(800, 600, "hello world")
rl.SetTargetFPS(60)

background := Color(0, 0, 0)

While (Not rl.WindowShouldClose()) {
  rl.BeginDrawing()
  rl.ClearBackground(background)
  rl.DrawRectangleRec(Rectangle(100, 100, 100, 100), Color(255, 255, 255))
  rl.EndDrawing()
}

rl.CloseWindow()

