-- 必须在这个位置定义PROJECT和VERSION变量
PROJECT = "sms_forwarder"
VERSION = "1.1.0"

-- 加载日志功能模块，并且设置日志输出等级
-- 如果关闭调用log模块接口输出的日志，等级设置为log.LOG_SILENT即可
require "log"
LOG_LEVEL = log.LOGLEVEL_DEBUG

require "sys"
require "net"

-- 设置dns
ril.request("AT+CDNSCFG=119.29.29.29,223.5.5.5")

-- 开启IPV6
-- 将模块第五路承载去激活
ril.request("AT+CGACT=0,5")
-- 设置第五路承载开启IPV6，由于我这里使用的是移动卡所以我设置APN为cmnet
ril.request("AT+CGDCONT=5,IPV4V6,cmnet")
-- 激活第五路承载
ril.request("AT+CGACT=1,5")

-- 每1分钟查询一次GSM信号强度
-- 每1分钟查询一次基站信息
net.startQueryAll(60000, 60000)

-- 此处关闭RNDIS网卡功能
ril.request("AT+RNDISCALL=0,1")

-- 加载网络指示灯和LTE指示灯功能模块
-- 根据自己的项目需求和硬件配置决定：1、是否加载此功能模块；2、配置指示灯引脚
-- 合宙官方出售的Air720U开发板上的网络指示灯引脚为pio.P0_1，LTE指示灯引脚为pio.P0_4
require "netLed"
pmd.ldoset(2, pmd.LDO_VLCD)
netLed.setup(true, pio.P0_1, pio.P0_4)
-- 网络指示灯功能模块中，默认配置了各种工作状态下指示灯的闪烁规律，参考netLed.lua中ledBlinkTime配置的默认值
-- 如果默认值满足不了需求，此处调用netLed.updateBlinkTime去配置闪烁时长
-- LTE指示灯功能模块中，配置的是注册上4G网络，灯就常亮，其余任何状态灯都会熄灭

require "sms"
require "utilHttp"
require "utilNotify"
require "utilMobile"
require "utilCall"
require "utilFS"
local config = require "config"

-- 错误日志上报
require "errDump"
if config.ERROR_DUMP_HOST ~= nil and config.ERROR_DUMP_HOST ~= "" then
    errDump.setNetworkLog(true)
    errDump.request(config.ERROR_DUMP_HOST, nil, true)
end

-- 判断是否是短信控制指令
-- @string smsText 短信内容
-- @string toNumber 要发送短信的号码
-- @return isSmsCtrl
local function smsCtrl(smsText, toNumber)
    local isSmsCtrl = false

    if smsText ~= "" and toNumber ~= "" and #smsText >= 5 and #toNumber <= 20 and smsText ~= config.SMS_CTRL_REBOOT_KEY then
        sms.send(toNumber, common.utf8ToGb2312(smsText))
        isSmsCtrl = true
    elseif smsText == config.SMS_CTRL_REBOOT_KEY then
        isSmsCtrl = true
        -- 重启前先保存当前队列
        sys.publish("REBOOT_PREPARE")
        local waitResult, data = sys.waitUntil("REBOOT_READY", 1000 * 60 * 5)

        if not waitResult or data then
            sys.restart("短信控制重启")
        end
    end

    return isSmsCtrl
end

local function readAndSendLocalSms(isInit)
    -- 读取本地短信并发送
    local msgQueue = utilFS.readMsg(true)
    log.info("main.readAndSendLocalSms", "本地短信数量:", #msgQueue)
    if #msgQueue > 0 then
        for _, msgContent in ipairs(msgQueue) do
            utilNotify.add(msgContent)
        end
    end

    if isInit then
        utilFS.initFile()
    end
end

-- 短信接收回调
sms.setNewSmsCb(function(senderNumber, smsContent, m)
    local smsText = common.gb2312ToUtf8(smsContent)
    log.info("smsCallback", m, senderNumber, smsText)

    local now = os.date("*t")
    local time = string.format("%d/%02d/%02d %02d:%02d:%02d", now.year, now.month, now.day, now.hour, now.min, now.sec)

    -- 短信控制
    local receiverNumber, smsContent2beSent = smsText:match("^SMS,(+?%d+),(.+)$")
    receiverNumber, smsContent2beSent = receiverNumber or "", smsContent2beSent or ""
    local isSmsCtrl = smsCtrl(smsContent2beSent, receiverNumber)

    -- 发送通知
    utilNotify.add({smsText, "", "发件号码: " .. senderNumber, "发件时间: " .. time,
                    "#SMS" .. (isSmsCtrl and " #CTRL" or "")}, nil, "短信")

end)

local function booter()
    local waitResult = sys.waitUntil("IP_READY_IND", 1000 * 60 * 3)

    if not waitResult then
        sys.restart("网络未就绪, 重新启动")
    end

    -- 开机通知
    if config.BOOT_NOTIFY then
        utilNotify.add("#BOOT")
    end

    -- 定时查询流量
    if config.QUERY_TRAFFIC_INTERVAL and config.QUERY_TRAFFIC_INTERVAL >= 1000 * 60 then
        sys.timerLoopStart(utilMobile.queryTraffic, config.QUERY_TRAFFIC_INTERVAL)
    end

    readAndSendLocalSms(true)

    -- 定时检查并发送本地短信
    if config.CHECK_LOCAL_SMS_INTERVAL and config.CHECK_LOCAL_SMS_INTERVAL > 0 then
        sys.timerLoopStart(readAndSendLocalSms, config.CHECK_LOCAL_SMS_INTERVAL)
    end

end

sys.taskInit(booter)

-- 启动系统框架
sys.init(0, 0)
sys.run()
