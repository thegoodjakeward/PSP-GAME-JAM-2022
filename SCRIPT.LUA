collectgarbage()
splash.show("OneLogoPow.png")
color.loadpalette()

img=image.load("MainMenuBackground.png")
img2=image.load("MainMenuBackgroundFlipped.png")
img3=image.load("BugginOutLogo.png")
img4=image.load("MainMenuForeground.png")
img5=image.load("MainMenuForegroundFlipped.png")

titlesong = sound.load("Buggin' Out 2 Intro.mp3")
titlesongloop = sound.load("Buggin' Out 2 Loop.mp3")

option = 1
buttons.interval(40,10)

BackgroundShift = 0
Credits = 0

sound.play(titlesong)

while true do
if sound.endstream(titlesong) then
	if not sound.playing(titlesongloop) then
		sound.play(titlesongloop) end
end
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

if Credits == 0 then
	if option == 1 then screen.print(240,196,"Start Game",0.8,color.white,color.green,__ACENTER)
	else screen.print(240,195,"Start Game",0.6,color.white,0,__ACENTER)
	end

	if option == 2 then screen.print(240,211,"Credits",0.8,color.white,color.green,__ACENTER)
	else screen.print(240,210,"Credits",0.6,color.white,0,__ACENTER)
	end
end

if buttons.down then option += 1
elseif buttons.up then option -= 1
end

if option < 1 then option = 2
elseif option > 2 then option = 1
end

if Credits == 1 then
	screen.print(240,180,"Programming and Music: thegoodjakeward",0.8,color.white,color.green,__ACENTER)
	screen.print(240,195,"3D Modeling: Cobra!",0.8,color.white,color.green,__ACENTER)
	screen.print(240,210,"SFX & Playtesting: graveash",0.8,color.white,color.green,__ACENTER)
	screen.print(240,240,"Press o to return to Main Menu",0.6,color.white,color.green,__ACENTER)
end

if buttons.cross then
    if option == 1 then 
		if sound.playing(titlesong) then sound.stop(titlesong) end
		if sound.playing(titlesongloop) then sound.stop(titlesongloop) end
		dofile("3d/script.lua")
    end
	if option == 2 then
		Credits = 1
	end
end
if buttons.circle then
	Credits = 0
end


screen.flip()
end

