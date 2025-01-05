--!strict
-- Services
local AssetService = game:GetService("AssetService")

-- Packages
local Maid = require("@wally/Maid")
local Iris = require("@wally/Iris")
-- Modules
-- Types

-- Constants
local IMAGE_TEXTURE = "rbxassetid://136097158177934"
-- Variables
-- References
-- Class
return function(frame: Frame)
	local maid = Maid.new()
	local isAlive = true
	task.spawn(function()
		local Util = require(".")

		local imageLabel = maid:GiveTask(Instance.new("ImageLabel"))
		imageLabel.Position = UDim2.fromScale(0.5, 0.5)
		imageLabel.AnchorPoint = Vector2.new(0.5, 0.5)

		local source = maid:GiveTask(AssetService:CreateEditableImageAsync(Content.fromUri(IMAGE_TEXTURE)))
		-- for x = 0, source.Size.X-1 do
		-- 	source:DrawRectangle(Vector2.new(x,0), Vector2.new(1, source.Size.Y-1), Color3.fromHSV(x/source.Size.X, 1, 1), 0, Enum.ImageCombineType.Overwrite)
		-- end

		local canvas = maid:GiveTask(Util.clone(source))
		imageLabel.Size = UDim2.fromOffset(canvas.Size.X, canvas.Size.Y)
		imageLabel.ImageContent = Content.fromObject(canvas)
		imageLabel.Parent = frame

		Iris.Init(game:GetService("CoreGui"))

		maid:GiveTask(Iris:Connect(function()
			if not isAlive then
				return
			end
			-- use a unique window size, rather than default
			local windowSize = Iris.State(Vector2.new(350, 550))

			Iris.Window({ "Retexture" }, { size = windowSize })
			do
				local isRedrawNeeded = false

				local colorState = Iris.State(Color3.new(1, 1, 1))
				if colorState:changed() then
					isRedrawNeeded = true
				end
				local channelShift = Iris.State(0)
				if channelShift:changed() then
					isRedrawNeeded = true
				end
				local brightnessState = Iris.State(1)
				if brightnessState:changed() then
					isRedrawNeeded = true
				end
				local saturationState = Iris.State(1)
				if saturationState:changed() then
					isRedrawNeeded = true
				end
				local hueState = Iris.State(0)
				if hueState:changed() then
					isRedrawNeeded = true
				end
				local isRedChannelEnabled = Iris.State(true)
				if isRedChannelEnabled:changed() then
					isRedrawNeeded = true
				end
				local isBlueChannelEnabled = Iris.State(true)
				if isBlueChannelEnabled:changed() then
					isRedrawNeeded = true
				end
				local isGreenChannelEnabled = Iris.State(true)
				if isGreenChannelEnabled:changed() then
					isRedrawNeeded = true
				end
				local isAlphaChannelVisible = Iris.State(false)
				if isAlphaChannelVisible:changed() then
					isRedrawNeeded = true
				end
				local monoState = Iris.State("None" :: "None" | "R" | "G" | "B")
				if monoState:changed() then
					isRedrawNeeded = true
				end
				Iris.Tree({
					[Iris.Args.Tree.Text] = "Colors",
				}, { isUncollapsed = Iris.State(true) })
				do
					if Iris.Button({ "Reset" }).clicked() then
						print("reset")
						colorState:set(Color3.new(1, 1, 1), true)
						brightnessState:set(1)
						isRedChannelEnabled:set(true)
						isGreenChannelEnabled:set(true)
						isBlueChannelEnabled:set(true)
					end
					Iris.InputNum({
						[Iris.Args.InputNum.Text] = "Brightness" :: any,
						[Iris.Args.InputNum.Min] = 0,
						[Iris.Args.InputNum.Max] = 1,
						[Iris.Args.InputNum.Increment] = 0.1,
					}, { number = brightnessState })
					Iris.InputNum({
						[Iris.Args.InputNum.Text] = "Saturation" :: any,
						[Iris.Args.InputNum.Min] = 0,
						[Iris.Args.InputNum.Max] = 1,
						[Iris.Args.InputNum.Increment] = 0.1,
					}, { number = saturationState })
					-- Iris.InputNum({
					-- 	[Iris.Args.InputNum.Text] = "Hue",
					-- 	[Iris.Args.InputNum.Min] = 0,
					-- 	[Iris.Args.InputNum.Max] = 1,
					-- 	[Iris.Args.InputNum.Increment] = 0.1,
					-- }, { number = hueState })
					Iris.InputNum({
						[Iris.Args.InputNum.Text] = "Channel Shift" :: any,
						[Iris.Args.InputNum.Min] = 0,
						[Iris.Args.InputNum.Max] = 2,
						[Iris.Args.InputNum.Increment] = 1,
					}, { number = channelShift })
					Iris.InputColor3({
						[Iris.Args.InputColor3.Text] = "Color",
					}, { color = colorState })
					do
						local h, s, v = colorState.value:ToHSV()
						Iris.Text({
							`H={math.round(h * 360)},S={math.round(s * 100)},V={math.round(v * 100)}`,
						})
					end
					do
						Iris.CollapsingHeader({
							[Iris.Args.CollapsingHeader.Text] = "Channels",
						}, { isUncollapsed = Iris.State(true) })
						do
							Iris.Checkbox({
								[Iris.Args.Checkbox.Text] = "Red",
							}, {
								isChecked = isRedChannelEnabled,
							})
							Iris.Checkbox({
								[Iris.Args.Checkbox.Text] = "Green",
							}, {
								isChecked = isGreenChannelEnabled,
							})
							Iris.Checkbox({
								[Iris.Args.Checkbox.Text] = "Blue",
							}, {
								isChecked = isBlueChannelEnabled,
							})
							Iris.Checkbox({
								[Iris.Args.Checkbox.Text] = "Alpha",
							}, {
								isChecked = isAlphaChannelVisible,
							})
						end
						Iris.End()
					end
					do
						print("monoState", monoState.value)
						Iris.CollapsingHeader({
							[Iris.Args.CollapsingHeader.Text] = "Monocolor",
						}, { isUncollapsed = Iris.State(true) })
						do
							Iris.RadioButton({
								[Iris.Args.RadioButton.Text] = "None",
								[Iris.Args.RadioButton.Index] = "None",
							}, {
								index = monoState,
							})
							Iris.RadioButton({
								[Iris.Args.RadioButton.Text] = "R",
								[Iris.Args.RadioButton.Index] = "R",
							}, {
								index = monoState,
							})
							Iris.RadioButton({
								[Iris.Args.RadioButton.Text] = "G",
								[Iris.Args.RadioButton.Index] = "G",
							}, {
								index = monoState,
							})
							Iris.RadioButton({
								[Iris.Args.RadioButton.Text] = "B",
								[Iris.Args.RadioButton.Index] = "B",
							}, {
								index = monoState,
							})
						end
						Iris.End()
					end
					if isRedrawNeeded then
						local start = tick()
						Util.replace(canvas, source)
						do
							Util.overwriteF(canvas, nil, nil, nil, 0)
							Util.shiftChannelRGB(canvas, channelShift.value)
							if not isAlphaChannelVisible.value then
								Util.overwriteF(canvas, nil, nil, nil, 1)
							end
						end
						do
							local monoValue = monoState.value
							if monoValue ~= "None" then
								Util.toMono(canvas, monoValue :: Util.Channel)
							end
						end
						do
							local saturation = saturationState.value
							if saturation ~= 1 then
								Util.applySaturation(canvas, saturation)
							end
						end

						Util.applyValue(canvas, brightnessState.value)
						Util.tint(canvas, colorState.value)
						if not isRedChannelEnabled.value then
							Util.clearChannel(canvas, "R")
						end
						if not isGreenChannelEnabled.value then
							Util.clearChannel(canvas, "G")
						end
						if not isBlueChannelEnabled.value then
							Util.clearChannel(canvas, "B")
						end
						if isAlphaChannelVisible.value then
							Util.clearChannel(canvas, "R")
							Util.clearChannel(canvas, "G")
							Util.clearChannel(canvas, "B")
							Util.shiftChannelRGBA(canvas, 1)
							Util.overwriteF(canvas, nil, nil, nil, 1)
						end
						print("duration", math.ceil(10000 * (tick() - start)) / 10, "ms")
					end
				end
				Iris.End()
			end
			Iris.End()
		end))
	end)
	return function()
		isAlive = false
		Iris.Shutdown()
		maid:Destroy()
	end
end
