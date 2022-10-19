--------------------------------------ONELUA 3D-----------------------------------
TIMER = 0
--INITIATE 
os.cpu(333) --set cpu clock speed
amg.init(__8888)
amg.perspective(40.0)
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
for a = 1,12 do Bug.model[a] = model3d.load(files.cdir().."/3d/Data/bug.obj") end

model3d.setphysics(Ball,1,{0,0,0},{0,0,0},2,__SPHERE) --second to last input is mass
--model3d.setphysics(Net,1,{0,0,0},{0,0,0},0,__BOX)
--model3d.setphysics(Water,1,{0,0,0},{0,0,0},0,__BOX) --zero mass indicates immovable
model3d.setphysics(Ramp,1,{0,0,0},{0,0,0},0,__CONVEX)

model3d.physics(Ball)
--model3d.physics(Net)
--model3d.physics(Water)
model3d.physics(Ramp)

model3d.setdamping(Ball,1,0.4,1000000) --sets linear and rotational damping
StartPosition = {0,50,0}

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
Rotation = 0; --camera's rotation
RotationForCalc = 0; --camera's rotation converted to corresponding quadrant for calcs
SinSign = 0; --used in quadrant calcs
CosSign = 0; --used in quadrant calcs
BugRotation = 0
NetForwardOffset = 4
NetSideOffset = 1
NetVerticalOffset = 2
CameraYAdjustment = 0

--LEVEL VARIABLES
Level = 1
Level1Bugs = {}
Level1Bugs.rendered = {true,true,true,true,false,false,false,false,false,false,false,false}
Level1Bugs.positions = {}
Level1Bugs.positions.x = {40, 40,-40,-40,0,0,0,0,0,0,0,0}
Level1Bugs.positions.y = { 0,  0,  0,  0,0,0,0,0,0,0,0,0}
Level1Bugs.positions.z = {40,-40, 40,-40,0,0,0,0,0,0,0,0}
Level1Bugs.glitches = {"NOCOLLISION","INFINITEJUMP","HIGHSPEED","NOTOP","WALLJUMP","SLOWTIME","REVERSE","HIDDENOBJECT","NOSTOP","STRONGGRAVITY","ICEPHYSICS","DARKMODE"}

--ENUMS
MovementState = {IDLE=0,RUNNING=0,FALLING=0,PAUSED=0,DEAD=0,START=1}
GlitchState = {NOGLITCH=0,NOCOLLISION=0,INFINITEJUMP=0,HIGHSPEED=0,NOTOP=0,WALLJUMP=0,SLOWTIME=0,REVERSE=0,HIDDENOBJECT=0,NOSTOP=0,STRONGGRAVITY=0,ICEPHYSICS=0,DARKMODE=0}

--TIMER
timer1 = timer.new()
timer.start(timer1)
timer2 = timer.new()
timer.stop(timer2)

while true do
	--level initialization stuff
	if MovementState.START==1 then
		if Level==1 then
			for a = 1,12 do 
				if Level1Bugs.rendered[a] then
					Bug.positions = Level1Bugs.positions
					model3d.position(Bug.model[a],1,{Bug.positions.x[a],Bug.positions.y[a],Bug.positions.z[a]}) 
				end
			end
			Bug.rendered = Level1Bugs.rendered
			Bug.glitches = Level1Bugs.glitches
			model3d.position(Ball,1,StartPosition)
			MovementState.START = 0
			BugsLeft = 4
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
	
	cam3d.position(camera1,{BallP.x,BallP.y+3,BallP.z}) --set camera to players position
	cam3d.eye(camera1,{10*math.sin(Rotation)+BallP.x,BallP.y+3+CameraYAdjustment,10*math.cos(Rotation)+BallP.z}) --set camera's looking direction
	
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
		MovementState.IDLE = 0
		MovementState.FALLING = 1
	else
		MovementState.FALLING = 0
	end
	--if MovementState.FALLING == 0 then CameraYAdjustment = CameraYAdjustment/1.08
	--elseif CameraYAdjustment > -2 then CameraYAdjustment += -0.05 end
	
	--enforce top speed
	if MovementState.RUNNING==1 and (BallV.x*BallV.x + BallV.z*BallV.z) > 400  then 
		BallV.z = BallV.z*0.97
		BallV.x = BallV.x*0.97
	end
	
	--bug movement
	for a = 1,12 do 
		if Bug.rendered[a] then
			TempBugP = model3d.getposition(Bug.model[a],1)
			if math.sqrt(((TempBugP.x+0.06*math.sin(BugRotation)-Bug.positions.x[a])^2)+((TempBugP.z+0.06*math.cos(BugRotation)-Bug.positions.z[a])^2)) > 2 then
				BugRotation += math.pi/1.5
			end
			if math.sqrt(((TempBugP.x+0.06*math.sin(BugRotation)-Bug.positions.x[a])^2)+((TempBugP.z+0.06*math.cos(BugRotation)-Bug.positions.z[a])^2)) < 2 then
				model3d.position(Bug.model[a],1,{TempBugP.x+0.04*math.sin(BugRotation),0,TempBugP.z+0.04*math.cos(BugRotation)})	
				model3d.rotation(Bug.model[a],1,{0,BugRotation*180/math.pi,0})
			end
		end
	end
	
	--net position
	model3d.rotation(Net,1,{180,360 - Rotation*180/(math.pi),0}) --change net's rotation
	model3d.position(Net,1,{BallP.x+NetForwardOffset*SinSign*math.sin(RotationForCalc)-NetSideOffset*CosSign*math.cos(RotationForCalc),BallP.y+NetVerticalOffset,BallP.z+NetForwardOffset*CosSign*math.cos(RotationForCalc)+NetSideOffset*SinSign*math.sin(RotationForCalc)})
	
	--apply movement if buttons are pressed
	buttons.read()
	if buttons.held.up then model3d.setvelocity(Ball,1,{BallV.x+0.5*SinSign*math.sin(RotationForCalc),BallV.y,BallV.z+0.5*CosSign*math.cos(RotationForCalc)}) end
	if buttons.held.down then model3d.setvelocity(Ball,1,{BallV.x-0.5*SinSign*math.sin(RotationForCalc),BallV.y,BallV.z-0.5*CosSign*math.cos(RotationForCalc)}) end
	if buttons.held.left then model3d.setvelocity(Ball,1,{BallV.x+0.5*CosSign*math.cos(RotationForCalc),BallV.y,BallV.z-0.5*SinSign*math.sin(RotationForCalc)}) end
	if buttons.held.right then model3d.setvelocity(Ball,1,{BallV.x-0.5*CosSign*math.cos(RotationForCalc),BallV.y,BallV.z+0.5*SinSign*math.sin(RotationForCalc)}) end
	if buttons.cross and MovementState.FALLING==0 then model3d.setvelocity(Ball,1,{BallV.x,15,BallV.z}) end --jump
	if buttons.held.l then Rotation += 0.0300630876 end
	if buttons.held.r then Rotation -= 0.0300630876 end
	if buttons.start then MovementState.PAUSED = 1 end
	if buttons.circle then
		for a = 1,12 do 
			if Bug.rendered[a] then
				TempBugP = model3d.getposition(Bug.model[a],1)
				if math.sqrt(((BallP.x-TempBugP.x)^2)+((BallP.y-TempBugP.y)^2)+((BallP.z-TempBugP.z)^2)) < 12.5 then
					Bug.rendered[a] = false
					timer.reset(timer2)
					timer.start(timer2)
					BugsLeft -= 1
				end
			end
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

	model3d.render(Ramp)
	--model3d.render(Water)
	for a=1,12 do 
		if Bug.rendered[a] then model3d.render(Bug.model[a]) end
	end
	model3d.render(Net)
	--model3d.blitshadow(Net,1,1,100,1)
	model3d.blitshadow(Ball,1,1,100,1)

	amg.light(1,0);--disable light after rendering objects

	--temporarily enable 2d mode to print debug variables
	amg.mode2d(1)
	--screen.print(15,168,"BallP.x"..BallP.x)
	--screen.print(15,180,"BallP.z"..BallP.z)
	--screen.print(15,192,"temp: ")
	--screen.print(15,204,"Rotation"..Rotation)
	--screen.print(15,216,"temp2: ")
	--screen.print(15,228,"How Close ")
	--timer.time(timer2)
	screen.print(15,240,"CameraYAdjustment "..CameraYAdjustment)
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
		end
	else HUD:blit(0,0,255) end
	
	screen.print(80,22,math.ceil(120-timer.time(timer1)/1000))
	screen.print(438,22,BugsLeft)
	
	amg.mode2d(0) --close 2d mode
	screen.flip()
	
	if math.ceil(120-timer.time(timer1)/1000) == 0 then
		MovementState.DEAD = 1
		MovementState.PAUSED = 1
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
			if option == 1 then 
				if MovementState.DEAD==1 then screen.print(240,212,"Retry",0.6,color.orange,color.yellow,__ACENTER)
				else screen.print(240,212,"Continue",0.6,color.orange,color.yellow,__ACENTER) end
			else 
				if MovementState.DEAD==1 then screen.print(240,212,"Retry",0.6,color.orange,0,__ACENTER)
				else screen.print(240,212,"Continue",0.6,color.orange,0,__ACENTER) end
			end
			if option == 2 then screen.print(240,224,"Quit to Main Menu",0.6,color.orange,color.yellow,__ACENTER)
			else screen.print(240,224,"Quit to Main Menu",0.6,color.orange,0,__ACENTER)
			end
			
			buttons.read()
			if buttons.down then option += 1
			elseif buttons.up then option -= 1
			end
			if option < 1 then option = 2
			elseif option > 2 then option = 1
			end
			if buttons.cross then
				MovementState.PAUSED = 0
				if MovementState.DEAD == 1 then
					model3d.position(Ball,1,StartPosition)
					model3d.setvelocity(Ball,1,{0,0,0})
					timer.reset(timer1)
					timer.start(timer1)
				end
				MovementState.DEAD = 0
				if option == 2 then 
					amg.mode2d(0) --close 2d mode
					screen.flip()
					model3d.finishphysics()
					Ball,Water,Ramp,Bug = nil,nil,nil,nil
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