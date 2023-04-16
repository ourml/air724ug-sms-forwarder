require "utilHttp"
local config = require "config"

module(..., package.seeall)

local msgQueue = {}

local function urlencodeTab(params)
    local msg = {}
    for k, v in pairs(params) do
        table.insert(msg, string.urlEncode(tostring(k)) .. "=" .. string.urlEncode(tostring(v)))
        table.insert(msg, "&")
    end
    table.remove(msg)
    return table.concat(msg)
end

local notify = {
    -- 发送到 bark
    ["bark"] = function(msg, group)
        if config.BARK_API == nil or config.BARK_API == "" then
            log.error("utilNotify", "未配置 `config.BARK_API`")
            return
        end
        if config.BARK_KEY == nil or config.BARK_KEY == "" then
            log.error("utilNotify", "未配置 `config.BARK_KEY`")
            return
        end

        local header = {
            ["Content-Type"] = "application/x-www-form-urlencoded"
        }
        local body = {
            body = msg
        }
        local url = ""

        if group ~= nil then
            url = config.BARK_API .. "/" .. config.BARK_KEY .. "?group=" .. group
        else
            url = config.BARK_API .. "/" .. config.BARK_KEY
        end

        log.info("utilNotify", "POST", url)
        utilHttp.fetch(nil, "POST", url, header, urlencodeTab(body))
    end,
    -- 发送到 next-smtp-proxy
    ["next-smtp-proxy"] = function(msg, group)
        if config.NEXT_SMTP_PROXY_API == nil or config.NEXT_SMTP_PROXY_API == "" then
            log.error("utilNotify", "未配置 `config.NEXT_SMTP_PROXY_API`")
            return
        end
        if config.NEXT_SMTP_PROXY_USER == nil or config.NEXT_SMTP_PROXY_USER == "" then
            log.error("utilNotify", "未配置 `config.NEXT_SMTP_PROXY_USER`")
            return
        end
        if config.NEXT_SMTP_PROXY_PASSWORD == nil or config.NEXT_SMTP_PROXY_PASSWORD == "" then
            log.error("utilNotify", "未配置 `config.NEXT_SMTP_PROXY_PASSWORD`")
            return
        end
        if config.NEXT_SMTP_PROXY_HOST == nil or config.NEXT_SMTP_PROXY_HOST == "" then
            log.error("utilNotify", "未配置 `config.NEXT_SMTP_PROXY_HOST`")
            return
        end
        if config.NEXT_SMTP_PROXY_PORT == nil or config.NEXT_SMTP_PROXY_PORT == "" then
            log.error("utilNotify", "未配置 `config.NEXT_SMTP_PROXY_PORT`")
            return
        end
        if config.NEXT_SMTP_PROXY_TO_EMAIL == nil or config.NEXT_SMTP_PROXY_TO_EMAIL == "" then
            log.error("utilNotify", "未配置 `config.NEXT_SMTP_PROXY_TO_EMAIL`")
            return
        end

        local header = {
            ["Content-Type"] = "application/x-www-form-urlencoded"
        }
        local body = {
            user = config.NEXT_SMTP_PROXY_USER,
            password = config.NEXT_SMTP_PROXY_PASSWORD,
            host = config.NEXT_SMTP_PROXY_HOST,
            port = config.NEXT_SMTP_PROXY_PORT,
            form_name = config.NEXT_SMTP_PROXY_FORM_NAME,
            to_email = config.NEXT_SMTP_PROXY_TO_EMAIL,
            subject = group or config.NEXT_SMTP_PROXY_SUBJECT,
            text = msg
        }

        log.info("utilNotify", "POST", config.NEXT_SMTP_PROXY_API)
        utilHttp.fetch(nil, "POST", config.NEXT_SMTP_PROXY_API, header, urlencodeTab(body))
    end
}

--- 发送通知
-- @param msg 消息内容
-- @param channel 通知渠道
function send(msg, channel, group)
    log.info("utilNotify.send", "发送通知", channel)

    -- 判断消息内容 msg
    if type(msg) ~= "string" then
        log.error("utilNotify.send", "发送通知失败", "参数类型错误", type(msg))
        return
    end
    if msg == "" then
        log.error("utilNotify.send", "发送通知失败", "消息为空")
        return
    end

    -- 判断通知渠道 channel
    if channel and notify[channel] == nil then
        log.error("utilNotify.send", "发送通知失败", "未知通知渠道", channel)
        return
    end

    -- 发送通知
    notify[channel](msg, group)
end

--- 添加到消息队列
-- @param msg 消息内容
-- @param channels 通知渠道
function add(msg, channels, groupName)
    if type(msg) == "table" then
        msg = table.concat(msg, "\n")
    end

    channels = channels or config.NOTIFY_TYPE

    if type(channels) ~= "table" then
        channels = {channels}
    end

    for _, channel in ipairs(channels) do
        table.insert(msgQueue, {
            channel = channel,
            msg = msg,
            group = groupName
        })
    end
    sys.publish("NEW_MSG")

    log.debug("utilNotify.add", "添加到消息队列, 当前队列长度:", #msgQueue)
end

-- 轮询消息队列
local function poll()
    local item, result
    while true do
        -- 消息队列非空, 且网络已注册
        if next(msgQueue) ~= nil and socket.isReady() then
            log.debug("utilNotify.poll", "轮询消息队列中, 当前队列长度:", #msgQueue)

            item = msgQueue[1]
            table.remove(msgQueue, 1)

            utilNotify.send(item.msg, item.channel, item.group)

            sys.wait(50)
        else
            sys.waitUntil("NEW_MSG", 1000 * 10)
        end
    end
end

sys.taskInit(poll)
