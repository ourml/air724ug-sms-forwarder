require "fs"

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

    local result = io.writeFile(msgFilePath, msg, "a+b")

    return result
end

-- 读取本地短信
-- @boolean empty 是否读取操作后清空文件内容, true => 清空; false => 保留
-- @return msgQueue table类型的短信内容
function readMsg(empty)
    local msgQueue = {}

    local isFileExists = io.exists(msgFilePath)
    if not isFileExists then
        log.warn("utilFS.readMsg", "文件不存在:", msgFilePath)
        return nil
    end

    local msg = io.readFile(msgFilePath)
    if msg == nil or msg == "" then
        log.warn("utilFS.readMsg", "文件不存在或为空:", msgFilePath)
        return nil
    end

    local msgSplit = msg:split(msgSplitSign)
    for _, msgContent in ipairs(msgSplit) do
        if msg ~= "" then
            table.insert(msgQueue, msg)
        end
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
    io.writeFile(msgFilePath, "", "w+b")
end
