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
