--[[
    CAT HUB |
    Bản quyền thuộc về ScirptTodday
]]

-- Biến cấu hình bảo mật
local KeyFileName = "CatHub_SavedKey.txt"
local CorrectKey = "ScriptTodday"

-- Hàm tải script từ máy chủ bảo mật
local function SecureLoad()
    -- Thay link dưới đây bằng link RAW GitHub hoặc Pastebin của bạn
    local Success, ScriptContent = pcall(game.HttpGet, game, "https://raw.githubusercontent.com/huy311716-wq/CatHub-Beta/refs/heads/main/Hub.Lua")
    
    if Success then
        local Exec, Error = loadstring(ScriptContent)
        if Exec then
            Exec()
        else
            warn("Lỗi thực thi: " .. Error)
        end
    else
        warn("Không thể kết nối máy chủ bảo mật!")
    end
end

-- Hệ thống xác thực Key
if isfile(KeyFileName) and readfile(KeyFileName) == CorrectKey then
    SecureLoad()
else
    local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
    local Win = Rayfield:CreateWindow({Name = "CAT HUB | SECURITY SYSTEM"})
    local Tab = Win:CreateTab("Xác thực", 4483362458)
    
    Tab:CreateInput({
        Name = "Nhập Key để tiếp tục",
        PlaceholderText = "Key...",
        Callback = function(t)
            if t == CorrectKey then
                writefile(KeyFileName, t)
                Rayfield:Destroy()
                SecureLoad()
            else
                Rayfield:Notify({Title = "Lỗi", Content = "Sai Key!", Duration = 3})
            end
        end
    })
end
