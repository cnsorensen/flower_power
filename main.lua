-- Flower Invaders

-- For crisp looking flowers
love.graphics.setDefaultFilter('nearest', 'nearest')

-- enemy stuff
enemy = {}
enemies_controller = {}
enemies_controller.enemies = {}
enemies_controller.image = love.graphics.newImage('enemy.png')

-- A super slow way of checking for bullet/flower collisions
function checkCollisions(enemies, bullets)
  for i,e in ipairs(enemies) do
    for _,b in pairs(bullets) do
      if b.y <= e.y + e.height and b.x > e.x and b.x < e.x + e.width then
        table.remove(enemies, i)
      end
    end
  end
end

function love.load()
  -- window title
  love.window.setTitle('Flower Power!')

  -- Background music
  love.audio.play(love.audio.newSource('music.mp3', 'static'))

  print(love.graphics.getWidth())
  print(love.graphics.getHeight())

  game_over = false
  game_win = false
  cooldown_init = 20

  background_image = love.graphics.newImage('background.png')

  -- player class
  player = {}
  player.x = 0
  player.y = 140
  player.bullets = {}
  player.cooldown = cooldown_init
  player.speed = 1
  player.image = love.graphics.newImage("player.png")
  player.fire_sound = love.audio.newSource("zap.mp3", "static")

  -- Fires bullets
  player.fire = function()
    if player.cooldown <= 0 then
      love.audio.play(player.fire_sound)
      player.cooldown = cooldown_init
      bullet = {}
      bullet.x = player.x + 4
      bullet.y = player.y
      table.insert(player.bullets, bullet)
    end
  end

  -- create enemies accross the window
  for i=0, 12 do
    enemies_controller:spawnEnemy(i * 15, 0)
  end
end

-- creates an enemy
function enemies_controller:spawnEnemy(x, y)
  enemy = {}
  enemy.x = x
  enemy.y = y
  enemy.width = 10
  enemy.height = 10
  enemy.bullets = {}
  enemy.cooldown = 100
  enemy.speed = 0.1
  table.insert(self.enemies, enemy)
end

-- gets called before draw
function love.update(dt)
  -- player bullet cooldown time decreases
  player.cooldown = player.cooldown - 1

  -- move player paddle left and right
  if love.keyboard.isDown("right") then
    player.x = player.x + player.speed
  elseif love.keyboard.isDown("left") then
    if player.x <= 0 then
      player.x = 0
    else
      player.x = player.x - player.speed
    end
  end

  -- shoot bullets
  if love.keyboard.isDown('space') then
    player.fire()
  end

  -- all the enemies have been kill
  if #enemies_controller.enemies == 0 then
    -- we win!!
    game_win = true
  end

  -- draw enemies
  for _,e in pairs(enemies_controller.enemies) do
    -- if an enemy hits the bottom of the screen, then game over
    if e.y >= love.graphics.getHeight()/4 then
      game_over = true
    end
    e.y = e.y + e.speed
  end

  -- bullet move up
  for _,b in pairs(player.bullets) do
    b.y = b.y - 1
  end

  -- delete bullet when out of window
  for i,b in ipairs(player.bullets) do
    if b.y < -10 then
      table.remove(player.bullets, i)
    end
  end

  -- check for bullet collisions with the enemies
  checkCollisions(enemies_controller.enemies, player.bullets)
end

function love.draw()
  love.graphics.scale(4)

  -- game over
  if game_over then
    love.graphics.print("Game Over!")
    return
  elseif game_win then
    love.graphics.print("You win!!")
    return
  end

  -- draw the ugly background
  love.graphics.draw(background_image)

  love.graphics.setColor(255, 255, 255)

  -- draw player paddle
  love.graphics.draw(player.image, player.x, player.y, 0)

  -- draw the enemies
  for _,e in pairs(enemies_controller.enemies) do
    love.graphics.draw(enemies_controller.image, e.x, e.y, 0)
  end

  -- draw bullets
  for _,b in pairs(player.bullets) do
    love.graphics.setColor(0, 0, 0)
    love.graphics.rectangle("fill", b.x, b.y, 2.5, 2.5)
    love.graphics.setColor(255, 255, 255)
  end
end

function love.keypressed(key)
  -- Exit game
  if key == 'q' or key == 'escape' then
    love.event.quit()
  end
end
