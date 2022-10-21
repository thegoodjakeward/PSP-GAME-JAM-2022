--------------------------------------ONELUA 3D-----------------------------------
TIMER = 0
--INITIATE 
os.cpu(333) --set cpu clock speed
amg.init(__8888)
amg.perspective(60.0)
model3d.initphysics(20,{-100,-100,-100},{100,100,100}) --Maximum objects and max and min world coordinates

--CAMERA
camera1 = cam3d.new()

--LIGHT
amg.typelight(1,__DIRECTIONAL)
amg.colorlight(1,color.new(250,250,250),color.new(90,90,90),color.new(250,250,250))
amg.poslight(1,{0.5,1,0.5})

--LOADING
Ball = model3d.load(files.cdir().."/3d/Data/ball.obj")
--Water = model3d.load(files.cdir().."/3d/Data/plane.obj")
Ramp = model3d.load(files.cdir().."/3d/Data/leve1.obj")
Net = model3d.load(files.cdir().."/3d/Data/net.obj")
Bug = {}
Bug.model = {}
Bug.rendered = {}
Bug.positions = {}
Bug.glitches = {}

speedy = texture3d.load(files.cdir().."/3d/Data/speed.png",1)
reversy = texture3d.load(files.cdir().."/3d/Data/reverse.png",1)
for a = 1,13 do 
	Bug.model[a] = model3d.load(files.cdir().."/3d/Data/bug.obj") 
	if a > 7 and a < 11 then
		texture3d.setcustom(Bug.model[a], 1, 1, speedy)
	end
	if a > 10 then
		texture3d.setcustom(Bug.model[a], 1, 1, reversy)
	end
end

model3d.setphysics(Ball,1,{0,0,0},{0,0,0},2,__SPHERE) --second to last input is mass
--model3d.setphysics(Net,1,{0,0,0},{0,0,0},0,__BOX)
--model3d.setphysics(Water,1,{0,0,0},{0,0,0},0,__BOX) --zero mass indicates immovable
model3d.setphysics(Ramp,1,{0,0,0},{0,0,0},0,__CONVEX)

model3d.physics(Ball)
--model3d.physics(Net)
--model3d.physics(Water)
model3d.physics(Ramp)

model3d.setdamping(Ball,1,0.4,1000000) --sets linear and rotational damping
StartPosition = {-42,1,-50}

blackscreen = image.load(files.cdir().."/3d/blackscreen.png")
level1backgroundNorth = image.load(files.cdir().."/3d/Level1BackgroundNorth.png")
level1backgroundSouth = image.load(files.cdir().."/3d/Level1BackgroundSouth.png")
level1backgroundEast = image.load(files.cdir().."/3d/Level1BackgroundEast.png")
level1backgroundWest = image.load(files.cdir().."/3d/Level1BackgroundWest.png")
HUD = image.load(files.cdir().."/3d/HUD.png")
HUD1 = image.load(files.cdir().."/3d/HUD1_4.png")
HUD2 = image.load(files.cdir().."/3d/HUD2_4.png")
HUD3 = image.load(files.cdir().."/3d/HUD3_4.png")
HUD4 = image.load(files.cdir().."/3d/HUD4_4.png")


--VARIABLES
RotationForCalc = 0; --camera's rotation converted to corresponding quadrant for calcs
SinSign = 0; --used in quadrant calcs
CosSign = 0; --used in quadrant calcs
BugRotation = 0
BugRotation2 = 0
BugRotation3 = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
NetForwardOffset = 3
NetSideOffset = 1
NetVerticalOffset = 0
CameraYAdjustment = 0
NetSwing = 0
NetSwingDown = 0
FallTimer = 0
GroundTimer = 0
BugJumpTimer = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
BugJumpHeight = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
win = 0
endCounter = 100

--LEVEL VARIABLES
Level = 1
Level1Bugs = {}
Level1Bugs.rendered = {true,true,true,true,true,true,true,true,true,true,true,true,true,true,true}
Level1Bugs.positions = {}
Level1Bugs.positions.x = {-33,-48.5, -25.3,  -7.5,  35.9,   -55, -25.5, 0, 17.5, 126.8,-40, 20.4, 36.5}
Level1Bugs.positions.y = { 0,  23.9, 100.4, 116.2, 119.6, 133.2, 153.4, 0, 83.3, 119.3,  0, 59.7, 66.9}
Level1Bugs.positions.z = {-33, 33.4,  39.3, -35.1,  -6.8,   4.1,  -5.4, 0, 32.3,   -15, 30, 50.1, -7.3}
Level1Bugs.glitches = {1,1,1,1,1,1,1,2,2,2,3,3}

--ENUMS
MovementState = {IDLE=0,RUNNING=0,FALLING=0,PAUSED=0,DEAD=0,START=1}
GlitchState = {NOGLITCH=0,NOCOLLISION=0,DOUBLEJUMP=0,HIGHSPEED=0,NOTOP=0,WALLJUMP=0,SLOWTIME=0,REVERSE=0,HIDDENOBJECT=0,NOSTOP=0,STRONGGRAVITY=0,ICEPHYSICS=0,DARKMODE=0}

--TIMER
timer1 = timer.new()
timer.start(timer1)
timer2 = timer.new()
timer.stop(timer2)

levelsong = sound.load("/3d/Buggin' Out.mp3")
jumpsound = sound.load("/3d/jump1.mp3")
netsound = sound.load("/3d/Swing1.mp3")
goodsound = sound.load("/3d/good1.mp3")
yaysound = sound.load("/3d/Yay1.mp3")

while true do
	--level initialization stuff
	if MovementState.START==1 then
		sound.play(levelsong)
		if Level==1 then
			Rotation = 0.3607570512; --camera's rotation
			for a = 1,13 do 
				if Level1Bugs.rendered[a] then
					Bug.positions = Level1Bugs.positions
					model3d.position(Bug.model[a],1,{Bug.positions.x[a],Bug.positions.y[a],Bug.positions.z[a]}) 
					Bug.rendered[a] = Level1Bugs.rendered[a]
					Bug.glitches[a] = Level1Bugs.glitches[a]
				end
			end
			model3d.position(Ball,1,StartPosition)
			MovementState.START = 0
			BugsLeft = 13
		end
	end
	
	amg.begin() --begin 3d
	amg.gravity(0,-9.8,0) --set gravity
	
	BallP = model3d.getposition(Ball,1) --grab position of character
	BallV = model3d.getvelocity(Ball,1) --grab veloctiy of character
	
	if Rotation > 2*math.pi then Rotation=0 --wrap around if rotation exceeds 2pi or goes below zero
	elseif Rotation < 0 then Rotation = 2*math.pi end
	if BugRotation > 2*math.pi then BugRotation = 0 
	elseif BugRotation < 0 then BugRotation = 2*math.pi end
	if BugRotation2 > 2*math.pi then BugRotation2 = 0 
	elseif BugRotation2 < 0 then BugRotation2 = 2*math.pi end
	
	cam3d.position(camera1,{BallP.x,BallP.y+0.8,BallP.z}) --set camera to players position
	cam3d.eye(camera1,{10*math.sin(Rotation)+BallP.x,BallP.y+0.8+CameraYAdjustment,10*math.cos(Rotation)+BallP.z}) --set camera's looking direction
	
	--calculate rotation angle for movement calculations based on quadrant
	if Rotation < math.pi/2 then 
		RotationForCalc = Rotation
		SinSign = 1
		CosSign = 1
	elseif Rotation < math.pi then 
		RotationForCalc = math.pi - Rotation
		SinSign = 1
		CosSign = -1
	elseif Rotation < 3*math.pi/2 then 
		RotationForCalc = Rotation-math.pi
		SinSign = -1
		CosSign = -1		
	else 
		RotationForCalc = 2*math.pi - Rotation 
		SinSign = -1
		CosSign = 1
	end
	
	--determine movement state
	if math.sqrt(BallV.x*BallV.x + BallV.z*BallV.z) > 0.01 then 
		MovementState.IDLE = 0
		MovementState.RUNNING = 1
	else 
		MovementState.IDLE = 1
		MovementState.RUNNING = 0
	end
	if math.abs(BallV.y) > 0.05 then
		FallTimer += 1
	else
		FallTimer = 0
		GroundTimer += 1
	end
	if FallTimer > 40 then
		MovementState.IDLE = 0
		MovementState.FALLING = 1
		GroundTimer = 0
	end
	if GroundTimer > 3 then
		MovementState.FALLING = 0
	else
		MovementState.FALLING = 1
	end
	
	--if MovementState.FALLING == 0 then CameraYAdjustment = CameraYAdjustment/1.08
	--elseif CameraYAdjustment > -2 then CameraYAdjustment += -0.05 end
	
	--enforce top speed
	if (BallV.x*BallV.x + BallV.z*BallV.z) > 400 and GlitchState.HIGHSPEED == 0  then 
		BallV.z = BallV.z*0.97
		BallV.x = BallV.x*0.97
	end
	
	--bug movement
	for a = 1,7 do
		if Bug.rendered[a] then
			TempBugP = 0
			TempBugP = model3d.getposition(Bug.model[a],1)
			if math.sqrt(((TempBugP.x+0.06*math.sin(BugRotation)-Bug.positions.x[a])^2)+((TempBugP.z+0.06*math.cos(BugRotation)-Bug.positions.z[a])^2)) > 2 then
				BugRotation += math.pi/1.5
			end
			if TempBugP.y + BugJumpHeight[a] < Bug.positions.y[a] then
				BugJumpHeight[a] = 0
				--model3d.position(Bug.model[a],1,{TempBugP.x,Bug.positions.y[a],TempBugP.z})	
			end
			if math.sqrt(((TempBugP.x+0.06*math.sin(BugRotation)-Bug.positions.x[a])^2)+((TempBugP.z+0.06*math.cos(BugRotation)-Bug.positions.z[a])^2)) < 2 then
				model3d.position(Bug.model[a],1,{TempBugP.x+0.04*math.sin(BugRotation),TempBugP.y+BugJumpHeight[a],TempBugP.z+0.04*math.cos(BugRotation)})	
				model3d.rotation(Bug.model[a],1,{0,BugRotation*180/math.pi,0})
			end
			if BugJumpTimer[a] == 0 then
				BugJumpHeight[a] = 0.8
				BugJumpTimer[a] = 100
			else
				BugJumpHeight[a] -= 0.05
				BugJumpTimer[a] -= 1
			end
		end
	end
	for a = 8,10 do
		if Bug.rendered[a] then
			TempBugP = 0
			TempBugP = model3d.getposition(Bug.model[a],1)
			if math.sqrt(((TempBugP.x+0.18*math.sin(BugRotation2)-Bug.positions.x[a])^2)+((TempBugP.z+0.18*math.cos(BugRotation2)-Bug.positions.z[a])^2)) > 2 then
				BugRotation2 += math.pi
			end
			model3d.position(Bug.model[a],1,{TempBugP.x+0.15*math.sin(BugRotation2),TempBugP.y,TempBugP.z+0.15*math.cos(BugRotation2)})	
			model3d.rotation(Bug.model[a],1,{0,BugRotation2*180/math.pi,0})
		end
	end
	for a = 11,13 do
		if Bug.rendered[a] then
			BugRotation3[a] += 0.1
			model3d.rotation(Bug.model[a],1,{0,BugRotation3[a]*180/math.pi,0})
		end
	end
	
	--net position
	model3d.rotation(Net,1,{180,360 - Rotation*180/(math.pi),0}) --change net's rotation
	model3d.position(Net,1,{BallP.x+NetForwardOffset*SinSign*math.sin(RotationForCalc)-NetSideOffset*CosSign*math.cos(RotationForCalc),BallP.y+NetVerticalOffset,BallP.z+NetForwardOffset*CosSign*math.cos(RotationForCalc)+NetSideOffset*SinSign*math.sin(RotationForCalc)})
	
	--apply movement if buttons are pressed
	buttons.read()
	if (buttons.held.up and GlitchState.REVERSE == 0) or (buttons.held.down and GlitchState.REVERSE == 1) then 
		BallV.x = BallV.x+0.5*SinSign*math.sin(RotationForCalc)
		BallV.z = BallV.z+0.5*CosSign*math.cos(RotationForCalc)
		model3d.setvelocity(Ball,1,{BallV.x,BallV.y,BallV.z}) end
	if (buttons.held.down and GlitchState.REVERSE == 0) or (buttons.held.up and GlitchState.REVERSE == 1) then 
		BallV.x = BallV.x-0.5*SinSign*math.sin(RotationForCalc)
		BallV.z = BallV.z-0.5*CosSign*math.cos(RotationForCalc)
		model3d.setvelocity(Ball,1,{BallV.x,BallV.y,BallV.z}) end
	if (buttons.held.left and GlitchState.REVERSE == 0) or (buttons.held.right and GlitchState.REVERSE == 1) then 
		BallV.x = BallV.x+0.5*CosSign*math.cos(RotationForCalc)
		BallV.z = BallV.z-0.5*SinSign*math.sin(RotationForCalc)
		model3d.setvelocity(Ball,1,{BallV.x,BallV.y,BallV.z}) end
	if (buttons.held.right and GlitchState.REVERSE == 0) or (buttons.held.left and GlitchState.REVERSE == 1) then 
		BallV.x = BallV.x-0.5*CosSign*math.cos(RotationForCalc)
		BallV.z = BallV.z+0.5*SinSign*math.sin(RotationForCalc)
		model3d.setvelocity(Ball,1,{BallV.x,BallV.y,BallV.z}) end
	--Analogx calcs
	if GlitchState.REVERSE == 0 then
		BallV.x = BallV.x-((buttons.analogx+0.5)/127.5)*CosSign*math.cos(RotationForCalc)
		BallV.z = BallV.z+((buttons.analogx+0.5)/127.5)*SinSign*math.sin(RotationForCalc)
		model3d.setvelocity(Ball,1,{BallV.x,BallV.y,BallV.z})
		BallV.x = BallV.x-((buttons.analogy+0.5)/127.5)*SinSign*math.sin(RotationForCalc)
		BallV.z = BallV.z-((buttons.analogy+0.5)/127.5)*CosSign*math.cos(RotationForCalc)
		model3d.setvelocity(Ball,1,{BallV.x,BallV.y,BallV.z}) 
	else
		BallV.x = BallV.x+((buttons.analogx+0.5)/127.5)*CosSign*math.cos(RotationForCalc)
		BallV.z = BallV.z-((buttons.analogx+0.5)/127.5)*SinSign*math.sin(RotationForCalc)
		model3d.setvelocity(Ball,1,{BallV.x,BallV.y,BallV.z})
		BallV.x = BallV.x+((buttons.analogy+0.5)/127.5)*SinSign*math.sin(RotationForCalc)
		BallV.z = BallV.z+((buttons.analogy+0.5)/127.5)*CosSign*math.cos(RotationForCalc)
		model3d.setvelocity(Ball,1,{BallV.x,BallV.y,BallV.z}) 
	end
	
	if buttons.cross and (MovementState.FALLING==0 or (GlitchState.DOUBLEJUMP == 1 and BallV.y < 4)) then 
		model3d.setvelocity(Ball,1,{BallV.x,16,BallV.z}) 
		GroundTimer = 0
		if not sound.playing(jumpsound) then sound.play(jumpsound) end
	end --jump
	if buttons.held.l then Rotation += 0.0300630876 end
	if buttons.held.r then Rotation -= 0.0300630876 end
	if buttons.start then MovementState.PAUSED = 1 end
	if buttons.circle and NetSwing == 0 then
		if not sound.playing(netsound) then sound.play(netsound) end
		NetSwing = 1
		NetSwingDown = 1
		for a = 1,12 do 
			if Bug.rendered[a] then
				TempBugP = model3d.getposition(Bug.model[a],1)
				if math.sqrt(((BallP.x-TempBugP.x)^2)+((BallP.y-TempBugP.y)^2)+((BallP.z-TempBugP.z)^2)) < 12.5 then
					Bug.rendered[a] = false
					timer.reset(timer2)
					timer.start(timer2)
					BugsLeft -= 1
					if Bug.glitches[a] == 1 then
						GlitchState.DOUBLEJUMP = 1
					elseif Bug.glitches[a] == 2 then
						GlitchState.HIGHSPEED = 1
					elseif Bug.glitches[a] == 3 then
						GlitchState.REVERSE = 1
					end
				end
			end
		end
	end
	if NetSwing == 1 then 
		if NetVerticalOffset > -1.5 and NetSwingDown == 1 then NetVerticalOffset -= 0.5
		else 
			NetSwingDown = 0
			if NetVerticalOffset < 0 then NetVerticalOffset += 0.1 
			else NetSwing = 0 end
		end
	end
	
		
	
	--background image code, there's one 480x272 image for each cardinal direction
	amg.mode2d(1)
	if Rotation < math.pi/2 then
		level1backgroundNorth:blit(Rotation/(math.pi/2)*480,0) end
	if Rotation < math.pi then
		level1backgroundWest:blit((Rotation-math.pi/2)/(math.pi/2)*480,0) end
	if Rotation < 3*math.pi/2 and Rotation >= math.pi/2 then
		level1backgroundSouth:blit((Rotation-math.pi)/(math.pi/2)*480,0) end
	if Rotation < 2*math.pi and Rotation >= math.pi then
		level1backgroundEast:blit((Rotation-3*math.pi/2)/(math.pi/2)*480,0) end
	if Rotation >= 3*math.pi/2 then
		level1backgroundNorth:blit((Rotation-2*math.pi)/(math.pi/2)*480,0) end
	amg.mode2d(0)

	--set camara
	cam3d.set(camera1)

	amg.light(1,1);--activate light before rendering objects

	model3d.render(Ramp,2)
	--model3d.render(Water)
	for a=1,12 do 
		if Bug.rendered[a] then model3d.render(Bug.model[a],2) end
	end
	model3d.render(Net)
	--model3d.blitshadow(Net,1,1,100,1)
	model3d.blitshadow(Ball,1,1,100,1)

	amg.light(1,0);--disable light after rendering objects

	--temporarily enable 2d mode to print debug variables
	amg.mode2d(1)
	--screen.print(15,168,"PowerupTime"..timer.time(timer2))
	--screen.print(15,180,"HIGHSPEED"..GlitchState.HIGHSPEED)
	--screen.print(15,192,"speed"..math.sqrt(BallV.x*BallV.x + BallV.z*BallV.z))
	screen.print(15,204,"endCounter"..endCounter)
	screen.print(15,216,"X: "..BallP.x)
	screen.print(15,228,"Y: "..BallP.y)
	--timer.time(timer2)
	screen.print(15,240,"Z: "..BallP.z)
	screen.print(15,252,"FPS: "..screen.fps())
	
	--powerup timer
	if timer.time(timer2)/1000 > 0 then
		if timer.time(timer2)/1000 < 1.25 then
			HUD4:blit(0,0,255)
		elseif timer.time(timer2)/1000 < 2.5 then
			HUD3:blit(0,0,255)
		elseif timer.time(timer2)/1000 < 3.75 then
			HUD2:blit(0,0,255)
		elseif timer.time(timer2)/1000 < 5 then
			HUD1:blit(0,0,255)
		elseif timer.time(timer2)/1000 > 5 then
			timer.reset(timer2)
			timer.stop(timer2)
			HUD:blit(0,0,255)
			GlitchState.DOUBLEJUMP = 0
			GlitchState.HIGHSPEED = 0
			GlitchState.REVERSE = 0
		end
	else HUD:blit(0,0,255) end
	
	screen.print(80,22,math.ceil(240-timer.time(timer1)/1000))
	screen.print(438,22,BugsLeft)
	
	amg.mode2d(0) --close 2d mode
	screen.flip()
	
	if math.ceil(240-timer.time(timer1)/1000) == 0 then
		MovementState.DEAD = 1
		MovementState.PAUSED = 1
	end
	
	if BallP.y > 201 and BugsLeft == 9 and (math.sqrt((BallP.x-40)^2 + (BallP.z-17)^2) < 30) then 
		win = 1 
	end
	if win == 1 then
		timer.stop(timer1)
		endCounter -= 1
	end
	if endCounter <= 0 then
		amg.mode2d(0) --close 2d mode
		screen.flip()
		model3d.finishphysics()
		Ball,Water,Ramp,Bug = nil,nil,nil,nil
		if sound.playing(levelsong) then sound.stop(levelsong) end
		collectgarbage()
		os.delay(100)
		amg.finish()
		dofile("script.lua")
	end
	
	--PAUSING/DYING/QUITTING
	if BallP.y < -2 then --check for death
		MovementState.DEAD = 1 
		MovementState.PAUSED = 1
	end 
	if MovementState.PAUSED==1 then
		buttons.interval(40,10) --these are default values from ONELUA documentation
		option = 1
		while MovementState.PAUSED == 1 do
			amg.mode2d(1)
			blackscreen:blit(0,0)
			if option == 1 then screen.print(240,201,"Retry",0.8,color.white,color.green,__ACENTER)
			else  screen.print(240,200,"Retry",0.6,color.white,0,__ACENTER) end
			if option == 2 then screen.print(240,216,"Quit to Main Menu",0.8,color.white,color.green,__ACENTER)
			else screen.print(240,215,"Quit to Main Menu",0.6,color.white,0,__ACENTER) end
			
			buttons.read()
			if buttons.down then option += 1
			elseif buttons.up then option -= 1
			end
			if option < 1 then option = 2
			elseif option > 2 then option = 1
			end
			if buttons.start then MovementState.PAUSED = 0 end
			if buttons.cross then
				MovementState.PAUSED = 0
				model3d.position(Ball,1,StartPosition)
				model3d.setvelocity(Ball,1,{0,0,0})
				timer.reset(timer1)
				timer.start(timer1)
				timer.reset(timer2)
				timer.stop(timer2)
				MovementState.DEAD = 0
				MovementState.START = 1
				if sound.playing(levelsong) then sound.stop(levelsong) end
				if option == 2 then 
					amg.mode2d(0) --close 2d mode
					screen.flip()
					model3d.finishphysics()
					Ball,Water,Ramp,Bug = nil,nil,nil,nil
					if sound.playing(levelsong) then sound.stop(levelsong) end
					collectgarbage()
					os.delay(100)
					amg.finish()
					dofile("script.lua")
				end
			end
			amg.mode2d(0)
			screen.flip()
		end
		buttons.interval()
	end	
	
	amg.update()
	model3d.updatephysics()
end