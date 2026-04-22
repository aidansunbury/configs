-- Reload config from terminal: hs -c "hs.reload()"

-- Modifier key configuration
-- Change this to use a different main modifier key: "option", "cmd", "ctrl", "shift"
local hyper = {"option"}

-- Load IPC module and auto-install CLI if missing (required for `hs` terminal command)
local ipc = require("hs.ipc")
if not ipc.cliStatus() then
    ipc.cliInstall()
end

-- Screenshot binding
hs.hotkey.bind({}, "f13", function()
    -- -c: force to clipboard
    -- -i: interactive (selection) mode
    hs.task.new("/usr/sbin/screencapture", nil, {"-c", "-i"}):start()
end)


-- Terminal (Hyper + Return)
hs.hotkey.bind(hyper, "Return", function()
    os.execute("open -n /Applications/Ghostty.app")
end)

-- Cmux (Hyper + Shift + Return)
hs.hotkey.bind({hyper[1], "shift"}, "Return", function()
    os.execute("open -n /Applications/cmux.app")
end)

-- Chrome Default Profile (personal)
hs.hotkey.bind(hyper, "g", function()
    os.execute("open -na 'Google Chrome' --args --profile-directory='Default' --new-window")
end)

-- Chrome Profile 1 (work)
hs.hotkey.bind({hyper[1], "shift"}, "g", function()
    os.execute("open -na 'Google Chrome' --args --profile-directory='Profile 1' --new-window")
end)

-- Zed Editor (Hyper + Z)
hs.hotkey.bind(hyper, "z", function()
    os.execute("open -n /Applications/Zed.app")
end)

-- VS Code (Hyper + C)
hs.hotkey.bind(hyper, "c", function()
    os.execute("open -n /Applications/Visual\\ Studio\\ Code.app")
end)

-- Slack (Hyper + S)
hs.hotkey.bind(hyper, "s", function()
    os.execute("open -n /Applications/Slack.app")
end)

-- Linear
hs.hotkey.bind(hyper, "l", function()
    os.execute("open -n /Applications/Linear.app")
end)

-- iMessage (Hyper + M)
hs.hotkey.bind(hyper, "m", function()
    os.execute("open -n /System/Applications/Messages.app")
end)

-- Notion (launch in Chrome)
-- --new-window launches it in a new window, otherwise will open it as a new tab
hs.hotkey.bind(hyper, "n", function()
    os.execute("open -na 'Google Chrome' --args --profile-directory='Profile 1' --new-window https://www.notion.so/")
end)