module(..., package.seeall)

-- 短信存储位置
local msgFilePath = "/msg.txt"
-- 短信分隔符
local msgSplitSign = "|"

-- 保存短信至本地文件
-- @string msg 短信内容
-- @return result 是否保存成功
function appendMsg(msg)
    msg = msg .. msgSplitSign

    log.info("utilFS.appendMsg", "content:", msg, "path:", msgFilePath)
    local fileHnadle = io.open(msgFilePath, "a+")

    if fileHnadle then
        fileHnadle:write(msg)
        fileHnadle:close()
        return true
    else
        return false
    end
end

-- 读取本地短信
-- @boolean empty 是否读取操作后清空文件内容, true => 清空; false => 保留
-- @return msgQueue table类型的短信内容
function readMsg(empty)
    local msgQueue = {}

    local fileHandle = io.open(msgFilePath, "r")
    if fileHandle then
        local msg = fileHandle:read("*all")
        if msg == nil or msg == "" then
            log.warn("utilFS.readMsg", "文件不存在或为空:", msgFilePath)
            fileHandle:close()
            return msgQueue
        end

        fileHandle:close()
        local msgSplit = msg:split(msgSplitSign)
        for _, msgContent in ipairs(msgSplit) do
            if msg ~= "" then
                table.insert(msgQueue, msg)
            end
        end
    else
        log.error("utilFS.readMsg", "读取文件出错")
        return msgQueue
    end

    -- 清空短信
    if empty then
        log.warn("utilFS.readMsg", "读取后清空本地短信")
        emptyMsg()
    end

    return msgQueue
end

-- 清空本地短信
function emptyMsg()
    log.warn("utilFS.emptyMsg", "清空本地短信")
    local fileHandle = io.open(msgFilePath, "w")

    if fileHandle then
        fileHandle:write()
        fileHandle:close()
        log.info("utilFS.emptyMsg", "本地短信已清空")
    else
        log.error("utilFS.emptyMsg", "本地短信清空失败")
    end
end

-- 初始化本地短信文件
function initFile()
    local fileHandle = io.open(msgFilePath, "a+")

    if fileHandle then
        fileHandle:write()
        fileHandle:close()
        log.info("utilFS.initFile", "初始化本地短信文件成功")
    else
        log.error("utilFS.initFile", "初始化本地文件失败")
    end
end