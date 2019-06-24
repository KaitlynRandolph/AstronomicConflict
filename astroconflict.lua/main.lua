-- Space Invaders!
-- Made by Kaitlyn Randolph 
-- 6/24/19
-- base code from a tutorial by Spunky Kangaroo on YT, with my own additions
-- Programming resources used:
-- Base mechanics/functions for game: Spunky Kangaroo's Love2D tutorial (https://www.youtube.com/user/thespastickangaroo/)
-- Spunky Kangaroo's code here: https://github.com/charles-l/gamedev_tutorial/tree/4285dd2036135d4c185d30e753a175ae77dd12d5

-- FIXME: performance is variable? find out what determines speed of gameplay
-- FIXME: hitboxes of characters is not correct

----------------
--  Variables --
-----------------
-- changes how graphics scale
love.graphics.setDefaultFilter('nearest', 'nearest')
--require()
local bullet = {}
local player = {}
local enemies_controller = {}
local enemy = {}
particle_systems = {}
particle_systems.list = {}
particle_systems.img = love.graphics.newImage('Visual Assets/particle.png')
scale_value = 6

------------------------
--  Bullet Functions  --
------------------------

function bullet:new(xIn, yIn)
	x = xIn
	y = yIn
end

------------------------
--  Main Functions  --
------------------------
--info run before the game starts
function love.load()
	love.window.setMode(600, 600, {vsync=false})
	game_over = false
	game_win = false
	setBackgroundGraphic()
	setBackgroundMusic()	
	setLaserNoise()
	bullet = {}
	player.new()
	--player.fire()
	for i=0, 7 do
		enemies_controller:spawnEnemy(i * 77, 0)
	end
end

function love.update(dt)
	particle_systems:update(dt)
	player.cooldown = player.cooldown - 1
	player.controller()
	winCheck()
	for _,e in pairs(enemies_controller.enemies) do
		if e.y >= love.graphics.getHeight()/5
			then game_over = true
		end
		e.y = e.y + 1 * e.speed
	end

	for i,b in ipairs(player.bullets) do
		if b.y < -10 then
			table.remove(player.bullets, i)
		end
		b.y = b.y - 2
	end

	checkCollisions(enemies_controller.enemies, player.bullets)
end

--called for every frame draw
function love.draw()
	--love.graphics.scale(3)
	love.graphics.draw(background_image, 0, 0, 0, 6, 6)

	--if game_over
	--	then love.graphics.print("Game Over!")
	--	return
	--elseif game_win 
	--	then love.graphics.print("You Won!")
	--end

	particle_systems:draw()
	-- draw player
	love.graphics.draw(player.image, player.x, player.y, 0, scale_value)

	-- draw enemy
	for _,e in pairs(enemies_controller.enemies) do
		love.graphics.draw(enemies_controller.image, e.x, e.y, 0, scale_value)
	end

	-- draw bullets
	for _,b in pairs(player.bullets) do
		love.graphics.rectangle("fill", b.x, b.y, scale_value, scale_value)
	end
end

-----------------------
--  Player Functions --
-----------------------
function player:new()
	player.x = 300
	player.y = 450
	player.w = 10 * scale_value
	player.bullets = {}
	player.cooldown = 0
	player.speed = .75
	player.image = love.graphics.newImage('Visual Assets/ship_detailed.png')
end

function player.fire()
	if player.cooldown <= 0 then
		love.audio.play(player.fire_sound) 
		local b = bullet:new(player.x + (1/2 * player.w), player.y + 2)
		table.insert(player.bullets, b)
	end
	player.cooldown = 50
end

function player.controller()
	if player.x < 0 then
		player.x = 0
	end
	if (player.x + player.w) > love.graphics.getWidth() then
		player.x = love.graphics.getWidth() - player.w
	end
	if love.keyboard.isDown("right") or love.keyboard.isDown("d") then
		player.x = player.x + player.speed
	elseif love.keyboard.isDown("left") or love.keyboard.isDown("a") then
		player.x = player.x - player.speed
	end
	if love.keyboard.isDown("space") then
		player.fire()
	end
end

----------------------------
--  Enemy/Game Functions  --
----------------------------
function checkCollisions(enemies, bullets)
	setHitNoise()
	for i,e in ipairs(enemies) do
		for _,b in pairs(bullets) do
			if b.y <= e.y + e.height and b.x > e.x and b.x < e.x + e.width then
				particle_systems:spawn(e.x + 5, e.y + 5)
				love.audio.play(hit_sound) 
				table.remove(enemies, i)
			end
		end
	end
end

function enemies_controller:new()
	enemies_controller.enemies = {}
	enemies_controller.image = love.graphics.newImage('Visual Assets/enemy.png')
end

-- self is equivalent to "this"
function enemies_controller:spawnEnemy(xIn, yIn)
	enemy = {}
	enemy.x = xIn
	enemy.y = yIn
	enemy.width = 100
	enemy.height = 100
	enemy.bullets = {}
	enemy.cooldown = 50
	enemy.speed = .2
	table.insert(enemies, enemy)
end

function enemy:fire()
	if self.cooldown <= 0 then
		local b = bullet:new((self.x + 35), self.y)
		table.insert(self.bullets, b)
	end
	self.cooldown = 50
end

function winCheck()
	if #enemies_controller.enemies == 0
		then game_win = true
	end
end

--------------------------
--  Particle Functions  --
--------------------------
function particle_systems:spawn(x, y)
	local ps = {}
	ps.x = x
	ps.y = y
	ps.ps = love.graphics.newParticleSystem(particle_systems.img, 32)
	ps.ps:setParticleLifetime(1, 2)
	ps.ps:setSizes(6)
	ps.ps:setEmissionRate(3)
	ps.ps:setEmissionArea(borderellipse, 0.5, 0.5, 0, false)
	ps.ps:setSizeVariation(1)
	ps.ps:setLinearAcceleration(-10, -10, 10, 10)
	ps.ps:setEmitterLifetime(1)
	table.insert(particle_systems.list, ps)
end

function particle_systems:draw()
	for _,v in pairs(particle_systems.list) do
		love.graphics.draw(v.ps, v.x, v.y)
	end
end

function particle_systems:update(dt)
	for _,v in pairs(particle_systems.list) do
		v.ps:update(dt)
	end
end

----------------------------
-- Visual/Sound Functions --
----------------------------
function setBackgroundMusic()
	-- "La Calahorra" (c) Rolemusic, found at: http://freemusicarchive.org/music/Rolemusic/~/calahorra
	local music = love.audio.newSource('Audio/rolemu_-_La_Calahorra.mp3', 'static')
	music:setLooping(true)
	love.audio.play(music)
end

function setBackgroundGraphic()
	background_image = love.graphics.newImage('Visual Assets/background.png')
end

function setLaserNoise()
	-- sound file (c) NoiseCollector, found here: https://freesound.org/people/NoiseCollector/sounds/62793/
	player.fire_sound = love.audio.newSource('Audio/noisecollector-lazerburster.wav', 'static')
end

function setHitNoise()
	-- sound file (c) LittleRobotSoundFactory, found here: https://freesound.org/people/LittleRobotSoundFactory/sounds/270310/
	hit_sound = love.audio.newSource('Audio/littlerobotsoundfactory - explosion_04.wav', 'static')
end