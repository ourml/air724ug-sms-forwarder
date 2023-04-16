require "config"
require "sms"
require "sim"

module(..., package.seeall)

-- 运营商数据
local operData = {
    ["46000"] = {"CM", "中国移动", {"10086", "103"}},
    ["46001"] = {"CU", "中国联通", {"10010", "2082"}},
    ["46002"] = {"CM", "中国移动", {"10086", "103"}},
    ["46007"] = {"CM", "中国移动", {"10086", "103"}},
    ["46011"] = {"CT", "中国电信", {"10001", "108"}},
    ["46015"] = {"CB", "中国广电"}
}

function queryTraffic()
    local mcc = sim.getMcc()
    local mnc = sim.getMnc();
    local oper = operData[mcc .. mnc]

    if oper and oper[3] then
        sms.send(oper[3][1], oper[3][2])
    else
        log.warn("utilMobile.queryTraffic", "查询流量代码未配置")
    end
end
