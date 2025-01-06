--!strict
-- Services
local AssetService = game:GetService("AssetService")
-- Packages
-- Modules
-- Types
-- Constants
-- Variables
-- References
local Canvas128 = AssetService:CreateEditableImage({ Size = Vector2.one * 128 })
local Canvas256 = AssetService:CreateEditableImage({ Size = Vector2.one * 256 })
local Canvas512 = AssetService:CreateEditableImage({ Size = Vector2.one * 512 })
local Source128 = AssetService:CreateEditableImage({ Size = Vector2.one * 128 })
local Source256 = AssetService:CreateEditableImage({ Size = Vector2.one * 256 })
local Source512 = AssetService:CreateEditableImage({ Size = Vector2.one * 512 })
-- Private Functions
function drawBuffer(source: EditableImage, canvas: EditableImage)
	canvas:WritePixelsBuffer(Vector2.zero, canvas.Size, source:ReadPixelsBuffer(Vector2.zero, canvas.Size))
end
function drawSplitBuffer(source: EditableImage, canvas: EditableImage, dim: number)
	local xReps = canvas.Size.X / dim
	assert(xReps % 1 == 0, "Canvas width must be divisible by dim")
	local yReps = canvas.Size.Y / dim
	assert(yReps % 1 == 0, "Canvas height must be divisible by dim")

	local size = Vector2.new(dim, dim)

	for x = 0, xReps - 1 do
		for y = 0, yReps - 1 do
			local xStart = x * dim
			local yStart = y * dim
			local pos = Vector2.new(xStart, yStart)
			canvas:WritePixelsBuffer(pos, size, source:ReadPixelsBuffer(pos, size))
		end
	end
end
-- Class
return {
	AfterAll = function()
		Canvas128:Destroy()
		Canvas256:Destroy()
		Canvas512:Destroy()
		Source128:Destroy()
		Source256:Destroy()
		Source512:Destroy()
	end,
	BeforeAll = function() end,
	AfterEach = function() end,
	BeforeEach = function() end,
	Functions = {
		["Buf-128"] = function(profiler: BenchmarkProfiler)
			drawBuffer(Source128, Canvas128)
		end,
		["Buf-256"] = function(profiler: BenchmarkProfiler)
			drawBuffer(Source256, Canvas256)
		end,
		["Buf-512"] = function(profiler: BenchmarkProfiler)
			drawBuffer(Source512, Canvas512)
		end,
		["Split-Buf-128"] = function(profiler: BenchmarkProfiler)
			drawSplitBuffer(Source128, Canvas128, 64)
		end,
		["Split-Buf-256"] = function(profiler: BenchmarkProfiler)
			drawSplitBuffer(Source256, Canvas256, 64)
		end,
		["Split-Buf-512"] = function(profiler: BenchmarkProfiler)
			drawSplitBuffer(Source512, Canvas512, 64)
		end,
		["DrawImage-128"] = function(profiler: BenchmarkProfiler)
			Canvas128:DrawImage(Vector2.zero, Source128, Enum.ImageCombineType.Overwrite)
		end,
		["DrawImage-256"] = function(profiler: BenchmarkProfiler)
			Canvas256:DrawImage(Vector2.zero, Source256, Enum.ImageCombineType.Overwrite)
		end,
		["DrawImage-512"] = function(profiler: BenchmarkProfiler)
			Canvas512:DrawImage(Vector2.zero, Source512, Enum.ImageCombineType.Overwrite)
		end,
	},
} :: BenchModule<number>
