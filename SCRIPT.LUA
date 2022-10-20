collectgarbage()
splash.show("OneLogoPow.png")
color.loadpalette()

img=image.load("MainMenuBackground.png")
img2=image.load("MainMenuBackgroundFlipped.png")
img3=image.load("BugginOutLogo.png")
img4=image.load("MainMenuForeground.png")
img5=image.load("MainMenuForegroundFlipped.png")

titlesong = sound.load("Buggin' Out.mp3")

option = 1
buttons.interval(40,10)

BackgroundShift = 0
Enter = 0

--sound.play(titlesong)

while true do
buttons.read()

if BackgroundShift < 240 then
	img:blit(0+BackgroundShift,0)
	img2:blit(-480+BackgroundShift,0)
	img4:blit(0+BackgroundShift*2,0)
	img5:blit(-480+BackgroundShift*2,0)
	BackgroundShift += 0.25
elseif BackgroundShift < 480 then
	img:blit(0+BackgroundShift,0)
	img2:blit(-480+BackgroundShift,0)
	img5:blit(-480+BackgroundShift*2,0)
	img4:blit(-960+BackgroundShift*2,0)
	BackgroundShift += 0.25
elseif BackgroundShift < 720 then
	img2:blit(-480+BackgroundShift,0)
	img:blit(-960+BackgroundShift,0)
	img4:blit(-960+BackgroundShift*2,0)
	img5:blit(-1440+BackgroundShift*2,0)
	BackgroundShift += 0.25
elseif BackgroundShift < 960 then
	img2:blit(-480+BackgroundShift,0)
	img:blit(-960+BackgroundShift,0)
	img5:blit(-1440+BackgroundShift*2,0)
	img4:blit(-1920+BackgroundShift*2,0)
	BackgroundShift += 0.25
elseif BackgroundShift == 960 then
	BackgroundShift = 0
	img:blit(0+BackgroundShift,0)
	img2:blit(-480+BackgroundShift,0)
	img4:blit(0+BackgroundShift*2,0)
	img5:blit(-480+BackgroundShift*2,0)
end

--if Enter < 120 then 
--	img3:blit(-480+Enter*4,0)
--	Enter += 1
--else img3:blit(0,0) end
img3:blit(0,0)

if option == 1 then screen.print(240,186,"Start Game",0.8,color.white,color.green,__ACENTER)
else screen.print(240,185,"Start Game",0.6,color.white,0,__ACENTER)
end

if option == 2 then screen.print(240,201,"Options",0.8,color.white,color.green,__ACENTER)
else screen.print(240,200,"Options",0.6,color.white,0,__ACENTER)
end

if option == 3 then screen.print(240,216,"High Scores",0.8,color.white,color.green,__ACENTER)
else screen.print(240,215,"High Scores",0.6,color.white,0,__ACENTER)
end

if option == 4 then screen.print(240,231,"Credits",0.8,color.white,color.green,__ACENTER)
else screen.print(240,230,"Credits",0.6,color.white,0,__ACENTER)
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

