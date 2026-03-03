-- Screenshot binding
hs.hotkey.bind({}, "f13", function()
    -- -c: force to clipboard
    -- -i: interactive (selection) mode
    hs.task.new("/usr/sbin/screencapture", nil, {"-c", "-i"}):start()
end)

-- Application Launch Bindings
-- Uncomment the bindings you want to use

-- Terminal (Cmd + Return)
hs.hotkey.bind({"cmd"}, "Return", function()
    os.execute("open -n /Applications/Ghostty.app")
end)

-- File Manager (Cmd + F)
-- hs.hotkey.bind({"cmd"}, "f", function()
--     os.execute("open -n /Applications/Finder.app")
-- end)

-- Chrome Default Profile (Cmd + G)
hs.hotkey.bind({"cmd"}, "g", function()
    os.execute("open -na 'Google Chrome' --args --profile-directory='Default' --new-window")
end)

-- Chrome Profile 4 (Cmd + Shift + G)
hs.hotkey.bind({"cmd", "shift"}, "g", function()
    os.execute("open -na 'Google Chrome' --args --profile-directory='Profile 4' --new-window")
end)

-- Music/Spotify (Cmd + M)
-- hs.hotkey.bind({"cmd"}, "m", function()
--     os.execute("open -n /Applications/Spotify.app")
-- end)

-- System Monitor (Cmd + T)
-- hs.hotkey.bind({"cmd"}, "t", function()
--     os.execute("open -n /Applications/Activity\\ Monitor.app")
-- end)

-- Obsidian (Cmd + O)
-- hs.hotkey.bind({"cmd"}, "o", function()
--     os.execute("open -n /Applications/Obsidian.app")
-- end)

-- Zed Editor (Cmd + Z)
-- hs.hotkey.bind({"cmd"}, "z", function()
--     os.execute("open -n /Applications/Zed.app")
-- end)

-- VS Code (Cmd + C)
-- hs.hotkey.bind({"cmd"}, "c", function()
--     os.execute("open -n /Applications/Visual\\ Studio\\ Code.app")
-- end)

-- OpenCode (Cmd + U)
-- hs.hotkey.bind({"cmd"}, "u", function()
--     os.execute("open -n /Applications/Terminal.app")
-- end)

-- GitHub Web App (Cmd + H)
-- hs.hotkey.bind({"cmd"}, "h", function()
--     os.execute("open 'https://github.com'")
-- end)

-- Graphite Web App (Cmd + R)
-- hs.hotkey.bind({"cmd"}, "r", function()
--     os.execute("open 'https://app.graphite.com/'")
-- end)

-- YouTube (Cmd + Y)
-- hs.hotkey.bind({"cmd"}, "y", function()
--     os.execute("open 'https://youtube.com/'")
-- end)

-- Slack (Cmd + S)
-- hs.hotkey.bind({"cmd"}, "s", function()
--     os.execute("open -n /Applications/Slack.app")
-- end)

-- Linear (Cmd + L)
-- hs.hotkey.bind({"cmd"}, "l", function()
--     os.execute("open 'https://linear.app'")
-- end)

-- Notion (Cmd + N)
-- hs.hotkey.bind({"cmd"}, "n", function()
--     os.execute("open 'https://notion.so'")
-- end)

local copyToastTimer = nil
local copyToastHideTimer = nil
local copyToastBackground = nil
local copyToastText = nil

local function copyLabel()
    local available = hs.pasteboard.typesAvailable() or {}

    if available.image then
        return "Image copied"
    end

    if available.URL then
        local urls = hs.pasteboard.readURL(nil, true)
        local firstUrl = nil

        if type(urls) == "table" then
            firstUrl = urls[1]
        else
            firstUrl = urls
        end

        if type(firstUrl) == "string" and string.sub(firstUrl, 1, 7) == "file://" then
            return "File copied"
        end
    end

    if available.string or available.styledText then
        return "Text copied"
    end

    return "Copied"
end

local function hideCopyToast()
    if copyToastHideTimer then
        copyToastHideTimer:stop()
        copyToastHideTimer = nil
    end

    if copyToastText then
        copyToastText:delete()
        copyToastText = nil
    end

    if copyToastBackground then
        copyToastBackground:delete()
        copyToastBackground = nil
    end
end

local function showCopyToast()
    hideCopyToast()

    local label = copyLabel()
    local screenFrame = hs.screen.mainScreen():frame()
    local textSize = 15
    local textFrame = hs.drawing.getTextDrawingSize(label, {
        font = ".AppleSystemUIFont",
        size = textSize,
    })
    local toastWidth = math.max(150, math.ceil(textFrame.w) + 40)
    local toastHeight = 42
    local marginRight = 20
    local marginTop = 10
    local backgroundFrame = {
        x = screenFrame.x + screenFrame.w - toastWidth - marginRight,
        y = screenFrame.y + marginTop,
        w = toastWidth,
        h = toastHeight,
    }

    local textDrawFrame = {
        x = backgroundFrame.x + (backgroundFrame.w - textFrame.w) / 2,
        y = backgroundFrame.y + (backgroundFrame.h - textFrame.h) / 2,
        w = textFrame.w,
        h = textFrame.h,
    }

    copyToastBackground = hs.drawing.rectangle(backgroundFrame)
        :setFill(true)
        :setFillColor({white = 0.1, alpha = 0.9})
        :setStroke(false)
        :setRoundedRectRadii(8, 8)
        :setLevel(hs.drawing.windowLevels.floating)

    copyToastText = hs.drawing.text(textDrawFrame, label)
        :setTextColor({white = 1, alpha = 1})
        :setTextFont(".AppleSystemUIFont")
        :setTextSize(textSize)
        :setLevel(hs.drawing.windowLevels.floating)

    copyToastBackground:show()
    copyToastText:show()

    copyToastHideTimer = hs.timer.doAfter(1.2, hideCopyToast)
end

local copyWatcher = hs.pasteboard.watcher.new(function()
    if copyToastTimer then
        copyToastTimer:stop()
    end

    copyToastTimer = hs.timer.doAfter(0.12, function()
        showCopyToast()
        copyToastTimer = nil
    end)
end)

copyWatcher:start()
