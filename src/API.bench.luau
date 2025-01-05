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
		[`add-{DIM}`] = function(profiler: BenchmarkProfiler, parameter: Parameter)
			Util.addU8(Canvas, parameter.AU8, parameter.BU8, parameter.GU8, parameter.RU8)
		end,
		[`apply-saturation-{DIM}`] = function(profiler: BenchmarkProfiler, parameter: Parameter)
			Util.applySaturation(Canvas, parameter.SaturationF)
		end,
		[`apply-value-{DIM}`] = function(profiler: BenchmarkProfiler, parameter: Parameter)
			Util.applyValue(Canvas, parameter.ValueF)
		end,
		[`clear-channel-{DIM}`] = function(profiler: BenchmarkProfiler, parameter: Parameter)
			Util.clearChannel(Canvas, parameter.RGBAChannel)
		end,
		[`clone-channel-{DIM}`] = function(profiler: BenchmarkProfiler, parameter: Parameter)
			Util.cloneChannel(Canvas, parameter.RGBAChannel):Destroy()
		end,
		[`crop-{DIM}`] = function(profiler: BenchmarkProfiler, parameter: Parameter)
			Util.crop(Canvas, parameter.Area.Min, parameter.Area.Max):Destroy()
		end,
		[`fill-{DIM}`] = function(profiler: BenchmarkProfiler, parameter: Parameter)
			Util.fillU8(Canvas, parameter.AU8, parameter.BU8, parameter.GU8, parameter.RU8)
		end,
		[`invert-channel-{DIM}`] = function(profiler: BenchmarkProfiler, parameter: Parameter)
			Util.invertChannel(Canvas, parameter.RGBAChannel)
		end,
		[`isolate-channel-{DIM}`] = function(profiler: BenchmarkProfiler, parameter: Parameter)
			Util.isolateChannel(Canvas, parameter.RGBAChannel)
		end,
		[`multiply-{DIM}`] = function(profiler: BenchmarkProfiler, parameter: Parameter)
			Util.multiplyU8(Canvas, parameter.RU8, parameter.GU8, parameter.BU8, parameter.AU8)
		end,
		[`overwrite-{DIM}`] = function(profiler: BenchmarkProfiler, parameter: Parameter)
			Util.overwriteU8(
				Canvas,
				if parameter.FocusR then parameter.RU8 else nil,
				if parameter.FocusG then parameter.GU8 else nil,
				if parameter.FocusB then parameter.BU8 else nil,
				if parameter.FocusA then parameter.AU8 else nil
			)
		end,
		[`replace-{DIM}`] = function(profiler: BenchmarkProfiler, parameter: Parameter)
			Util.replace(Canvas, Source)
		end,
		[`resize-{DIM}`] = function(profiler: BenchmarkProfiler, parameter: Parameter)
			Util.resize(Canvas, parameter.Size, parameter.SamplingMode):Destroy()
		end,
		[`shift-channel-rgb-{DIM}`] = function(profiler: BenchmarkProfiler, parameter: Parameter)
			Util.shiftChannelRGB(Canvas, parameter.OffsetRGB)
		end,
		[`shift-channel-rgba-{DIM}`] = function(profiler: BenchmarkProfiler, parameter: Parameter)
			Util.shiftChannelRGBA(Canvas, parameter.OffsetRGBA)
		end,
		[`split-rgb-{DIM}`] = function(profiler: BenchmarkProfiler, parameter: Parameter)
			local r, g, b = Util.splitRGB(Canvas)
			r:Destroy()
			g:Destroy()
			b:Destroy()
		end,
		[`split-rgba-{DIM}`] = function(profiler: BenchmarkProfiler, parameter: Parameter)
			local r, g, b, a = Util.splitRGBA(Canvas)
			r:Destroy()
			g:Destroy()
			b:Destroy()
			a:Destroy()
		end,
		[`tint-{DIM}`] = function(profiler: BenchmarkProfiler, parameter: Parameter)
			Util.tint(Canvas, parameter.Tint)
		end,
		[`to-mono-{DIM}`] = function(profiler: BenchmarkProfiler, parameter: Parameter)
			Util.toMono(Canvas, parameter.RGBAChannel)
		end,
	},
} :: BenchModule<Parameter>
