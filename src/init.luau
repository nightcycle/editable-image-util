--!strict
--!native
-- Services
local AssetService = game:GetService("AssetService")
local CollectionService = game:GetService("CollectionService")

-- Packages
-- Modules

-- Types
export type Channel = "R" | "G" | "B" | "A"
-- Constants
local BINDING_TAG = "EditableImageUtilBound"
local CHANNEL_INDEX: { [Channel]: number } = table.freeze({
	R = 0,
	G = 1,
	B = 2,
	A = 3,
})
-- Variables
local DependentRegistry: { [EditableImage]: { Instance } } = {}
-- References
-- Private Functions
function newBlank(size: Vector2): EditableImage
	return AssetService:CreateEditableImage({
		Size = size,
	})
end

-- Class
local Util = {}
Util.CHANNEL_INDEX = CHANNEL_INDEX

function Util.fillU8(image: EditableImage, rU8: number, gU8: number, bU8: number, aU8: number): ()
	image:DrawRectangle(
		Vector2.zero,
		image.Size,
		Color3.fromRGB(rU8, gU8, bU8),
		1 - (math.max(aU8, 1) / 255),
		Enum.ImageCombineType.Overwrite
	)
end

function Util.fillF(image: EditableImage, rF: number, gF: number, bF: number, aF: number): ()
	Util.fillU8(image, math.round(rF * 255), math.round(gF * 255), math.round(bF * 255), math.round(aF * 255))
end

function Util.addU8(image: EditableImage, rU8: number, gU8: number, bU8: number, aU8: number): ()
	local mask = newBlank(image.Size)
	Util.fillU8(mask, rU8, gU8, bU8, aU8)
	image:DrawImage(Vector2.zero, mask, Enum.ImageCombineType.Add)
	mask:Destroy()
end

function Util.addF(image: EditableImage, rF: number, gF: number, bF: number, aF: number): ()
	Util.addU8(image, math.round(rF * 255), math.round(gF * 255), math.round(bF * 255), math.round(aF * 255))
end

function Util.splitRGB(image: EditableImage): (EditableImage, EditableImage, EditableImage)
	local r = Util.clone(image)
	Util.isolateChannel(r, "R")
	local g = Util.clone(image)
	Util.isolateChannel(g, "G")
	local b = Util.clone(image)
	Util.isolateChannel(b, "B")
	return r, g, b
end

function Util.splitRGBA(image: EditableImage): (EditableImage, EditableImage, EditableImage)
	local r, g, b = Util.splitRGB(image)
	local a = Util.clone(image)
	Util.isolateChannel(a, "A")
	return r, g, b, a
end

function Util.multiplyU8(image: EditableImage, rU8: number, gU8: number, bU8: number, aU8: number): ()
	rU8 = math.max(rU8, 1)
	gU8 = math.max(gU8, 1)
	bU8 = math.max(bU8, 1)
	aU8 = math.max(aU8, 1)

	local mask = newBlank(image.Size)
	Util.fillU8(mask, rU8, gU8, bU8, aU8)
	image:DrawImage(Vector2.zero, mask, Enum.ImageCombineType.Multiply)
	mask:Destroy()
end

function Util.multiplyF(image: EditableImage, rF: number, gF: number, bF: number, aF: number): ()
	Util.multiplyU8(
		image,
		math.round(rF * 255),
		math.round(gF * 255),
		math.round(bF * 255),
		math.round(aF * 255)
	)
end

function Util.overwriteU8(image: EditableImage, rU8: number?, gU8: number?, bU8: number?, aU8: number?): ()
	Util.multiplyU8(
		image,
		if rU8 then 1 else 255,
		if gU8 then 1 else 255,
		if bU8 then 1 else 255,
		if aU8 then 1 else 255
	)
	Util.addU8(image, rU8 or 0, gU8 or 0, bU8 or 0, aU8 or 0)
end

function Util.overwriteF(image: EditableImage, rF: number?, gF: number?, bF: number?, aF: number?): ()
	Util.overwriteU8(
		image,
		if rF then math.round(rF * 255) else nil,
		if gF then math.round(gF * 255) else nil,
		if bF then math.round(bF * 255) else nil,
		if aF then math.round(aF * 255) else nil
	)
end

function Util.shiftChannelRGBA(image: EditableImage, offset: number): ()
	offset %= 4
	if offset == 0 then
		return
	end
	local buf = image:ReadPixelsBuffer(Vector2.zero, image.Size)
	local newBuf = buffer.create(image.Size.X * image.Size.Y * 4)
	buffer.copy(newBuf, offset, buf, 0, buffer.len(buf) - offset)
	buffer.copy(newBuf, 0, buf, buffer.len(buf) - offset, offset)
	image:WritePixelsBuffer(Vector2.zero, image.Size, newBuf)
end

-- impossible until I can find a way to subtract images
-- https://stackoverflow.com/questions/8507885/shift-hue-of-an-rgb-color
-- function Util.shiftHue(image: EditableImage, hue: number): ()
-- 	hue %= 1
-- 	if hue == 0 or hue == 1 then
-- 		return
-- 	end
-- 	local rotation = math.rad(hue*360)
-- 	local cosA = math.cos(rotation)
-- 	local sinA = math.sin(rotation)
-- 	local r1 = cosA + (1.0 - cosA) / 3.0
-- 	local g1 = 1./3. * (1.0 - cosA) - math.sqrt(1./3.) * sinA
-- 	local b1 = 1./3. * (1.0 - cosA) + math.sqrt(1./3.) * sinA
-- 	local r2 = 1./3. * (1.0 - cosA) + math.sqrt(1./3.) * sinA
-- 	local g2 = cosA + 1./3.*(1.0 - cosA)
-- 	local b2 = 1./3. * (1.0 - cosA) - math.sqrt(1./3.) * sinA
-- 	local r3 = 1./3. * (1.0 - cosA) - math.sqrt(1./3.) * sinA
-- 	local g3 = 1./3. * (1.0 - cosA) + math.sqrt(1./3.) * sinA
-- 	local b3 = cosA + 1./3. * (1.0 - cosA)

-- 	local r = Util.clone(image)
-- 	Util.isolateChannel(r, 0)

-- 	local g = Util.clone(image)
-- 	Util.isolateChannel(g, 1)

-- 	local b = Util.clone(image)
-- 	Util.isolateChannel(b, 2)

-- 	local a = Util.clone(image)
-- 	Util.isolateChannel(a, 3)

-- 	local function combineChannels(targetChannel: number, rWeight: number, gWeight: number, bWeight: number): EditableImage
-- 		local rC = Util.clone(r)
-- 		local gC = Util.clone(g)
-- 		local bC = Util.clone(b)

-- 		targetChannel %= 3
-- 		if targetChannel == 0 then
-- 			Util.shiftChannelRGB(bC, 1)
-- 			Util.shiftChannelRGB(gC, 2)
-- 		elseif targetChannel == 1 then
-- 			Util.shiftChannelRGB(rC, 1)
-- 			Util.shiftChannelRGB(bC, 2)
-- 		else
-- 			Util.shiftChannelRGB(gC, 1)
-- 			Util.shiftChannelRGB(rC, 2)
-- 		end
-- 		rC:DrawImage(Vector2.zero, gC, Enum.ImageCombineType.Add)
-- 		rC:DrawImage(Vector2.zero, bC, Enum.ImageCombineType.Add)
-- 		gC:Destroy()
-- 		bC:Destroy()
-- 		return rC
-- 	end

-- 	print("r1", r1, "g1", g1, "b1", b1)
-- 	local rx = combineChannels(0, r1, g1, b1)
-- 	local gx = combineChannels(1, r2, g2, b2)
-- 	local bx = combineChannels(2, r3, g3, b3)

-- 	a:DrawImage(Vector2.zero, rx, Enum.ImageCombineType.Add)
-- 	a:DrawImage(Vector2.zero, gx, Enum.ImageCombineType.Add)
-- 	a:DrawImage(Vector2.zero, bx, Enum.ImageCombineType.Add)
-- 	image:DrawImage(Vector2.zero, a, Enum.ImageCombineType.Overwrite)
-- 	r:Destroy()
-- 	g:Destroy()
-- 	b:Destroy()
-- 	a:Destroy()
-- 	rx:Destroy()
-- 	gx:Destroy()
-- 	bx:Destroy()
-- end

function Util.moveChannel(image: EditableImage, source: Channel, target: Channel)
	local channel = Util.clone(image)
	Util.isolateChannel(channel, source)

	Util.shiftChannelRGBA(channel, (CHANNEL_INDEX[target] - CHANNEL_INDEX[source]) % 4)
	if target == "R" then
		Util.overwriteF(image, 0, nil, nil, nil)
	elseif target == "G" then
		Util.overwriteF(image, nil, 0, nil, nil)
	elseif target == "B" then
		Util.overwriteF(image, nil, nil, 0, nil)
	elseif target == "A" then
		Util.overwriteF(image, nil, nil, nil, 0)
	end
	image:DrawImage(Vector2.zero, channel, Enum.ImageCombineType.Add)
	channel:Destroy()
end

function Util.shiftChannelRGB(image: EditableImage, offset: number): ()
	offset %= 3
	if offset == 0 then
		return
	end
	local a = Util.clone(image)
	Util.isolateChannel(a, "A")
	Util.moveChannel(image, "B", "A")

	if offset == 1 then
		Util.shiftChannelRGBA(image, 1)
		image:DrawImage(Vector2.zero, a, Enum.ImageCombineType.Add)
	else
		Util.moveChannel(image, "G", "B")

		Util.shiftChannelRGBA(image, 2)
		Util.moveChannel(image, "A", "R")

		image:DrawImage(Vector2.zero, a, Enum.ImageCombineType.Add)
	end

	a:Destroy()
end

function Util.applySaturation(image: EditableImage, saturation: number): ()
	saturation = math.clamp(saturation, 0, 1)
	Util.multiplyF(image, saturation, saturation, saturation, 1)
	Util.addF(image, 1 - saturation, 1 - saturation, 1 - saturation, 0)
end

function Util.applyValue(image: EditableImage, value: number): ()
	value = math.clamp(value, 0, 1)
	Util.multiplyF(image, value, value, value, 1)
end

function Util.tint(image: EditableImage, color: Color3): ()
	Util.multiplyF(image, color.R, color.G, color.B, 1)
end

function Util.toMono(image: EditableImage, channel: Channel): ()
	if channel == "R" then
		Util.moveChannel(image, "R", "G")
		Util.moveChannel(image, "R", "B")
	elseif channel == "G" then
		Util.moveChannel(image, "G", "R")
		Util.moveChannel(image, "G", "B")
	elseif channel == "B" then
		Util.moveChannel(image, "B", "R")
		Util.moveChannel(image, "B", "G")
	elseif channel == "A" then
		Util.moveChannel(image, "A", "R")
		Util.moveChannel(image, "A", "G")
		Util.moveChannel(image, "A", "B")
	end
end

function Util.isolateChannel(image: EditableImage, channel: Channel): ()
	local offset = CHANNEL_INDEX[channel]
	offset %= 4
	if offset == 0 then
		Util.multiplyU8(image, 255, 0, 0, 0)
	elseif offset == 1 then
		Util.multiplyU8(image, 0, 255, 0, 0)
	elseif offset == 2 then
		Util.multiplyU8(image, 0, 0, 255, 0)
	else
		Util.multiplyU8(image, 0, 0, 0, 255)
	end
end

function Util.clearChannel(image: EditableImage, channel: Channel): ()
	local offset = CHANNEL_INDEX[channel]

	offset %= 4
	if offset == 0 then
		Util.multiplyU8(image, 0, 255, 255, 255)
	elseif offset == 1 then
		Util.multiplyU8(image, 255, 0, 255, 255)
	elseif offset == 2 then
		Util.multiplyU8(image, 255, 255, 0, 255)
	else
		Util.multiplyU8(image, 255, 255, 255, 0)
	end
end

function Util.cloneChannel(image: EditableImage, channel: Channel): EditableImage
	local clone = Util.clone(image)
	Util.isolateChannel(clone, channel)

	return clone
end

function Util.replace(canvas: EditableImage, source: EditableImage): ()
	canvas:DrawImage(Vector2.zero, source, Enum.ImageCombineType.Overwrite)
end

function Util.clone(image: EditableImage): EditableImage
	local cloneImage = newBlank(image.Size)

	cloneImage:DrawImage(Vector2.zero, image, Enum.ImageCombineType.Overwrite)

	return cloneImage
end

function Util.crop(image: EditableImage, min: Vector2, max: Vector2): EditableImage
	local sourceSize = image.Size

	local targetSize = max - min
	local clampedWidth = math.min(min.X + targetSize.X, sourceSize.X) - min.X
	local clampedHeight = math.min(min.Y + targetSize.Y, sourceSize.Y) - min.Y
	local clampedSize = Vector2.new(clampedWidth, clampedHeight)

	local output = newBlank(clampedSize)

	output:WritePixelsBuffer(Vector2.zero, clampedSize, output:ReadPixelsBuffer(min, max))

	return output
end

-- WARNING, this is a slower operation
function Util.invertChannel(image: EditableImage, channel: Channel): ()
	local buf = image:ReadPixelsBuffer(Vector2.zero, image.Size)
	local offset = CHANNEL_INDEX[channel]
	local rowWidth = 4 * image.Size.X
	for y=0, image.Size.Y-1 do
		local base = y * rowWidth
		for x=0, image.Size.X-1 do
			local index = base + x * 4 + offset
			buffer.writeu8(buf, index, 255 - buffer.readu8(buf, index))
		end
	end
	image:WritePixelsBuffer(Vector2.zero, image.Size, buf)
end

function Util.bind(inst: Instance, image: EditableImage): ()
	local dependents = DependentRegistry[image] or {}
	DependentRegistry[image] = dependents
	inst:AddTag(BINDING_TAG)
	if not table.find(dependents, inst) then
		table.insert(dependents, inst)
	end
end

function Util.unbind(inst: Instance, image: EditableImage): ()
	local dependents = DependentRegistry[image]
	if not dependents then
		error("Image not bound to instance")
		return
	end

	pcall(function()
		CollectionService:RemoveTag(inst, BINDING_TAG)
	end)

	local index = table.find(dependents, inst)
	if index then
		table.remove(dependents, index)
	end

	if #dependents == 0 then
		DependentRegistry[image] = nil
		image:Destroy()
	end
end

function Util.unbindAll(inst: Instance): ()
	for image, deps in pairs(DependentRegistry) do
		if table.find(deps, inst) then
			Util.unbind(inst, image)
		end
	end
end

function Util.initCleanUpListener(): () -> ()
	local isAlive = true
	local connection: RBXScriptConnection
	local function cleanUp()
		if not isAlive then
			return
		end
		isAlive = false
		connection:Disconnect()
	end

	connection = CollectionService:GetInstanceRemovedSignal(BINDING_TAG):Connect(Util.unbindAll)

	return cleanUp
end

return Util
