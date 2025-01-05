--!strict
-- Services
local AssetService = game:GetService("AssetService")
-- Packages
-- Modules
local Util = require(game.ReplicatedStorage.package.Wally.Main)
-- Types
-- Constants
-- Variables
-- References
local Canvas64 = AssetService:CreateEditableImage({ Size = Vector2.one * 64 })
local Canvas128 = AssetService:CreateEditableImage({ Size = Vector2.one * 128 })
local Canvas256 = AssetService:CreateEditableImage({ Size = Vector2.one * 256 })
local Canvas512 = AssetService:CreateEditableImage({ Size = Vector2.one * 512 })
-- Private Functions
function setValue(image: EditableImage, value: number)
	local buf = image:ReadPixelsBuffer(Vector2.zero, image.Size)
	local rowWidth = 4 * image.Size.X
	for y = 0, image.Size.Y - 1 do
		local base = y * rowWidth
		for x = 0, image.Size.X - 1 do
			local rI = base + x * 4 + 0
			local gI = base + x * 4 + 1
			local bI = base + x * 4 + 2
			buffer.writeu8(buf, rI, value * buffer.readu8(buf, rI))
			buffer.writeu8(buf, gI, value * buffer.readu8(buf, gI))
			buffer.writeu8(buf, bI, value * buffer.readu8(buf, bI))
		end
	end
	image:WritePixelsBuffer(Vector2.zero, image.Size, buf)
end
-- Class
return {
	AfterAll = function()
		Canvas64:Destroy()
		Canvas128:Destroy()
		Canvas256:Destroy()
		Canvas512:Destroy()
	end,
	BeforeAll = function() end,
	AfterEach = function() end,
	BeforeEach = function() end,
	Functions = {
		["Buf-64"] = function(profiler: BenchmarkProfiler)
			setValue(Canvas64, 0.9)
		end,
		["Buf-128"] = function(profiler: BenchmarkProfiler)
			setValue(Canvas128, 0.9)
		end,
		["Buf-256"] = function(profiler: BenchmarkProfiler)
			setValue(Canvas256, 0.9)
		end,
		["Buf-512"] = function(profiler: BenchmarkProfiler)
			setValue(Canvas512, 0.9)
		end,
		["Image-64"] = function(profiler: BenchmarkProfiler)
			Util.applyValue(Canvas64, 0.9)
		end,
		["Image-128"] = function(profiler: BenchmarkProfiler)
			Util.applyValue(Canvas128, 0.9)
		end,
		["Image-256"] = function(profiler: BenchmarkProfiler)
			Util.applyValue(Canvas256, 0.9)
		end,
		["Image-512"] = function(profiler: BenchmarkProfiler)
			Util.applyValue(Canvas512, 0.9)
		end,
	},
} :: BenchModule<number>
