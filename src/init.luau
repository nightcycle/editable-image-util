--!strict
--!native
-- Services
local AssetService = game:GetService("AssetService")

-- Packages
local Result = require(script.Parent.Result)
-- Modules=
-- Types
export type Result<V, E> = Result.Result<V, E>
export type Channel = "R" | "G" | "B" | "A"
-- Constants
local CHANNEL_INDEX: { [Channel]: number } = table.freeze({
	R = 0,
	G = 1,
	B = 2,
	A = 3,
})
-- Variables
-- References
-- Private Functions

-- Class
local Util = {}
Util.CHANNEL_INDEX = CHANNEL_INDEX

function Util.tryCreateEditableImage(size: Vector2): Result<EditableImage, string>
	local image = AssetService:CreateEditableImage({
		Size = size,
	})
	if image then
		return Result.ok(image)
	else
		return Result.err(`Not enough memory to create image of size ({size.X}, {size.Y})`)
	end
end

function Util.tryClone(image: EditableImage): Result<EditableImage, string>
	return Util.tryCreateEditableImage(image.Size):match(function(clone: EditableImage)
		clone:DrawImage(Vector2.zero, image, Enum.ImageCombineType.Overwrite)
		return Result.ok(clone)
	end, function(err: string)
		return Result.err(err)
	end)
end

function Util.tryCloneChannel(image: EditableImage, channel: Channel): Result<EditableImage, string>
	return Util.tryClone(image):match(function(clone: EditableImage)
		Util.isolateChannel(clone, channel)
		return Result.ok(clone)
	end, function(err: string)
		return Result.err(err)
	end)
end

function Util.tryCrop(image: EditableImage, min: Vector2, max: Vector2): Result<EditableImage, string>
	local sourceSize = image.Size

	local targetSize = max - min
	local clampedWidth = math.min(targetSize.X, sourceSize.X)
	local clampedHeight = math.min(targetSize.Y, sourceSize.Y)
	local clampedSize = Vector2.new(clampedWidth, clampedHeight)

	return Util.tryCreateEditableImage(clampedSize):match(function(output: EditableImage)
		output:WritePixelsBuffer(Vector2.zero, clampedSize, image:ReadPixelsBuffer(min, clampedSize))
		return Result.ok(output)
	end, function(err: string)
		return Result.err(err)
	end)
end

function Util.tryResize(
	image: EditableImage,
	size: Vector2,
	samplingMode: Enum.ResamplerMode?
): Result<EditableImage, string>
	return Util.tryCreateEditableImage(size):match(function(scaledImage: EditableImage)
		local scale = Vector2.new(size.X / (image.Size.X - 0), size.Y / (image.Size.Y - 0))
		scaledImage:DrawImageTransformed(size / 2, scale, 0, image, {
			CombineType = Enum.ImageCombineType.Overwrite,
			SamplingMode = samplingMode or Enum.ResamplerMode.Default,
		})
		return Result.ok(scaledImage)
	end, function(err: string)
		return Result.err(err)
	end)
end

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

function Util.subtractU8(image: EditableImage, rU8: number, gU8: number, bU8: number, aU8: number): ()
	if aU8 == 0 then
		Util.readForEachPixelRGB(image, function(r, g, b)
			return r - rU8, g - gU8, b - bU8
		end)
	else
		Util.readForEachPixelRGBA(image, function(r, g, b, a)
			return r - rU8, g - gU8, b - bU8, a - aU8
		end)
	end
end

function Util.subtractF(image: EditableImage, rF: number, gF: number, bF: number, aF: number): ()
	Util.subtractU8(
		image,
		math.round(rF * 255),
		math.round(gF * 255),
		math.round(bF * 255),
		math.round(aF * 255)
	)
end

function Util.addU8(image: EditableImage, rU8: number, gU8: number, bU8: number, aU8: number): ()
	image:DrawRectangle(
		Vector2.zero,
		image.Size,
		Color3.fromRGB(rU8, gU8, bU8),
		1 - (math.max(aU8, 1) / 255),
		Enum.ImageCombineType.Add
	)
	-- Util.tryCreateEditableImage(image.Size):match(function(mask: EditableImage)
	-- 	Util.fillU8(mask, rU8, gU8, bU8, aU8)
	-- 	-- image:DrawImage(Vector2.zero, mask, Enum.ImageCombineType.Add)
	-- 	image:DrawRectangle(
	-- 		Vector2.zero,
	-- 		image.Size,
	-- 		Color3.fromRGB(rU8, gU8, bU8),
	-- 		1 - (math.max(aU8, 1) / 255),
	-- 		Enum.ImageCombineType.Add
	-- 	)
	-- 	mask:Destroy()
	-- 	return nil
	-- end, function(err: string)
	-- 	rU8 = math.round(rU8)
	-- 	gU8 = math.round(gU8)
	-- 	bU8 = math.round(bU8)
	-- 	aU8 = math.round(aU8)
	-- 	local function updateChannel(channel: Channel, addU8: number)
	-- 		Util.writeForEachInPixelChannel(image, channel, function(vU8)
	-- 			return vU8 + addU8
	-- 		end)
	-- 	end
	-- 	local function updateRGB()
	-- 		Util.writeForEachPixelRGB(image, function(r, g, b)
	-- 			return r + rU8, g + gU8, b + bU8
	-- 		end)
	-- 	end
	-- 	local function updateRGBA()
	-- 		Util.writeForEachPixelRGBA(image, function(r, g, b, a)
	-- 			return r + rU8, g + gU8, b + bU8, a + aU8
	-- 		end)
	-- 	end
	-- 	if rU8 ~= 0 then
	-- 		if gU8 == 0 and bU8 == 0 and aU8 == 0 then
	-- 			updateChannel("R", rU8)
	-- 		elseif aU8 == 0 then
	-- 			updateRGB()
	-- 		else
	-- 			updateRGBA()
	-- 		end
	-- 	elseif gU8 ~= 0 then
	-- 		if bU8 == 0 and aU8 == 0 then
	-- 			updateChannel("G", gU8)
	-- 		elseif aU8 == 0 then
	-- 			updateRGB()
	-- 		else
	-- 			updateRGBA()
	-- 		end
	-- 	elseif bU8 ~= 0 then
	-- 		if aU8 == 0 then
	-- 			updateChannel("B", bU8)
	-- 		else
	-- 			updateRGBA()
	-- 		end
	-- 	elseif aU8 ~= 0 then
	-- 		updateChannel("A", aU8)
	-- 	end
	-- 	return nil
	-- end)
end

function Util.addF(image: EditableImage, rF: number, gF: number, bF: number, aF: number): ()
	Util.addU8(image, math.round(rF * 255), math.round(gF * 255), math.round(bF * 255), math.round(aF * 255))
end

function Util.trySplitRGB(image: EditableImage): Result<{
	R: EditableImage,
	G: EditableImage,
	B: EditableImage,
}, string>
	return Util.tryCloneChannel(image, "R"):match(function(r: EditableImage)
		return Util.tryCloneChannel(image, "G"):match(function(g: EditableImage)
			return Util.tryCloneChannel(image, "B"):match(function(b: EditableImage)
				local out = { R = r, G = g, B = b }
				table.freeze(out)
				return Result.ok(out)
			end, function(err: string)
				r:Destroy()
				g:Destroy()
				return Result.err(err)
			end)
		end, function(err: string)
			r:Destroy()
			return Result.err(err)
		end)
	end, function(err: string)
		return Result.err(err)
	end)
end

function Util.trySplitRGBA(image: EditableImage): Result<{
	R: EditableImage,
	G: EditableImage,
	B: EditableImage,
	A: EditableImage,
}, string>
	return Util.tryCloneChannel(image, "R"):match(function(r: EditableImage)
		return Util.tryCloneChannel(image, "G"):match(function(g: EditableImage)
			return Util.tryCloneChannel(image, "B"):match(function(b: EditableImage)
				return Util.tryCloneChannel(image, "A"):match(function(a: EditableImage)
					local out = { R = r, G = g, B = b, A = a }
					table.freeze(out)
					return Result.ok(out)
				end, function(err: string)
					r:Destroy()
					g:Destroy()
					b:Destroy()
					return Result.err(err)
				end)
			end, function(err: string)
				r:Destroy()
				g:Destroy()
				return Result.err(err)
			end)
		end, function(err: string)
			r:Destroy()
			return Result.err(err)
		end)
	end, function(err: string)
		return Result.err(err)
	end)
end

function Util.multiplyU8(image: EditableImage, rU8: number, gU8: number, bU8: number, aU8: number): ()
	if rU8 > 255 or gU8 > 255 or bU8 > 255 or aU8 > 255 then
		local rF = rU8 / 255
		local gF = gU8 / 255
		local bF = bU8 / 255
		if aU8 == 255 then
			Util.writeForEachPixelRGB(image, function(r, g, b)
				return r * rF, g * gF, b * bF
			end)
		else
			local aF = aU8 / 255
			Util.writeForEachPixelRGBA(image, function(r, g, b, a)
				return r * rF, g * gF, b * bF, a * aF
			end)
		end
	else
		rU8 = math.round(rU8)
		gU8 = math.round(gU8)
		bU8 = math.round(bU8)
		aU8 = math.round(aU8)

		-- needs to be clamped at 1, otherwise stuff breaks?
		rU8 = math.clamp(rU8, 1, 255)
		gU8 = math.clamp(gU8, 1, 255)
		bU8 = math.clamp(bU8, 1, 255)
		aU8 = math.clamp(aU8, 1, 255)

		image:DrawRectangle(
			Vector2.zero,
			image.Size,
			Color3.fromRGB(rU8, gU8, bU8),
			1 - (math.max(aU8, 1) / 255),
			Enum.ImageCombineType.Multiply
		)

		-- Util.tryCreateEditableImage(image.Size):match(function(mask: EditableImage)
		-- 	Util.fillU8(mask, rU8, gU8, bU8, aU8)
		-- 	image:DrawImage(Vector2.zero, mask, Enum.ImageCombineType.Multiply)
		-- 	mask:Destroy()
		-- 	return nil
		-- end, function(err: string)
		-- 	local rF = rU8 / 255
		-- 	local gF = gU8 / 255
		-- 	local bF = bU8 / 255
		-- 	local aF = aU8 / 255
		-- 	local function updateChannel(channel: Channel, multiF: number)
		-- 		Util.writeForEachInPixelChannel(image, channel, function(vU8)
		-- 			return vU8 * multiF
		-- 		end)
		-- 	end
		-- 	local function updateRGB()
		-- 		Util.writeForEachPixelRGB(image, function(r, g, b)
		-- 			return r * rF, g * gF, b * bF
		-- 		end)
		-- 	end
		-- 	local function updateRGBA()
		-- 		Util.writeForEachPixelRGBA(image, function(r, g, b, a)
		-- 			return r * rF, g * gF, b * bF, a * aF
		-- 		end)
		-- 	end
		-- 	if rU8 ~= 255 then
		-- 		if gU8 == 255 and bU8 == 255 and aU8 == 255 then
		-- 			updateChannel("R", rF)
		-- 		elseif aU8 == 255 then
		-- 			updateRGB()
		-- 		else
		-- 			updateRGBA()
		-- 		end
		-- 	elseif gU8 ~= 255 then
		-- 		if bU8 == 255 and aU8 == 255 then
		-- 			updateChannel("G", gF)
		-- 		elseif aU8 == 255 then
		-- 			updateRGB()
		-- 		else
		-- 			updateRGBA()
		-- 		end
		-- 	elseif bU8 ~= 255 then
		-- 		if aU8 == 255 then
		-- 			updateChannel("B", bF)
		-- 		else
		-- 			updateRGBA()
		-- 		end
		-- 	elseif aU8 ~= 255 then
		-- 		updateChannel("A", aF)
		-- 	end
		-- 	return nil
		-- end)
	end
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

function Util.shiftChannelRGB(image: EditableImage, offset: number): ()
	offset %= 3
	if offset == 0 then
		return
	end
	if offset == 1 then
		Util.writeForEachPixelRGB(image, function(rU8, gU8, bU8)
			return bU8, rU8, gU8
		end)
	else
		Util.writeForEachPixelRGB(image, function(rU8, gU8, bU8)
			return gU8, bU8, rU8
		end)
	end
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

function Util.forEachPixelXY(
	image: EditableImage,
	isReadOnly: boolean,
	callback: (buf: buffer, x: number, y: number) -> ()
): ()
	local buf = image:ReadPixelsBuffer(Vector2.zero, image.Size)
	local xReps = image.Size.X - 1
	for y = 0, image.Size.Y - 1 do
		for x = 0, xReps do
			callback(buf, x, y)
		end
	end
	if not isReadOnly then
		image:WritePixelsBuffer(Vector2.zero, image.Size, buf)
	end
end

function Util.forEachPixelXYI(
	image: EditableImage,
	isReadOnly: boolean,
	callback: (buf: buffer, x: number, y: number, i: number) -> ()
): ()
	local buf = image:ReadPixelsBuffer(Vector2.zero, image.Size)
	local rowWidth = 4 * image.Size.X
	local xReps = image.Size.X - 1
	for y = 0, image.Size.Y - 1 do
		local base = y * rowWidth
		for x = 0, xReps do
			callback(buf, x, y, base + x * 4)
		end
	end
	if not isReadOnly then
		image:WritePixelsBuffer(Vector2.zero, image.Size, buf)
	end
end

function Util.forEachPixelStartIndex(
	image: EditableImage,
	isReadOnly: boolean,
	callback: (buf: buffer, i: number) -> ()
): ()
	local buf = image:ReadPixelsBuffer(Vector2.zero, image.Size)
	local rowWidth = 4 * image.Size.X
	local xReps = image.Size.X - 1
	for y = 0, image.Size.Y - 1 do
		local base = y * rowWidth
		for x = 0, xReps do
			callback(buf, base + x * 4)
		end
	end
	if not isReadOnly then
		image:WritePixelsBuffer(Vector2.zero, image.Size, buf)
	end
end

function Util.readForEachPixelRGB(
	image: EditableImage,
	callback: (rU8: number, gU8: number, bU8: number) -> ()
): ()
	Util.forEachPixelStartIndex(image, true, function(buf: buffer, i: number)
		callback(buffer.readu8(buf, i + 0), buffer.readu8(buf, i + 1), buffer.readu8(buf, i + 2))
	end)
end

function Util.writeForEachPixelRGB(
	image: EditableImage,
	callback: (rU8: number, gU8: number, bU8: number) -> (number, number, number)
): ()
	Util.forEachPixelStartIndex(image, false, function(buf: buffer, i: number)
		local rI = i + 0
		local gI = i + 1
		local bI = i + 2
		local r, g, b = callback(buffer.readu8(buf, rI), buffer.readu8(buf, gI), buffer.readu8(buf, bI))
		buffer.writeu8(buf, rI, r)
		buffer.writeu8(buf, gI, g)
		buffer.writeu8(buf, bI, b)
	end)
end

function Util.readForEachPixelRGBA(
	image: EditableImage,
	callback: (
		rU8: number,
		gU8: number,
		bU8: number,
		aU8: number
	) -> ()
): ()
	Util.forEachPixelStartIndex(image, true, function(buf: buffer, i: number)
		callback(
			buffer.readu8(buf, i + 0),
			buffer.readu8(buf, i + 1),
			buffer.readu8(buf, i + 2),
			buffer.readu8(buf, i + 3)
		)
	end)
end

function Util.writeForEachPixelRGBA(
	image: EditableImage,
	callback: (
		rU8: number,
		gU8: number,
		bU8: number,
		aU8: number
	) -> (number, number, number, number)
): ()
	Util.forEachPixelStartIndex(image, false, function(buf: buffer, i: number)
		local rI = i + 0
		local gI = i + 1
		local bI = i + 2
		local aI = i + 3
		local rU8, gU8, bU8, aU8 = callback(
			buffer.readu8(buf, rI),
			buffer.readu8(buf, gI),
			buffer.readu8(buf, bI),
			buffer.readu8(buf, aI)
		)
		buffer.writeu8(buf, rI, rU8)
		buffer.writeu8(buf, gI, gU8)
		buffer.writeu8(buf, bI, bU8)
		buffer.writeu8(buf, aI, aU8)
	end)
end

do
	-- https://math.stackexchange.com/questions/556341/rgb-to-hsv-color-conversion-algorithm
	local function toHSV(rF: number, gF: number, bF: number): (number, number, number)
		local maxC = math.max(rF, gF, bF)
		local minC = math.min(rF, gF, bF)
		local rng = (maxC - minC)
		if rng == 0 then
			return 0, 0, maxC
		end

		local vF = maxC
		local sF = rng / maxC
		local rC = (maxC - rF) / rng
		local gC = (maxC - gF) / rng
		local bC = (maxC - bF) / rng
		local hF: number
		if rF == maxC then
			hF = bC - gC
		elseif gF == maxC then
			hF = 2 + rC - bC
		else
			hF = 4 + gC - rC
		end
		hF /= 6
		hF %= 1

		return hF, sF, vF
	end

	local function toRGB(hF: number, sF: number, vF: number): (number, number, number)
		local h6 = hF * 6
		local i = math.floor(h6)
		local f = h6 - i

		if i < 3 then
			if i <= 1 then
				if i == 0 then --i=0
					return vF, vF * (1 - ((1 - f) * sF)), vF * (1 - sF)
				else -- i=1
					return vF * (1 - (f * sF)), vF, vF * (1 - sF)
				end
			else -- i=2
				return vF * (1 - sF), vF, vF * (1 - ((1 - f) * sF))
			end
		else
			if i == 3 then -- i=3
				return vF * (1 - sF), vF * (1 - (f * sF)), vF
			else
				if i == 4 then -- i=4
					return vF * (1 - ((1 - f) * sF)), vF * (1 - sF), vF
				else -- i=5
					return vF, vF * (1 - sF), vF * (1 - (f * sF))
				end
			end
		end
	end

	function Util.readForEachPixelHSVA(
		image: EditableImage,
		callback: (
			hF: number,
			sF: number,
			vF: number,
			aU8: number
		) -> ()
	): ()
		Util.forEachPixelStartIndex(image, true, function(buf: buffer, i: number)
			local rI = i + 0
			local gI = i + 1
			local bI = i + 2
			local aI = i + 3
			local rU8, gU8, bU8, aU8 =
				buffer.readu8(buf, rI), buffer.readu8(buf, gI), buffer.readu8(buf, bI), buffer.readu8(buf, aI)
			local hF, sF, vF = toHSV(rU8 / 255, gU8 / 255, bU8 / 255)
			callback(hF, sF, vF, aU8)
		end)
	end

	function Util.writeForEachPixelHSVA(
		image: EditableImage,
		callback: (
			hF: number,
			sF: number,
			vF: number,
			aU8: number
		) -> (number, number, number, number)
	): ()
		Util.forEachPixelStartIndex(image, false, function(buf: buffer, i: number)
			local rI = i + 0
			local gI = i + 1
			local bI = i + 2
			local aI = i + 3
			local rU8, gU8, bU8, aU8 =
				buffer.readu8(buf, rI), buffer.readu8(buf, gI), buffer.readu8(buf, bI), buffer.readu8(buf, aI)
			local hF, sF, vF = toHSV(rU8 / 255, gU8 / 255, bU8 / 255)
			hF, sF, vF, aU8 = callback(hF, sF, vF, aU8)
			local rF, gF, bF = toRGB(hF, sF, vF)
			buffer.writeu8(buf, rI, rF * 255)
			buffer.writeu8(buf, gI, gF * 255)
			buffer.writeu8(buf, bI, bF * 255)
			buffer.writeu8(buf, aI, aU8)
		end)
	end

	function Util.readForEachPixelHSV(
		image: EditableImage,
		callback: (hF: number, sF: number, vF: number) -> ()
	): ()
		Util.forEachPixelStartIndex(image, true, function(buf: buffer, i: number)
			local rI = i + 0
			local gI = i + 1
			local bI = i + 2
			local rU8, gU8, bU8 = buffer.readu8(buf, rI), buffer.readu8(buf, gI), buffer.readu8(buf, bI)
			local hF, sF, vF = toHSV(rU8 / 255, gU8 / 255, bU8 / 255)
			callback(hF, sF, vF)
		end)
	end

	function Util.writeForEachPixelHSV(
		image: EditableImage,
		callback: (
			hF: number,
			sF: number,
			vF: number
		) -> (number, number, number)
	): ()
		Util.forEachPixelStartIndex(image, false, function(buf: buffer, i: number)
			local rI = i + 0
			local gI = i + 1
			local bI = i + 2
			local rU8, gU8, bU8 = buffer.readu8(buf, rI), buffer.readu8(buf, gI), buffer.readu8(buf, bI)
			local hF, sF, vF = toHSV(rU8 / 255, gU8 / 255, bU8 / 255)
			hF, sF, vF = callback(hF, sF, vF)
			local rF, gF, bF = toRGB(hF, sF, vF)
			buffer.writeu8(buf, rI, rF * 255)
			buffer.writeu8(buf, gI, gF * 255)
			buffer.writeu8(buf, bI, bF * 255)
		end)
	end

	function Util.addHSV(image: EditableImage, hF: number, sF: number, vF: number, skipMod: boolean?): ()
		if skipMod then
			Util.writeForEachPixelHSV(image, function(h, s, v)
				return h + hF, s + sF, v + vF
			end)
		else
			Util.writeForEachPixelHSV(image, function(h, s, v)
				return (h + hF) % 1, (s + sF) % 1, (v + vF) % 1
			end)
		end
	end

	function Util.multiplyHSV(image: EditableImage, hF: number, sF: number, vF: number, skipMod: boolean?): ()
		if skipMod then
			Util.writeForEachPixelHSV(image, function(h, s, v)
				return h * hF, s * sF, v * vF
			end)
		else
			Util.writeForEachPixelHSV(image, function(h, s, v)
				return (h * hF) % 1, (s * sF) % 1, (v * vF) % 1
			end)
		end
	end
end

function Util.readForEachInPixelChannel(
	image: EditableImage,
	channel: Channel,
	callback: (vU8: number) -> ()
): ()
	if channel == "R" then
		Util.forEachPixelStartIndex(image, true, function(buf: buffer, i: number)
			callback(buffer.readu8(buf, i))
		end)
	elseif channel == "G" then
		Util.forEachPixelStartIndex(image, true, function(buf: buffer, i: number)
			callback(buffer.readu8(buf, i + 1))
		end)
	elseif channel == "B" then
		Util.forEachPixelStartIndex(image, true, function(buf: buffer, i: number)
			callback(buffer.readu8(buf, i + 2))
		end)
	else
		Util.forEachPixelStartIndex(image, true, function(buf: buffer, i: number)
			callback(buffer.readu8(buf, i + 3))
		end)
	end
end

function Util.writeForEachInPixelChannel(
	image: EditableImage,
	channel: Channel,
	callback: (vU8: number) -> number
): ()
	if channel == "R" then
		Util.forEachPixelStartIndex(image, false, function(buf: buffer, i: number)
			buffer.writeu8(buf, i, callback(buffer.readu8(buf, i)))
		end)
	elseif channel == "G" then
		Util.forEachPixelStartIndex(image, false, function(buf: buffer, i: number)
			i += 1
			buffer.writeu8(buf, i, callback(buffer.readu8(buf, i)))
		end)
	elseif channel == "B" then
		Util.forEachPixelStartIndex(image, false, function(buf: buffer, i: number)
			i += 2
			buffer.writeu8(buf, i, callback(buffer.readu8(buf, i)))
		end)
	else
		Util.forEachPixelStartIndex(image, false, function(buf: buffer, i: number)
			i += 3
			buffer.writeu8(buf, i, callback(buffer.readu8(buf, i)))
		end)
	end
end

function Util.moveChannel(image: EditableImage, source: Channel, target: Channel)
	if source == target then
		return
	end
	Util.tryClone(image):match(function(channel: EditableImage)
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
		return nil
	end, function(err: string)
		if source == "R" then
			if target == "G" then
				Util.writeForEachPixelRGB(image, function(rU8, gU8, bU8)
					return rU8, rU8, bU8
				end)
			elseif target == "B" then
				Util.writeForEachPixelRGB(image, function(rU8, gU8, bU8)
					return rU8, gU8, rU8
				end)
			else -- A
				Util.writeForEachPixelRGBA(image, function(rU8, gU8, bU8, aU8)
					return rU8, gU8, bU8, rU8
				end)
			end
		elseif source == "G" then
			if target == "R" then
				Util.writeForEachPixelRGB(image, function(rU8, gU8, bU8)
					return gU8, gU8, bU8
				end)
			elseif target == "B" then
				Util.writeForEachPixelRGB(image, function(rU8, gU8, bU8)
					return rU8, gU8, gU8
				end)
			else -- A
				Util.writeForEachPixelRGBA(image, function(rU8, gU8, bU8, aU8)
					return rU8, gU8, bU8, gU8
				end)
			end
		elseif source == "B" then
			if target == "R" then
				Util.writeForEachPixelRGB(image, function(rU8, gU8, bU8)
					return bU8, gU8, bU8
				end)
			elseif target == "G" then
				Util.writeForEachPixelRGB(image, function(rU8, gU8, bU8)
					return rU8, bU8, bU8
				end)
			else -- A
				Util.writeForEachPixelRGBA(image, function(rU8, gU8, bU8, aU8)
					return rU8, gU8, bU8, bU8
				end)
			end
		else -- A
			if target == "R" then
				Util.writeForEachPixelRGBA(image, function(rU8, gU8, bU8, aU8)
					return aU8, gU8, bU8, aU8
				end)
			elseif target == "G" then
				Util.writeForEachPixelRGBA(image, function(rU8, gU8, bU8, aU8)
					return rU8, aU8, bU8, aU8
				end)
			else -- B
				Util.writeForEachPixelRGBA(image, function(rU8, gU8, bU8, aU8)
					return rU8, gU8, aU8, aU8
				end)
			end
		end
		return nil
	end)
end

function Util.setContrast(image: EditableImage, contrastF: number): ()
	contrastF = math.clamp(contrastF, 0, 1)
	Util.multiplyF(image, contrastF, contrastF, contrastF, 1)
	Util.addF(image, 1 - contrastF, 1 - contrastF, 1 - contrastF, 0)
end

function Util.setBrightness(image: EditableImage, brightnessF: number): ()
	brightnessF = math.clamp(brightnessF, 0, 1)
	Util.multiplyF(image, brightnessF, brightnessF, brightnessF, 1)
end

function Util.tint(image: EditableImage, color: Color3): ()
	Util.multiplyF(image, color.R, color.G, color.B, 1)
end

function Util.toMono(image: EditableImage, channel: Channel): ()
	if channel == "R" then
		Util.writeForEachPixelRGB(image, function(rU8, _, _)
			return rU8, rU8, rU8
		end)
	elseif channel == "G" then
		Util.writeForEachPixelRGB(image, function(_, gU8, _)
			return gU8, gU8, gU8
		end)
	elseif channel == "B" then
		Util.writeForEachPixelRGB(image, function(_, _, bU8)
			return bU8, bU8, bU8
		end)
	else -- A
		Util.writeForEachPixelRGBA(image, function(_, _, _, aU8)
			return aU8, aU8, aU8, aU8
		end)
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

function Util.replace(canvas: EditableImage, source: EditableImage): ()
	canvas:DrawImage(Vector2.zero, source, Enum.ImageCombineType.Overwrite)
end

function Util.getChannelRangeU8(image: EditableImage, channel: Channel): NumberRange
	local min = 255
	local max = 0

	Util.readForEachInPixelChannel(image, channel, function(vU8)
		if vU8 > max then
			max = vU8
		elseif vU8 < min then
			min = vU8
		end
	end)

	-- means it was never written to
	if min > max then
		min = max
	end
	if max == 0 then
		max = 255
	end
	return NumberRange.new(min, max)
end

function Util.getRGBRangeU8(image: EditableImage): NumberRange
	local min = 255
	local max = 0

	Util.readForEachPixelRGB(image, function(rU8: number, gU8: number, bU8: number)
		local maxV = math.max(rU8, gU8, bU8)
		local minV = math.min(rU8, gU8, bU8)
		if maxV > max then
			max = maxV
		end
		if minV < min then
			min = minV
		end
	end)

	-- means it was never written to
	if min > max then
		min = max
	end
	if max == 0 then
		max = 255
	end
	return NumberRange.new(min, max)
end

function Util.getRGBARangeU8(image: EditableImage): NumberRange
	local min = 255
	local max = 0

	Util.readForEachPixelRGBA(image, function(rU8: number, gU8: number, bU8: number, aU8: number)
		local maxV = math.max(rU8, gU8, bU8, aU8)
		local minV = math.min(rU8, gU8, bU8, aU8)
		if maxV > max then
			max = maxV
		end
		if minV < min then
			min = minV
		end
	end)

	-- means it was never written to
	if min > max then
		min = max
	end
	if max == 0 then
		max = 255
	end
	return NumberRange.new(min, max)
end

function Util.normalizeChannel(image: EditableImage, channel: Channel): ()
	local rangeU8 = Util.getChannelRangeU8(image, channel)
	local minU8 = rangeU8.Min
	local maxU8 = rangeU8.Max
	local weightF = (maxU8 - minU8) / 255
	Util.writeForEachInPixelChannel(image, channel, function(vU8)
		return (vU8 - minU8) / weightF
	end)
end

function Util.normalizeRGB(image: EditableImage): ()
	local rangeU8 = Util.getRGBRangeU8(image)
	local minU8 = rangeU8.Min
	local maxU8 = rangeU8.Max
	local weightF = (maxU8 - minU8) / 255
	Util.writeForEachPixelRGB(image, function(r: number, g: number, b: number)
		return (r - minU8) / weightF, (g - minU8) / weightF, (b - minU8) / weightF
	end)
end

function Util.normalizeRGBA(image: EditableImage): ()
	local rangeU8 = Util.getRGBARangeU8(image)
	local minU8 = rangeU8.Min
	local maxU8 = rangeU8.Max
	local weightF = (maxU8 - minU8) / 255
	Util.writeForEachPixelRGBA(image, function(r: number, g: number, b: number, a: number)
		return (r - minU8) / weightF, (g - minU8) / weightF, (b - minU8) / weightF, (a - minU8) / weightF
	end)
end

function Util.invertChannel(image: EditableImage, channel: Channel): ()
	Util.writeForEachInPixelChannel(image, channel, function(vU8)
		return 255 - vU8
	end)
end

return Util
