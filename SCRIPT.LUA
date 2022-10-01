collectgarbage()
splash.show("OneLogoPow.png")
color.loadpalette()

if not img then img=image.load("MainMenu.png") end

option = 1
buttons.interval(40,10)

while true do
buttons.read()

if img then img:blit(0,0) end

if option == 1 then screen.print(240,212,"Start Game",0.6,color.orange,color.yellow,__ACENTER)
else screen.print(240,212,"Start Game",0.6,color.orange,0,__ACENTER)
end

if option == 2 then screen.print(240,224,"Options",0.6,color.orange,color.yellow,__ACENTER)
else screen.print(240,224,"Options",0.6,color.orange,0,__ACENTER)
end

if option == 3 then screen.print(240,236,"High Scores",0.6,color.orange,color.yellow,__ACENTER)
else screen.print(240,236,"High Scores",0.6,color.orange,0,__ACENTER)
end

if option == 4 then screen.print(240,248,"Credits",0.6,color.orange,color.yellow,__ACENTER)
else screen.print(240,248,"Credits",0.6,color.orange,0,__ACENTER)
end


if buttons.down then option += 1
elseif buttons.up then option -= 1
end

if option < 1 then option = 4
elseif option > 4 then option = 1
end

if buttons.cross then
    if option == 1 then dofile("3d/script.lua")
    elseif option == 2 then dofile("3d/script.lua")
    elseif option == 3 then dofile("3d/script.lua")
    elseif option == 4 then dofile("3d/script.lua")
    end
end

screen.flip()
end

