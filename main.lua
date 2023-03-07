require "socket" -- gettime

local plyX = nil;
local plyY = nil;
local enemies = {};
local bullets = {};
local lastBulletTime = nil;

function distance(x1,y1,x2,y2) return math.sqrt((x2 - x1) ^ 2 + (y2 - y1) ^ 2) end

function love.draw()
  -- grass field
  love.graphics.setBackgroundColor(0, 155, 0);

  -- draw player
  love.graphics.setColor(0, 0, 255);
  love.graphics.circle("fill", plyX, plyY, 30);

  -- draw enemies
  for _, enemy in pairs(enemies) do
    love.graphics.setColor(255, 0, 0);
    love.graphics.circle("fill", enemy.x, enemy.y, 30);
  end

  -- draw bullets
  for _, bullet in pairs(bullets) do
    love.graphics.setColor(255, 255, 255);
    love.graphics.circle("fill", bullet.x, bullet.y, 4);
  end

  if next(enemies) == nil then -- winning screen
    love.graphics.setColor(255, 223, 0)
    love.graphics.setNewFont(100);
    love.graphics.print("VITÓRIA", 175, 250);
  end
end

-- set player spawn and enemies
function love.load()
  plyX = 600; plyY = 500;
  addEnemy(100, 100);
  addEnemy(600, 100);
  addEnemy(100, 500);
end

-- input, collision, passive movement
function love.update(dt)
  for index, bullet in pairs(bullets) do
    if -- check bounds
      bullet.x < 0 or
      bullet.x > 800 or
      bullet.y < 0 or
      bullet.y > 600
    then table.remove(bullets, index); goto continue; end

    for _index, enemy in pairs(enemies) do -- check collision
      if distance(bullet.x, bullet.y, enemy.x, enemy.y) < 34 then
        table.remove(bullets, index); table.remove(enemies, _index);
        goto continue;
      end
    end
    
    moveBullet(bullet, dt);
    ::continue::
  end

  -- process input
  if     love.keyboard.isDown("up")    then
    if love.keyboard.isDown("space") then shootBullet("up");
    else movePlayer("up", dt); end
  elseif love.keyboard.isDown("down")  then
    if love.keyboard.isDown("space") then shootBullet("down");
    else movePlayer("down", dt); end
  elseif love.keyboard.isDown("left")  then
    if love.keyboard.isDown("space") then shootBullet("left");
    else movePlayer("left", dt); end
  elseif love.keyboard.isDown("right") then
    if love.keyboard.isDown("space") then shootBullet("right");
    else movePlayer("right", dt); end
  end
end

function addEnemy(posX, posY)
  local enemy = {};
  enemy.x = posX;
  enemy.y = posY;
  -- enemy.hp = 100;

  table.insert(enemies, enemy);
end

function movePlayer(input, dt)
  if     input == "up"    then plyY = plyY - 175*dt;
  elseif input == "down"  then plyY = plyY + 175*dt;
  elseif input == "left"  then plyX = plyX - 175*dt;
  elseif input == "right" then plyX = plyX + 175*dt;
  end
end

function moveBullet(bullet, dt)
  if     bullet.direction == "up"    then bullet.y = bullet.y - 200*dt;
  elseif bullet.direction == "down"  then bullet.y = bullet.y + 200*dt;
  elseif bullet.direction == "left"  then bullet.x = bullet.x - 200*dt;
  elseif bullet.direction == "right" then bullet.x = bullet.x + 200*dt;
  end
end

function shootBullet(dir)
  -- preventing bullet spam
  if lastBulletTime and (socket.gettime()*1000) - lastBulletTime < 500
  then return else lastBulletTime = socket.gettime()*1000; end
  
  local bullet = {};
  bullet.direction = dir;

  -- initial position according to player position
  -- padding is 4+30 (both circles' radius)
  if     dir == "up"    then
    bullet.x = plyX; bullet.y = plyY - 34;
  elseif dir == "down"  then
    bullet.x = plyX; bullet.y = plyY + 34;
  elseif dir == "left"  then
    bullet.x = plyX - 34; bullet.y = plyY;
  elseif dir == "right" then
    bullet.x = plyX + 34; bullet.y = plyY;
  end
  -- bullet.damage = 50;

  table.insert(bullets, bullet);
end