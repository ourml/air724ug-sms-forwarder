require "http"

module(..., package.seeall)

local function httpCbFunc(result, prompt, head, body)
    log.info("utilHttp.httpCbFunc", result, prompt)
    if result and head then
        sys.publish("MSG_SENDED", true)
        for k, v in ipairs(head) do
            log.info("utilHttp.httpCbFunc", k .. ": " .. v)
        end
    end
    if result and body then
        log.info("utilHttp.httpCbFunc", "bodyLen=" .. body:len())
    end

    if not result then
        log.error("utilHttp.fetch 请求失败:" .. prompt)
        sys.publish("MSG_SENDED", false)
    end
end

--- 对 http.request 的封装
-- @param timeout 超时时间(单位: 毫秒)
-- @param method 请求方法
-- @param url 请求地址
-- @param headers 请求头
-- @param body 请求体
function fetch(timeout, method, url, headers, body)
    timeout = timeout or 1000 * 25
    local opts = {
        timeout = timeout
    }

    log.debug("utilHttp.fetch", "开始请求")

    http.request(method, url, nil, headers, body, timeout, httpCbFunc)
end
