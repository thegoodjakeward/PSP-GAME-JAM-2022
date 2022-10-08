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
Water = model3d.load(files.cdir().."/3d/Data/plane.obj")
Ramp = model3d.load(files.cdir().."/3d/Data/ramp.obj")
Bug = {}
Bug.model = {}
Bug.rendered = {}
Bug.glitch = {}
Bug.position = {}
for a = 1,12 do Bug.model[a] = model3d.load(files.cdir().."/3d/Data/bug.obj") end

model3d.setphysics(Ball,1,{0,0,0},{0,0,0},2,__SPHERE) --second to last input is mass
model3d.setphysics(Water,1,{0,0,0},{0,0,0},0,__BOX) --zero mass indicates immovable
model3d.setphysics(Ramp,1,{0,0,0},{0,0,0},0,__CONVEX)

model3d.physics(Ball)
model3d.physics(Water)
model3d.physics(Ramp)

model3d.setdamping(Ball,1,0.4,1000000) --sets linear and rotational damping
StartPosition = {-2,6,0}

blackscreen = image.load(files.cdir().."/3d/blackscreen.png")


--VARIABLES
Rotation = 0; --camera's rotation
RotationForCalc = 0; --camera's rotation converted to corresponding quadrant for calcs
SinSign = 0; --used in quadrant calcs
CosSign = 0; --used in quadrant calcs
BugRotation = 0

--LEVEL VARIABLES
Level = 1
Level1Bugs = {}
Level1Bugs.rendered = {true,true,true,false,false,false,false,false,false,false,false,false}
Level1Bugs.positions = {}
for a = 1,12 do Level1Bugs.positions[a] = {x=-5*a,y=1,z=10} end
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
	if MovementState.START==1 then
		for a = 1,12 do 
			Bug.position[a] = Level1Bugs.positions[a]
			model3d.position(Bug.model[a],1,{Bug.position[a].x,Bug.position[a].y,Bug.position[a].z}) 
		end
		model3d.position(Ball,1,StartPosition)
		MovementState.START = 0
		Bug.rendered = Level1Bugs.rendered
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
	cam3d.eye(camera1,{10*math.sin(Rotation)+BallP.x,BallP.y+3,10*math.cos(Rotation)+BallP.z}) --set camera's looking direction
	
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
	
	--enforce top speed
	if MovementState.RUNNING==1 and (BallV.x*BallV.x + BallV.z*BallV.z) > 400  then 
		BallV.z = BallV.z*0.97
		BallV.x = BallV.x*0.97
	end
	
	for a = 1,12 do 
		model3d.setVelocity(Bug.model[a],1,{2*math.sin(BugRotation),0,2*math.cos(BugRotation)})
		TempBugP = model3d.getposition(Bug.model[a],1)
		if math.sqrt(math.pow(TempBugP.x-Bug.position[a].x,2)+math.pow(TempBugP.y-Bug.position[a].y,2)+math.pow(TempBugP.z-Bug.position[a].z,2)) > 5 then
			
		end
	end

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
				if math.sqrt(math.pow(BallP.x-Bug.position[a].x,2)+math.pow(BallP.y-Bug.position[a].y,2)+math.pow(BallP.z-Bug.position[a].z,2)) < 10 then
					Bug.rendered[a] = false
				end
			end
		end
	end

	--set camara
	cam3d.set(camera1)

	amg.light(1,1);--activate light before rendering objects

	model3d.render(Ramp)
	model3d.render(Water)
	for a=1,12 do 
		if Bug.rendered[a] then model3d.render(Bug.model[a]) end
	end
	model3d.blitshadow(Ball,1,1,100,1)

	amg.light(1,0);--disable light after rendering objects

	--temporarily enable 2d mode to print debug variables
	amg.mode2d(1)
	screen.print(15,168,"Time "..timer.time(timer1)/1000)
	screen.print(15,180,"Time2 "..timer.time(timer2)/1000)
	screen.print(15,192,"FPS "..screen.fps())
	screen.print(15,204,"INFINITEJUMP"..GlitchState.INFINITEJUMP)
	screen.print(15,216,"Speed "..math.sqrt(BallV.x*BallV.x + BallV.z*BallV.z))
	screen.print(15,228,"How Close "..math.sqrt(math.pow(BallP.x-Bug.position[1].x,2)+math.pow(BallP.y-Bug.position[1].y,2)+math.pow(BallP.z-Bug.position[1].z,2)))
	screen.print(15,240,"Running? "..MovementState.RUNNING)
	screen.print(15,252,"Idle? "..MovementState.IDLE)
	
	amg.mode2d(0) --close 2d mode
	screen.flip()
	
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