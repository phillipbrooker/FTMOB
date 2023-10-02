--[[
FROM THE MOUTHS OF BONEHEADS
Philosophy Reading Group Simulator

Author: 	Haziasoft
Version: 	0.1.0
--]]

--IMPORTS AND SHORTHANDS
import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"
import "data"

local pd <const> = playdate --shorthanding the library
local gfx <const> = pd.graphics --shorthanding graphics calls

--CONSTANTS
local screenWidth = pd.display.getWidth()
local screenHeight = pd.display.getHeight()
local bubbleHeight = 180
local bubbleRadius = 10

--SPRITE DATA

boneheads = {}

--[[Setting up boneheads objects with attributes indexed as follows:

1. image directory
2. centre image x position (from origin: top left)
3. centre image y position (from origin)
4. centre speech bubble x position (from origin)
5. centre speech bubble y position (from origin)
6. speech bubble width
7. triangle point x1
8. triangle point y1
9. triangle point x2
10. triangle point y2
11. triangle point x3
12. triangle point y3
13. centre triangle sprite x position (from origin)
--]]

local J1 = {"images/J1.png", 320, 155, 10, 10, 215, 0, 0, 0, 16, 22, 16, 230}
table.insert(boneheads, J1)
local J2 = {"images/J2.png", 75, 150, screenWidth-225, 10, 215, 22, 0, 22, 16, 0, 16, screenWidth-230}
table.insert(boneheads, J2)
local N1 = {"images/N1.png", 75, 150, screenWidth-220, 10, 210, 22, 0, 22, 16, 0, 16, screenWidth-225}
table.insert(boneheads, N1)
local N2 = {"images/N2.png", 340, 150, 10, 10, 240, 0, 0, 0, 16, 22, 16, 255}
table.insert(boneheads, N2)
local R1 = {"images/R1.png", 330, 160, 10, 10, 220, 0, 0, 0, 16, 22, 16, 235}
table.insert(boneheads, R1)
local R2 = {"images/R2.png", 80, 150, screenWidth-220, 10, 210, 22, 0, 22, 16, 0, 16, screenWidth-225}
table.insert(boneheads, R2)

--SOME FUNCTIONS

	--Randomising boneheads
selected = boneheads[math.random(#boneheads)]

function selectRandomBonehead() --Random-but-not-repeating
	bonehead = boneheads[math.random(#boneheads)]
	if bonehead == selected then
		selectRandomBonehead()
	else
		selected = bonehead
	end
end

	--Randomising messages
function randomIntervention() --Draws on variables in "data.lua"
	return prefaces[math.random(#prefaces)] .. " " .. statements[math.random(#statements)]
end

--GAME ENVIRONMENT SETUP

function myGameSetUp()
	--Setting up a background
	gfx.setBackgroundColor(gfx.kColorBlack)
	gfx.setColor(gfx.kColorBlack)
	gfx.fillRect(0, 0, screenWidth, screenHeight)

	init_bh = selected

	--Setting up a bonehead image/splash screen
	boneheadImage = gfx.image.new(init_bh[1]) --Loading image from .png file
	assert(boneheadImage) --making sure the image was where we thought
	boneheadSprite = gfx.sprite.new(boneheadImage) --adding the image to a new sprite
	boneheadSprite:moveTo(init_bh[2], init_bh[3]) 	--placing the centre of the sprite
	boneheadSprite:add() --putting the sprite in the update cache
	
	--Setting up speech bubble, text and triangles
	local rectX, rectY, rectW, rectH, rectR = init_bh[4], init_bh[5], init_bh[6], bubbleHeight, bubbleRadius
	local triX1, triY1, triX2, triY2, triX3, triY3 = init_bh[7], init_bh[8], init_bh[9], init_bh[10], init_bh[11], init_bh[12]
	local triangleSpriteX = init_bh[13]
	
	local bubbleImage = gfx.image.new(rectW, rectH) --generates new empty image of specified dimensions, for main speech bubble box
	gfx.pushContext(bubbleImage) 	--establishes the image as the thing to be drawn to (performance-wise, better than constantly redrawing the sprite every frame). See also lockFocus() method
		gfx.setColor(gfx.kColorWhite)
		gfx.fillRoundRect(0, 0, rectW, rectH, rectR) --NOTE: x and y are 0 as we're drawing in the boundaries of the image, which we can move around the screen later
		msg = "Ah, come in, come in, welcome to the illustrious \"Seminar Room 4\"; we're just in the middle of our weekly Wittgenstein reading group. Take a seat and press [B] to hear the debate."
		gfx.drawTextInRect(msg, 10, 10, rectW-20, rectH-20) -- Sizing keeps a 10px border round the text box
	gfx.popContext() -- Closing the context loop
	bubbleSprite = gfx.sprite.new(bubbleImage)
	bubbleSprite:moveTo(rectX+(rectW/2), rectY+(rectH/2))
	bubbleSprite:add()
	
	local triangleImage = gfx.image.new(22, 16) --generating empty image for speech bubble triangle
	gfx.pushContext(triangleImage)
		gfx.setColor(gfx.kColorWhite)
		gfx.fillTriangle(triX1, triY1, triX2, triY2, triX3, triY3)
	gfx.popContext()
	triangleSprite = gfx.sprite.new(triangleImage) 
	triangleSprite:moveTo(triangleSpriteX, bubbleHeight-3)
	triangleSprite:add()
		
end

myGameSetUp() 	--this runs once, configuring the game and running the 'splash screen', then everything else can be done by calling pd.update() 30 times a second

--GAME LOOP

function pd.update()
	--Poll the controls and do stuff
	if pd.buttonJustPressed(pd.kButtonB) then
		boneheadSprite:remove() --Clearing sprites from screen
		bubbleSprite:remove()
		triangleSprite:remove()
		
		selectRandomBonehead() --Selecting new sprites to load
		new_bh = selected
		
		--Setting up a bonehead image
		boneheadImage = gfx.image.new(new_bh[1])
		assert(boneheadImage)
		boneheadSprite = gfx.sprite.new(boneheadImage)
		boneheadSprite:moveTo(new_bh[2], new_bh[3])
		boneheadSprite:add()
		
	--Setting up speech bubble and text
	local rectX, rectY, rectW, rectH, rectR = new_bh[4], new_bh[5], new_bh[6], bubbleHeight, bubbleRadius
	local triX1, triY1, triX2, triY2, triX3, triY3 = new_bh[7], new_bh[8], new_bh[9], new_bh[10], new_bh[11], new_bh[12]
	local triangleSpriteX = new_bh[13]

	local bubbleImage = gfx.image.new(rectW, rectH)
	gfx.pushContext(bubbleImage)
		gfx.setColor(gfx.kColorWhite)
		gfx.fillRoundRect(0, 0, rectW, rectH, rectR)
		msg = randomIntervention()
		gfx.drawTextInRect(msg, 10, 10, rectW-20, rectH-20)
	gfx.popContext()
	bubbleSprite = gfx.sprite.new(bubbleImage)
	bubbleSprite:moveTo(rectX+(rectW/2), rectY+(rectH/2))
	bubbleSprite:add()	
	
	local triangleImage = gfx.image.new(22, 16)
	gfx.pushContext(triangleImage)
		gfx.setColor(gfx.kColorWhite)
		gfx.fillTriangle(triX1, triY1, triX2, triY2, triX3, triY3)
	gfx.popContext()
	triangleSprite = gfx.sprite.new(triangleImage) 
	triangleSprite:moveTo(triangleSpriteX, bubbleHeight-3)
	triangleSprite:add()
	
	end

	gfx.sprite.update() --draw sprites
	pd.timer.updateTimers() 	--keep timers updated (not necessary here, but in most other games it will be, e.g. ones with animation)
	
end