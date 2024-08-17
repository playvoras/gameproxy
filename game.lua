local fakegame = newproxy(true)
local fakegame_meta = getmetatable(fakegame)

fakegame_meta.__index = function(self, index)
    local success, game_index = pcall(function()
        return game[index]
    end)

    if index == "HttpGet" then
        return function(_, url)
            assert(type(url) == "string" and url:sub(1, 4) == "http", "arg #1 not a valid url.")
            local s, r
            http_service:RequestInternal({Url = url, Method = "GET"}):Start(function(a, b)
                s, r = a, b
            end)
            repeat task.wait() until s or r
            return r.Body
        end
    elseif index == "GetObjects" then
        return function(_, assetid)
            assert(type(assetid) == "string" and assetid:find("rbxassetid://"), "arg #1 not a valid asset id.")
            return {insert_service:LoadLocalAsset(assetid)}
        end
    elseif index == "LoadString" then
        return function(_, str)
            assert(type(str) == "string", "arg #1 must be a string.")
            return loadstring(str)()
        end
    elseif index == "WaitForChild" then
        return function(_, child_name, timeout)
            assert(type(child_name) == "string", "arg #1 must be a string.")
            return game:WaitForChild(child_name, timeout)
        end
    elseif index == "IsLoaded" then
        return function()
            return game:IsLoaded()
        end
    elseif index == "GetService" then
        return function(_, service_name)
            assert(type(service_name) == "string", "arg #1 must be a string.")
            return game:GetService(service_name)
        end
    elseif index == "FindFirstChild" then
        return function(_, child_name)
            assert(type(child_name) == "string", "arg #1 must be a string.")
            return game:FindFirstChild(child_name)
        end
    elseif index == "GetChildren" then
        return function()
            return game:GetChildren()
        end
    elseif index == "GetDescendants" then
        return function()
            return game:GetDescendants()
        end
    elseif index == "HttpPost" then
        return function(_, url, data)
            assert(type(url) == "string" and url:sub(1, 4) == "http", "arg #1 not a valid url.")
            assert(type(data) == "string", "arg #2 must be a string.")
            local s, r
            http_service:RequestInternal({Url = url, Method = "POST", Body = data}):Start(function(a, b)
                s, r = a, b
            end)
            repeat task.wait() until s or r
            return r.Body
        end
    elseif success and type(game_index) == "function" then
        return function(_, ...)
            return game_index(game, ...)
        end
    else
        return game_index or game[index]
    end
end

fakegame_meta.__metatable = "The metatable is locked"
