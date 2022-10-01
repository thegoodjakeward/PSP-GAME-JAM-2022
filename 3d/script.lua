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

model3d.setphysics(Ball,1,{0,0,0},{0,0,0},2,__CONVEX)
model3d.setphysics(Water,1,{0,0,0},{0,0,0},0,__CONVEX)
model3d.setphysics(Ramp,1,{0,0,0},{0,0,0},0,__CONVEX)

model3d.physics(Ball)
model3d.physics(Water)
model3d.physics(Ramp)

model3d.setdamping(Ball,1,0.1,0.1)
model3d.position(Ball,1,{-2,6,0})

Rotation = 0;

while true do
	amg.begin()
	amg.gravity(0,-9.8,0) --Gravedad
	
	if Rotation > 2*math.pi then Rotation -= 2*math.pi
	elseif Rotation < -2*math.pi then Rotation += 2*math.pi end
	model3d.rotation(Ball,1,{0,Rotation,0})
	
	BallP = model3d.getposition(Ball,1)
	BallV = model3d.getvelocity(Ball,1)
	BallR = model3d.getrotation(Ball,1)
	if BallV.x > 10  then BallV.x = 10  end
	if BallV.x < -10 then BallV.x = -10 end
	if BallV.z > 10  then BallV.z = 10  end
	if BallV.z < -10 then BallV.z = -10 end

	cam3d.position(camera1,{BallP.x,BallP.y+3,BallP.z})
	cam3d.eye(camera1,{100*math.sin(Rotation)+BallP.x,BallP.y,100*math.cos(Rotation)+BallP.z})
	cam3d.rotation(camera1,{0,-Rotation,0})
	
	--Set camara
	cam3d.set(camera1)

	amg.light(1,1);--activar luz 1

	model3d.render(Ramp)
	model3d.render(Water)

	model3d.blitshadow(Ball,1,1,100,1)
	model3d.render(Ball)

	amg.light(1,0);--desactivar luz 1

	amg.mode2d(1)
	screen.print(15,168,"Rotation"..Rotation)
	screen.print(15,180,"X-Position"..BallP.x)
	screen.print(15,192,"Y-Position"..BallP.y)
	screen.print(15,204,"Z-Position"..BallP.z)
	screen.print(15,216,"X-Velocity"..BallV.x)
	screen.print(15,228,"Y-Velocity"..BallV.y)
	screen.print(15,240,"Z-Velocity"..BallV.z)
	if buttons.start then dofile("script.lua") end
	amg.mode2d(0)
	screen.flip()

	buttons.read()
	if buttons.held.up then model3d.setvelocity(Ball,1,{BallV.x+math.sin(Rotation),BallV.y,BallV.z+math.cos(Rotation)}) end
	if buttons.held.down then model3d.setvelocity(Ball,1,{BallV.x-math.sin(Rotation),BallV.y,BallV.z-math.cos(Rotation)}) end
	if buttons.held.left then model3d.setvelocity(Ball,1,{BallV.x+math.cos(Rotation),BallV.y,BallV.z-math.sin(Rotation)}) end
	if buttons.held.right then model3d.setvelocity(Ball,1,{BallV.x-math.cos(Rotation),BallV.y,BallV.z+math.sin(Rotation)}) end
	if buttons.held.cross and BallP.y < 1.2 then 
		model3d.setvelocity(Ball,1,{BallV.x,15,BallV.z}) 
	end
	if buttons.held.l then Rotation += 0.03 end
	if buttons.held.r then Rotation -= 0.03 end
	model3d.rotation(Ball,1,{0,Rotation,0})
	
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