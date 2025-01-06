--!strict
-- Services
local AssetService = game:GetService("AssetService")

-- Packages
-- Modules
-- Types

-- Constants
local SAMPLE_SIZE = 256
local SKIP_ENABLED = false
-- Variables
-- References

-- Class
return function(): ()
	describe("memory", function()
		if SKIP_ENABLED then
			SKIP()
		end
		local Util = require(script.Parent)
		local image: EditableImage

		if not SKIP_ENABLED then
			beforeAll(function()
				image = AssetService:CreateEditableImage({ Size = Vector2.one * 1024 })
			end)

			afterAll(function()
				image:Destroy()
			end)
		end

		describe("add", function()
			it("float", function()
				for i = 1, SAMPLE_SIZE do
					Util.addF(image, i / SAMPLE_SIZE, i / SAMPLE_SIZE, i / SAMPLE_SIZE, i / SAMPLE_SIZE)
				end
			end)

			it("u8", function()
				for i = 1, SAMPLE_SIZE do
					Util.addU8(
						image,
						255 * i / SAMPLE_SIZE,
						255 * i / SAMPLE_SIZE,
						255 * i / SAMPLE_SIZE,
						255 * i / SAMPLE_SIZE
					)
				end
			end)
		end)

		it("set-contrast", function()
			for i = 1, SAMPLE_SIZE do
				Util.setContrast(image, 1 - 1 / SAMPLE_SIZE)
			end
		end)

		it("set-brightness", function()
			for i = 1, SAMPLE_SIZE do
				Util.setBrightness(image, 1 - 1 / SAMPLE_SIZE)
			end
		end)

		it("clear-channel", function()
			for i = 1, SAMPLE_SIZE do
				Util.clearChannel(image, "R")
				Util.clearChannel(image, "G")
				Util.clearChannel(image, "B")
				Util.clearChannel(image, "A")
			end
		end)

		it("isolate-channel", function()
			for i = 1, SAMPLE_SIZE do
				Util.isolateChannel(image, "R")
				Util.isolateChannel(image, "G")
				Util.isolateChannel(image, "B")
				Util.isolateChannel(image, "A")
			end
		end)

		it("try-clone", function()
			for i = 1, SAMPLE_SIZE do
				Util.tryClone(image):unwrap():Destroy()
			end
		end)

		it("clone-channel", function()
			for i = 1, SAMPLE_SIZE do
				Util.tryCloneChannel(image, "R"):unwrap():Destroy()
				Util.tryCloneChannel(image, "G"):unwrap():Destroy()
				Util.tryCloneChannel(image, "B"):unwrap():Destroy()
				Util.tryCloneChannel(image, "A"):unwrap():Destroy()
			end
		end)

		it("try-crop", function()
			for i = 1, SAMPLE_SIZE do
				Util.tryCrop(image, Vector2.one, image.Size / 2):unwrap():Destroy()
			end
		end)

		describe("fill", function()
			it("float", function()
				for i = 1, SAMPLE_SIZE do
					Util.fillF(image, 1 / SAMPLE_SIZE, 1 / SAMPLE_SIZE, 1 / SAMPLE_SIZE, 1 / SAMPLE_SIZE)
				end
			end)
			it("u8", function()
				for i = 1, SAMPLE_SIZE do
					Util.fillU8(
						image,
						255 * 1 / SAMPLE_SIZE,
						255 * 1 / SAMPLE_SIZE,
						255 * 1 / SAMPLE_SIZE,
						255 * 1 / SAMPLE_SIZE
					)
				end
			end)
		end)
		it("invert-channel", function()
			for i = 1, SAMPLE_SIZE do
				Util.invertChannel(image, "R")
				Util.invertChannel(image, "G")
				Util.invertChannel(image, "B")
				Util.invertChannel(image, "A")
			end
		end)
		it("move-channel", function()
			for i = 1, SAMPLE_SIZE do
				Util.moveChannel(image, "R", "A")
				Util.moveChannel(image, "R", "G")
				Util.moveChannel(image, "R", "B")

				Util.moveChannel(image, "G", "R")
				Util.moveChannel(image, "G", "B")
				Util.moveChannel(image, "G", "A")

				Util.moveChannel(image, "B", "R")
				Util.moveChannel(image, "B", "G")
				Util.moveChannel(image, "B", "A")

				Util.moveChannel(image, "A", "R")
				Util.moveChannel(image, "A", "G")
				Util.moveChannel(image, "A", "B")
			end
		end)
		describe("multiply", function()
			it("float", function()
				for i = 1, SAMPLE_SIZE do
					Util.multiplyF(image, 1 / SAMPLE_SIZE, 1 / SAMPLE_SIZE, 1 / SAMPLE_SIZE, 1 / SAMPLE_SIZE)
				end
			end)
			it("u8", function()
				for i = 1, SAMPLE_SIZE do
					Util.multiplyU8(
						image,
						255 * 1 / SAMPLE_SIZE,
						255 * 1 / SAMPLE_SIZE,
						255 * 1 / SAMPLE_SIZE,
						255 * 1 / SAMPLE_SIZE
					)
				end
			end)
		end)
		describe("overwrite", function()
			it("float", function()
				for i = 1, SAMPLE_SIZE do
					Util.overwriteF(image, 1 / SAMPLE_SIZE, nil, nil, nil)
					Util.overwriteF(image, nil, 1 / SAMPLE_SIZE, nil, nil)
					Util.overwriteF(image, nil, nil, 1 / SAMPLE_SIZE, nil)
					Util.overwriteF(image, nil, nil, nil, 1 / SAMPLE_SIZE)
				end
			end)
			it("u8", function()
				for i = 1, SAMPLE_SIZE do
					Util.overwriteU8(image, 255 * 1 / SAMPLE_SIZE, nil, nil, nil)
					Util.overwriteU8(image, nil, 255 * 1 / SAMPLE_SIZE, nil, nil)
					Util.overwriteU8(image, nil, nil, 255 * 1 / SAMPLE_SIZE, nil)
					Util.overwriteU8(image, nil, nil, nil, 255 * 1 / SAMPLE_SIZE)
				end
			end)
		end)
		it("replace", function()
			for i = 1, SAMPLE_SIZE do
				local newImage = Util.tryClone(image):unwrap()
				Util.replace(image, newImage)
				newImage:Destroy()
			end
		end)
		it("try-resize", function()
			for i = 1, SAMPLE_SIZE do
				Util.tryResize(image, image.Size / 2):unwrap():Destroy()
			end
		end)

		describe("shift-channel", function()
			it("rgb", function()
				for i = 1, SAMPLE_SIZE do
					Util.shiftChannelRGB(image, 1)
					Util.shiftChannelRGB(image, 2)
				end
			end)
			it("rgba", function()
				for i = 1, SAMPLE_SIZE do
					Util.shiftChannelRGBA(image, 1)
					Util.shiftChannelRGBA(image, 2)
					Util.shiftChannelRGBA(image, 3)
				end
			end)
		end)

		describe("try-split", function()
			it("rgb", function()
				for i = 1, SAMPLE_SIZE do
					local rgb = Util.trySplitRGB(image):unwrap()
					rgb.R:Destroy()
					rgb.G:Destroy()
					rgb.B:Destroy()
				end
			end)
			it("rgba", function()
				for i = 1, SAMPLE_SIZE do
					local rgba = Util.trySplitRGBA(image):unwrap()
					rgba.R:Destroy()
					rgba.G:Destroy()
					rgba.B:Destroy()
					rgba.A:Destroy()
				end
			end)
		end)

		it("tint", function()
			for i = 1, SAMPLE_SIZE do
				Util.tint(image, Color3.new(1, 0, 0))
			end
		end)

		it("to-mono", function()
			for i = 1, SAMPLE_SIZE do
				Util.toMono(image, "R")
				Util.toMono(image, "G")
				Util.toMono(image, "B")
				Util.toMono(image, "A")
			end
		end)
	end)
end
