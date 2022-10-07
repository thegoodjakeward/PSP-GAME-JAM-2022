--------------------------------------ONELUA 3D-----------------------------------
TIMER = 0
--INIT
os.cpu(333)
amg.init(__8888)
amg.perspective(40.0)
model3d.initphysics(20,{-100,-100,-100},{100,100,100}) --Tamaño del mundo físico
--CAM
camera1 = cam3d.new()

--LIGHT
amg.typelight(1,__DIRECTIONAL)
amg.colorlight(1,color.new(250,250,250),color.new(90,90,90),color.new(250,250,250))
amg.poslight(1,{0.5,1,0.5})

--LOADING
Ball = model3d.load(files.cdir().."/3d/data/ball.obj")
Water = model3d.load(files.cdir().."/3d/data/plane.obj")
Ramp = model3d.load(files.cdir().."/3d/data/ramp.obj")

model3d.setphysics(Ball,1,{0,0,0},{0,0,0},2,__SPHERE)
model3d.setphysics(Water,1,{0,0,0},{0,0,0},0,__BOX)
model3d.setphysics(Ramp,1,{0,0,0},{0,0,0},0,__CONVEX)

model3d.physics(Ball)
model3d.physics(Water)
model3d.physics(Ramp)

model3d.setdamping(Ball,1,0.4,1000000)
model3d.position(Ball,1,{-2,6,0})

Rotation = 0;
RotationForCalc = 0;
SinSign = 0;
CosSign = 0;
tempVz = 0;
tempVx = 0;

while true do
	amg.begin()
	amg.gravity(0,-9.8,0)
	
	BallP = model3d.getposition(Ball,1)
	BallV = model3d.getvelocity(Ball,1)
	
	if Rotation > 2*math.pi then Rotation=0
	elseif Rotation < 0 then Rotation = 2*math.pi end
	
	cam3d.position(camera1,{BallP.x,BallP.y+3,BallP.z})
	cam3d.eye(camera1,{10*math.sin(Rotation)+BallP.x,BallP.y+3,10*math.cos(Rotation)+BallP.z})
	
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
	
	if (BallV.x*BallV.x + BallV.z*BallV.z) > 400  then 
		BallV.z = BallV.z*0.97
		BallV.x = BallV.x*0.97
	end

	buttons.read()
	if buttons.held.up then model3d.setvelocity(Ball,1,{BallV.x+0.5*SinSign*math.sin(RotationForCalc),BallV.y,BallV.z+0.5*CosSign*math.cos(RotationForCalc)}) end
	if buttons.held.down then model3d.setvelocity(Ball,1,{BallV.x-0.5*SinSign*math.sin(RotationForCalc),BallV.y,BallV.z-0.5*CosSign*math.cos(RotationForCalc)}) end
	if buttons.held.left then model3d.setvelocity(Ball,1,{BallV.x+0.5*CosSign*math.cos(RotationForCalc),BallV.y,BallV.z-0.5*SinSign*math.sin(RotationForCalc)}) end
	if buttons.held.right then model3d.setvelocity(Ball,1,{BallV.x-0.5*CosSign*math.cos(RotationForCalc),BallV.y,BallV.z+0.5*SinSign*math.sin(RotationForCalc)}) end
	if buttons.held.cross and math.abs(BallV.y) < 0.05 then model3d.setvelocity(Ball,1,{BallV.x,15,BallV.z}) end
	if buttons.held.l then Rotation += 0.0300630876 end
	if buttons.held.r then Rotation -= 0.0300630876 end

	--Set camara
	cam3d.set(camera1)

	amg.light(1,1);--activar luz 1

	model3d.render(Ramp)
	model3d.render(Water)

	model3d.blitshadow(Ball,1,1,100,1)
	--model3d.render(Ball)

	amg.light(1,0);--desactivar luz 1

	amg.mode2d(1)
	screen.print(15,168,"Rotation"..RotationForCalc)
	screen.print(15,180,"X-Position"..BallP.x)
	screen.print(15,192,"Y-Position"..BallP.y)
	screen.print(15,204,"Z-Position"..BallP.z)
	screen.print(15,216,"Speed"..math.sqrt(BallV.x*BallV.x + BallV.z*BallV.z))
	screen.print(15,228,"TempVz"..tempVz)
	screen.print(15,240,"TempVx"..tempVx)
	if buttons.start then dofile("script.lua") end
	amg.mode2d(0)
	screen.flip()
	
	amg.update()
	model3d.updatephysics()

	if buttons.start then
		model3d.finishphysics()
		Ball,Water,Ramp = nil,nil,nil
		collectgarbage()
		os.delay(100)
	
		amg.finish()
		dofile("script.lua")
	end
end