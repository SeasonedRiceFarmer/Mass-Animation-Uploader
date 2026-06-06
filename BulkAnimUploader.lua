--[[
	MassAnimationUploader
	Author:  SeasonedRiceFarmer (on Roblox, Discord, and Github)
    GitHub:  https://github.com/SeasonedRiceFarmer

    Select KeyframeSequences in Explorer, pick an upload destination
    (personal or group), pick an output folder, confirm, and upload.
    Source KeyframeSequences are never modified or destroyed.
    Each successful upload creates an Animation object in the output folder.
--]]

local AssetService = game:GetService("AssetService")
local Selection    = game:GetService("Selection")
local GroupService = game:GetService("GroupService")

-- ── Plugin boilerplate ────────────────────────────────────────────────────────

local toolbar   = plugin:CreateToolbar("Mass Animation Uploader")
local toggleBtn = toolbar:CreateButton(
	"Mass Animation Uploader",
	"Mass upload selected KeyframeSequences",
	"rbxassetid://81635857323026"
)

local widgetInfo = DockWidgetPluginGuiInfo.new(
	Enum.InitialDockState.Float,
	true,
	false,
	300,
	540,
	260,
	420
)

local widget = plugin:CreateDockWidgetPluginGuiAsync("Mass Animation Uploader", widgetInfo)
widget.Title = "Mass Animation Uploader"

toggleBtn.Click:Connect(function()
	widget.Enabled = not widget.Enabled
end)

-- ── Colours ───────────────────────────────────────────────────────────────────

local C = {
	bg         = Color3.fromRGB(37,  37,  37),
	surface    = Color3.fromRGB(46,  46,  46),
	surfaceHov = Color3.fromRGB(55,  55,  55),
	border     = Color3.fromRGB(60,  60,  60),
	accent     = Color3.fromRGB(0,   162, 255),
	accentHov  = Color3.fromRGB(51,  181, 255),
	confirm    = Color3.fromRGB(60,  180, 90),
	confirmHov = Color3.fromRGB(80,  210, 110),
	danger     = Color3.fromRGB(220, 70,  70),
	text       = Color3.fromRGB(235, 235, 235),
	muted      = Color3.fromRGB(140, 140, 140),
	success    = Color3.fromRGB(80,  200, 120),
	warning    = Color3.fromRGB(240, 180, 60),
}

-- ── Helpers ───────────────────────────────────────────────────────────────────

local function make(class, props, parent)
	local obj = Instance.new(class)
	for k, v in pairs(props) do obj[k] = v end
	if parent then obj.Parent = parent end
	return obj
end

local function label(text, size, color, parent)
	return make("TextLabel", {
		Text                   = text,
		TextSize               = size,
		TextColor3             = color,
		Font                   = Enum.Font.GothamMedium,
		BackgroundTransparency = 1,
		TextXAlignment         = Enum.TextXAlignment.Left,
		AutomaticSize          = Enum.AutomaticSize.XY,
	}, parent)
end

local function divider(order, parent)
	make("Frame", {
		Size             = UDim2.new(1, 0, 0, 1),
		BackgroundColor3 = C.border,
		BorderSizePixel  = 0,
		LayoutOrder      = order,
	}, parent)
end

-- ── Root ──────────────────────────────────────────────────────────────────────

local root = make("Frame", {
	Size             = UDim2.fromScale(1, 1),
	BackgroundColor3 = C.bg,
	BorderSizePixel  = 0,
}, widget)

make("UIPadding", {
	PaddingTop    = UDim.new(0, 16),
	PaddingBottom = UDim.new(0, 16),
	PaddingLeft   = UDim.new(0, 14),
	PaddingRight  = UDim.new(0, 14),
}, root)

make("UIListLayout", {
	FillDirection = Enum.FillDirection.Vertical,
	SortOrder     = Enum.SortOrder.LayoutOrder,
	Padding       = UDim.new(0, 10),
}, root)

-- ── Title ─────────────────────────────────────────────────────────────────────

local titleRow = make("Frame", {
	BackgroundTransparency = 1,
	AutomaticSize          = Enum.AutomaticSize.Y,
	Size                   = UDim2.fromScale(1, 0),
	LayoutOrder            = 0,
}, root)

make("UIListLayout", {
	FillDirection = Enum.FillDirection.Vertical,
	SortOrder     = Enum.SortOrder.LayoutOrder,
	Padding       = UDim.new(0, 2),
}, titleRow)

local titleLbl = label("Mass Animation Uploader", 16, C.text, titleRow)
titleLbl.Font = Enum.Font.GothamBold
label("Upload selected KeyframeSequences", 11, C.muted, titleRow)

-- ── Selection count ───────────────────────────────────────────────────────────

divider(1, root)

local selFrame = make("Frame", {
	BackgroundTransparency = 1,
	AutomaticSize          = Enum.AutomaticSize.Y,
	Size                   = UDim2.fromScale(1, 0),
	LayoutOrder            = 2,
}, root)

local selLbl = label("No KeyframeSequences selected", 12, C.muted, selFrame)

-- ── Upload destination (Personal / Group) ─────────────────────────────────────

divider(3, root)

local destHeader = label("UPLOAD DESTINATION", 10, C.muted, root)
destHeader.LayoutOrder = 4

local radioFrame = make("Frame", {
	BackgroundTransparency = 1,
	AutomaticSize          = Enum.AutomaticSize.Y,
	Size                   = UDim2.fromScale(1, 0),
	LayoutOrder            = 5,
}, root)

make("UIListLayout", {
	FillDirection = Enum.FillDirection.Vertical,
	SortOrder     = Enum.SortOrder.LayoutOrder,
	Padding       = UDim.new(0, 6),
}, radioFrame)

local function radioBtn(text, order, parent)
	local row = make("Frame", {
		BackgroundTransparency = 1,
		Size                   = UDim2.new(1, 0, 0, 20),
		LayoutOrder            = order,
	}, parent)

	local dot = make("Frame", {
		Size             = UDim2.fromOffset(14, 14),
		Position         = UDim2.fromOffset(0, 3),
		BackgroundColor3 = C.surface,
		BorderColor3     = C.border,
		BorderSizePixel  = 1,
	}, row)
	make("UICorner", { CornerRadius = UDim.new(1, 0) }, dot)

	local inner = make("Frame", {
		Size             = UDim2.fromOffset(8, 8),
		Position         = UDim2.fromOffset(3, 3),
		BackgroundColor3 = C.accent,
		Visible          = false,
		BorderSizePixel  = 0,
	}, dot)
	make("UICorner", { CornerRadius = UDim.new(1, 0) }, inner)

	local lbl = label(text, 12, C.text, row)
	lbl.Position = UDim2.fromOffset(20, 2)

	local btn = make("TextButton", {
		Size                   = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Text                   = "",
		ZIndex                 = 2,
	}, row)

	return inner, btn
end

local personalInner, personalBtn = radioBtn("Personal account", 1, radioFrame)
local groupInner,    groupBtn    = radioBtn("Group",            2, radioFrame)

local groupInputFrame = make("Frame", {
	BackgroundTransparency = 1,
	Size                   = UDim2.new(1, 0, 0, 30),
	LayoutOrder            = 6,
	Visible                = false,
}, root)

local groupInput = make("TextBox", {
	Size              = UDim2.new(1, 0, 1, 0),
	BackgroundColor3  = C.surface,
	BorderColor3      = C.border,
	BorderSizePixel   = 1,
	Text              = "",
	PlaceholderText   = "Group ID  (numbers only)",
	PlaceholderColor3 = C.muted,
	TextColor3        = C.text,
	TextSize          = 12,
	Font              = Enum.Font.Gotham,
	ClearTextOnFocus  = false,
}, groupInputFrame)
make("UIPadding", { PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8) }, groupInput)

local useGroup = false

local function setDestination(toGroup)
	useGroup = toGroup
	personalInner.Visible   = not toGroup
	groupInner.Visible      = toGroup
	groupInputFrame.Visible = toGroup
end

setDestination(false)
personalBtn.MouseButton1Click:Connect(function() setDestination(false) end)
groupBtn.MouseButton1Click:Connect(function()    setDestination(true)  end)

-- ── Output folder picker ──────────────────────────────────────────────────────

divider(7, root)

local folderHeader = label("OUTPUT FOLDER", 10, C.muted, root)
folderHeader.LayoutOrder = 8

local folderRow = make("Frame", {
	BackgroundTransparency = 1,
	Size                   = UDim2.new(1, 0, 0, 28),
	LayoutOrder            = 9,
}, root)

make("UIListLayout", {
	FillDirection = Enum.FillDirection.Horizontal,
	SortOrder     = Enum.SortOrder.LayoutOrder,
	Padding       = UDim.new(0, 6),
	VerticalAlignment = Enum.VerticalAlignment.Center,
}, folderRow)

local folderLbl = make("TextLabel", {
	Size                   = UDim2.new(1, -80, 1, 0),
	BackgroundColor3       = C.surface,
	BorderColor3           = C.border,
	BorderSizePixel        = 1,
	Text                   = "None selected",
	TextColor3             = C.muted,
	TextSize               = 11,
	Font                   = Enum.Font.Gotham,
	TextXAlignment         = Enum.TextXAlignment.Left,
	TextTruncate           = Enum.TextTruncate.AtEnd,
	LayoutOrder            = 1,
}, folderRow)
make("UIPadding", { PaddingLeft = UDim.new(0, 6) }, folderLbl)

local pickBtn = make("TextButton", {
	Size             = UDim2.new(0, 72, 1, 0),
	BackgroundColor3 = C.surface,
	BorderColor3     = C.border,
	BorderSizePixel  = 1,
	Text             = "Pick",
	TextColor3       = C.text,
	TextSize         = 12,
	Font             = Enum.Font.GothamMedium,
	AutoButtonColor  = false,
	LayoutOrder      = 2,
}, folderRow)
make("UICorner", { CornerRadius = UDim.new(0, 4) }, pickBtn)

local outputFolder = nil  -- Instance ref, set by picker

pickBtn.MouseButton1Click:Connect(function()
	local sel = Selection:Get()
	if #sel == 1 and (sel[1]:IsA("Folder") or sel[1]:IsA("Model")) then
		outputFolder        = sel[1]
		folderLbl.Text      = sel[1]:GetFullName()
		folderLbl.TextColor3 = C.text
	else
		folderLbl.Text      = "Select exactly one Folder or Model first"
		folderLbl.TextColor3 = C.warning
		outputFolder        = nil
	end
end)

pickBtn.MouseEnter:Connect(function() pickBtn.BackgroundColor3 = C.surfaceHov end)
pickBtn.MouseLeave:Connect(function() pickBtn.BackgroundColor3 = C.surface    end)

-- ── Confirmation banner (hidden until upload is requested) ────────────────────

divider(10, root)

local confirmFrame = make("Frame", {
	BackgroundTransparency = 1,
	AutomaticSize          = Enum.AutomaticSize.Y,
	Size                   = UDim2.fromScale(1, 0),
	LayoutOrder            = 11,
	Visible                = false,
}, root)

make("UIListLayout", {
	FillDirection = Enum.FillDirection.Vertical,
	SortOrder     = Enum.SortOrder.LayoutOrder,
	Padding       = UDim.new(0, 6),
}, confirmFrame)

local confirmLbl = make("TextLabel", {
	Size                   = UDim2.new(1, 0, 0, 0),
	AutomaticSize          = Enum.AutomaticSize.Y,
	BackgroundTransparency = 1,
	Text                   = "",
	TextColor3             = C.warning,
	TextSize               = 11,
	Font                   = Enum.Font.Gotham,
	TextXAlignment         = Enum.TextXAlignment.Left,
	TextWrapped            = true,
	LayoutOrder            = 1,
}, confirmFrame)

local confirmBtnRow = make("Frame", {
	BackgroundTransparency = 1,
	Size                   = UDim2.new(1, 0, 0, 30),
	LayoutOrder            = 2,
}, confirmFrame)

make("UIListLayout", {
	FillDirection     = Enum.FillDirection.Horizontal,
	SortOrder         = Enum.SortOrder.LayoutOrder,
	Padding           = UDim.new(0, 8),
	VerticalAlignment = Enum.VerticalAlignment.Center,
}, confirmBtnRow)

local confirmYesBtn = make("TextButton", {
	Size             = UDim2.new(0.5, -4, 1, 0),
	BackgroundColor3 = C.confirm,
	BorderSizePixel  = 0,
	Text             = "Yes, upload",
	TextColor3       = Color3.fromRGB(255, 255, 255),
	TextSize         = 12,
	Font             = Enum.Font.GothamBold,
	AutoButtonColor  = false,
	LayoutOrder      = 1,
}, confirmBtnRow)
make("UICorner", { CornerRadius = UDim.new(0, 6) }, confirmYesBtn)

local confirmNoBtn = make("TextButton", {
	Size             = UDim2.new(0.5, -4, 1, 0),
	BackgroundColor3 = C.surface,
	BorderColor3     = C.border,
	BorderSizePixel  = 1,
	Text             = "Cancel",
	TextColor3       = C.text,
	TextSize         = 12,
	Font             = Enum.Font.GothamMedium,
	AutoButtonColor  = false,
	LayoutOrder      = 2,
}, confirmBtnRow)
make("UICorner", { CornerRadius = UDim.new(0, 6) }, confirmNoBtn)

confirmYesBtn.MouseEnter:Connect(function() confirmYesBtn.BackgroundColor3 = C.confirmHov end)
confirmYesBtn.MouseLeave:Connect(function() confirmYesBtn.BackgroundColor3 = C.confirm    end)
confirmNoBtn.MouseEnter:Connect(function()  confirmNoBtn.BackgroundColor3  = C.surfaceHov end)
confirmNoBtn.MouseLeave:Connect(function()  confirmNoBtn.BackgroundColor3  = C.surface    end)

-- ── Upload button ─────────────────────────────────────────────────────────────

local uploadBtn = make("TextButton", {
	Size             = UDim2.new(1, 0, 0, 36),
	BackgroundColor3 = C.accent,
	BorderSizePixel  = 0,
	Text             = "Upload Selected",
	TextColor3       = Color3.fromRGB(255, 255, 255),
	TextSize         = 13,
	Font             = Enum.Font.GothamBold,
	AutoButtonColor  = false,
	LayoutOrder      = 12,
}, root)
make("UICorner", { CornerRadius = UDim.new(0, 6) }, uploadBtn)

uploadBtn.MouseEnter:Connect(function() uploadBtn.BackgroundColor3 = C.accentHov end)
uploadBtn.MouseLeave:Connect(function() uploadBtn.BackgroundColor3 = C.accent    end)

-- ── Log box ───────────────────────────────────────────────────────────────────

local logFrame = make("ScrollingFrame", {
	Size                 = UDim2.new(1, 0, 0, 130),
	BackgroundColor3     = C.surface,
	BorderColor3         = C.border,
	BorderSizePixel      = 1,
	CanvasSize           = UDim2.fromScale(0, 0),
	AutomaticCanvasSize  = Enum.AutomaticSize.Y,
	ScrollBarThickness   = 4,
	ScrollBarImageColor3 = C.border,
	LayoutOrder          = 13,
}, root)

make("UIPadding", {
	PaddingTop    = UDim.new(0, 6),
	PaddingBottom = UDim.new(0, 6),
	PaddingLeft   = UDim.new(0, 8),
	PaddingRight  = UDim.new(0, 8),
}, logFrame)

make("UIListLayout", {
	FillDirection = Enum.FillDirection.Vertical,
	SortOrder     = Enum.SortOrder.LayoutOrder,
	Padding       = UDim.new(0, 2),
}, logFrame)

local logCount = 0

local function log(text, color)
	logCount += 1
	-- TextBox with TextEditable=false so text is selectable/copyable
	local entry = make("TextBox", {
		Text                   = text,
		TextSize               = 11,
		Font                   = Enum.Font.Code,
		TextColor3             = color or C.text,
		BackgroundTransparency = 1,
		TextXAlignment         = Enum.TextXAlignment.Left,
		TextWrapped            = true,
		AutomaticSize          = Enum.AutomaticSize.Y,
		Size                   = UDim2.new(1, 0, 0, 0),
		LayoutOrder            = logCount,
		TextEditable           = false,
		ClearTextOnFocus       = false,
		BorderSizePixel        = 0,
	}, logFrame)
	task.defer(function()
		logFrame.CanvasPosition = Vector2.new(0, logFrame.AbsoluteCanvasSize.Y)
	end)
	return entry
end

local function clearLog()
	for _, child in ipairs(logFrame:GetChildren()) do
		if child:IsA("TextBox") then child:Destroy() end
	end
	logCount = 0
end

-- ── Selection watcher ─────────────────────────────────────────────────────────

local function getTargets()
	local t = {}
	for _, obj in ipairs(Selection:Get()) do
		if obj:IsA("KeyframeSequence") then
			table.insert(t, obj)
		end
	end
	return t
end

local function updateSelLabel()
	local n = #getTargets()
	if n == 0 then
		selLbl.Text       = "No KeyframeSequences selected"
		selLbl.TextColor3 = C.muted
	elseif n == 1 then
		selLbl.Text       = "1 KeyframeSequence selected"
		selLbl.TextColor3 = C.text
	else
		selLbl.Text       = n .. " KeyframeSequences selected"
		selLbl.TextColor3 = C.text
	end
end

Selection.SelectionChanged:Connect(updateSelLabel)
updateSelLabel()

-- ── State machine: idle → confirming → uploading ──────────────────────────────

local state = "idle"  -- "idle" | "confirming" | "uploading"

local pendingTargets = nil
local pendingGroupId = nil

local function setState(s)
	state = s
	confirmFrame.Visible = (s == "confirming")
	uploadBtn.Visible    = (s ~= "confirming")
	if s == "uploading" then
		uploadBtn.Text             = "Uploading…"
		uploadBtn.BackgroundColor3 = C.border
	else
		uploadBtn.Text             = "Upload Selected"
		uploadBtn.BackgroundColor3 = C.accent
	end
end

setState("idle")

-- ── Upload logic ──────────────────────────────────────────────────────────────

local function runUpload(targets, groupId)
	setState("uploading")
	clearLog()
	log(string.format("Uploading %d animation(s)…", #targets), C.muted)

	-- Ensure output folder exists
	local folder = outputFolder
	if not folder then
		folder = Instance.new("Folder")
		folder.Name   = "UploadedAnimations"
		folder.Parent = game:GetService("ServerStorage")
		log("No folder selected — created ServerStorage/UploadedAnimations", C.warning)
	end

	local succeeded, failed = 0, 0

	for _, seq in ipairs(targets) do
		local seqName = seq.Name

		local params = {
			Name        = seqName,
			Description = "Uploaded via MassAnimationUploader",
			CreatorType = groupId and Enum.AssetCreatorType.Group or Enum.AssetCreatorType.User,
		}
		if groupId then
			params.CreatorId = groupId
		end

		local ok, createResult, assetId = pcall(function()
			return AssetService:CreateAssetAsync(seq, Enum.AssetType.Animation, params)
		end)

		if ok and createResult == Enum.CreateAssetResult.Success then
			local anim = Instance.new("Animation")
			anim.Name        = seqName
			anim.AnimationId = "rbxassetid://" .. tostring(assetId)
			anim.Parent      = folder

			log(string.format("✔  %s  →  rbxassetid://%d", seqName, assetId), C.success)
			succeeded += 1
		else
			local errMsg = tostring(createResult)
			log(string.format("✖  %s  —  %s", seqName, errMsg), C.danger)
			failed += 1
		end

		task.wait(0.1)
	end

	log("────────────────────────────", C.border)
	if failed == 0 then
		log(string.format("Done. %d uploaded.", succeeded), C.success)
	else
		log(string.format("Done. %d uploaded, %d failed.", succeeded, failed), C.warning)
	end

	setState("idle")
	updateSelLabel()
end

-- ── Button wiring ─────────────────────────────────────────────────────────────

uploadBtn.MouseButton1Click:Connect(function()
	if state ~= "idle" then return end

	local groupId = nil
	if useGroup then
		groupId = tonumber(groupInput.Text)
		if not groupId then
			clearLog()
			log("✖  Enter a valid numeric Group ID.", C.danger)
			return
		end
		local ok, info = pcall(function()
			return GroupService:GetGroupInfoAsync(groupId)
		end)
		if not ok then
			clearLog()
			log("✖  Group does not exist or could not be reached.", C.danger)
			return
		end
		log("Uploading to: " .. info.Name, C.muted)
	end

	local targets = getTargets()
	if #targets == 0 then
		clearLog()
		log("✖  Select at least one KeyframeSequence first.", C.danger)
		return
	end

	local dest = useGroup and ("group " .. tostring(groupId)) or "your personal account"
	local folderName = outputFolder and outputFolder:GetFullName() or "ServerStorage/UploadedAnimations (auto)"
	confirmLbl.Text = string.format(
		"Upload %d animation(s) to %s?\nOutput folder: %s",
		#targets, dest, folderName
	)

	pendingTargets = targets
	pendingGroupId = groupId
	setState("confirming")
end)

confirmYesBtn.MouseButton1Click:Connect(function()
	if state ~= "confirming" then return end
	local targets = pendingTargets
	local groupId = pendingGroupId
	pendingTargets = nil
	pendingGroupId = nil
	task.spawn(runUpload, targets, groupId)
end)

confirmNoBtn.MouseButton1Click:Connect(function()
	if state ~= "confirming" then return end
	pendingTargets = nil
	pendingGroupId = nil
	setState("idle")
end)
