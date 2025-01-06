--!strict
-- Services
local AssetService = game:GetService(`AssetService`)
-- Packages
-- Modules
local Util = require(game.ReplicatedStorage.package.Wally.Main)
-- Types
type Parameter = {
	RGBChannel: Util.Channel,
	RGBAChannel: Util.Channel,
	SaturationF: number,
	ValueF: number,
	HueF: number,
	RU8: number,
	GU8: number,
	BU8: number,
	AU8: number,
	FocusR: boolean,
	FocusG: boolean,
	FocusB: boolean,
	FocusA: boolean,
	Area: Rect,
	Size: Vector2,
	SamplingMode: Enum.ResamplerMode,
	OffsetRGB: number,
	OffsetRGBA: number,
	Tint: Color3,
}
-- Constants
local DIM = 512
-- Variables
-- References
local Canvas = AssetService:CreateEditableImage({ Size = Vector2.one * DIM })
local Source = AssetService:CreateEditableImage({ Size = Canvas.Size })

-- Private Functions
local function indexToChannel(i: number): Util.Channel
	for k, v in pairs(Util.CHANNEL_INDEX) do
		if v == i then
			return k :: Util.Channel
		end
	end
	error(`Invalid channel index: {i}`)
end
-- Class
return {
	ParameterGenerator = function(): Parameter
		local rng = Random.new()
		local rbgChannelIndex = rng:NextInteger(0, 2)
		local rgbaChannelIndex = rng:NextInteger(0, 3)

		local min = Vector2.new(rng:NextInteger(0, Canvas.Size.X - 2), rng:NextInteger(0, Canvas.Size.Y - 2))
		local max = Vector2.new(
			rng:NextInteger(min.X + 1, Canvas.Size.X - 1),
			rng:NextInteger(min.Y + 1, Canvas.Size.Y - 1)
		)

		return {
			RGBChannel = indexToChannel(rbgChannelIndex),
			RGBAChannel = indexToChannel(rgbaChannelIndex),
			SaturationF = rng:NextNumber(),
			ValueF = rng:NextNumber(),
			HueF = rng:NextNumber(),
			RU8 = rng:NextInteger(0, 255),
			GU8 = rng:NextInteger(0, 255),
			BU8 = rng:NextInteger(0, 255),
			AU8 = rng:NextInteger(0, 255),
			FocusR = rng:NextNumber() < 0.5,
			FocusG = rng:NextNumber() < 0.5,
			FocusB = rng:NextNumber() < 0.5,
			FocusA = rng:NextNumber() < 0.5,
			Area = Rect.new(min, max),
			Size = Vector2.new(rng:NextInteger(2, Canvas.Size.X * 2), rng:NextInteger(2, Canvas.Size.Y * 2)),
			SamplingMode = Enum.ResamplerMode:GetEnumItems()[rng:NextInteger(
				1,
				#Enum.ResamplerMode:GetEnumItems()
			)],
			OffsetRGB = rng:NextInteger(1, 2),
			OffsetRGBA = rng:NextInteger(1, 3),
			Tint = Color3.fromRGB(rng:NextInteger(0, 255), rng:NextInteger(0, 255), rng:NextInteger(0, 255)),
		}
	end,
	AfterAll = function()
		Canvas:Destroy()
		Source:Destroy()
	end,
	BeforeAll = function()
		Util.fillU8(
			Canvas,
			math.random(0, 255),
			math.random(0, 255),
			math.random(0, 255),
			math.random(0, 255)
		)
	end,
	AfterEach = function() end,
	BeforeEach = function() end,
	Functions = {
		[`write-for-each-px-in-channel-{DIM}`] = function(profiler: BenchmarkProfiler, parameter: Parameter)
			Util.writeForEachInPixelChannel(Canvas, parameter.RGBAChannel, function(value: number)
				return value
			end)
		end,
		[`write-for-each-px-hsv-{DIM}`] = function(profiler: BenchmarkProfiler, parameter: Parameter)
			Util.writeForEachPixelHSV(Canvas, function(hF: number, sF: number, vF: number)
				return hF, sF, vF
			end)
		end,
		[`write-for-each-px-hsva-{DIM}`] = function(profiler: BenchmarkProfiler, parameter: Parameter)
			Util.writeForEachPixelHSVA(Canvas, function(hF: number, sF: number, vF: number, aU8: number)
				return hF, sF, vF, aU8
			end)
		end,
		[`write-for-each-px-rgb-{DIM}`] = function(profiler: BenchmarkProfiler, parameter: Parameter)
			Util.writeForEachPixelRGB(Canvas, function(rU8: number, gU8: number, bU8: number)
				return rU8, gU8, bU8
			end)
		end,
		[`write-for-each-px-rgba-{DIM}`] = function(profiler: BenchmarkProfiler, parameter: Parameter)
			Util.writeForEachPixelRGBA(Canvas, function(rU8: number, gU8: number, bU8: number, aU8: number)
				return rU8, gU8, bU8, aU8
			end)
		end,
		[`read-for-each-px-in-channel-{DIM}`] = function(profiler: BenchmarkProfiler, parameter: Parameter)
			Util.readForEachInPixelChannel(Canvas, parameter.RGBAChannel, function(value: number) end)
		end,
		[`read-for-each-px-hsv-{DIM}`] = function(profiler: BenchmarkProfiler, parameter: Parameter)
			Util.readForEachPixelHSV(Canvas, function(hF: number, sF: number, vF: number) end)
		end,
		[`read-for-each-px-hsva-{DIM}`] = function(profiler: BenchmarkProfiler, parameter: Parameter)
			Util.readForEachPixelHSVA(Canvas, function(hF: number, sF: number, vF: number, aU8: number) end)
		end,
		[`read-for-each-px-rgb-{DIM}`] = function(profiler: BenchmarkProfiler, parameter: Parameter)
			Util.readForEachPixelRGB(Canvas, function(rU8: number, gU8: number, bU8: number) end)
		end,
		[`read-for-each-px-rgba-{DIM}`] = function(profiler: BenchmarkProfiler, parameter: Parameter)
			Util.readForEachPixelRGBA(
				Canvas,
				function(rU8: number, gU8: number, bU8: number, aU8: number) end
			)
		end,
		[`get-channel-range-u8-{DIM}`] = function(profiler: BenchmarkProfiler, parameter: Parameter)
			Util.getChannelRangeU8(Canvas, parameter.RGBAChannel)
		end,
		[`get-rgb-range-u8-{DIM}`] = function(profiler: BenchmarkProfiler, parameter: Parameter)
			Util.getRGBRangeU8(Canvas)
		end,
		[`get-rgba-range-u8-{DIM}`] = function(profiler: BenchmarkProfiler, parameter: Parameter)
			Util.getRGBARangeU8(Canvas)
		end,
	},
} :: BenchModule<Parameter>
