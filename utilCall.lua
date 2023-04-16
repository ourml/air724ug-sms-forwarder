module(..., package.seeall)
require "cc"
require "audio"
require "common"
require "utilNotify"

-- 来电铃声播放协程ID
local coIncoming

local function callVolTest()
    local curVol = audio.getCallVolume()
    curVol = (curVol >= 7) and 1 or (curVol + 1)
    log.info("utilCall.setCallVolume", curVol)
    audio.setCallVolume(curVol)
end

--- “通话已建立”消息处理函数
-- @string num，建立通话的对方号码
-- @return 无
local function connected(num)
    log.info("utilCall.connected")
    coIncoming = nil
    -- 通话中设置mic增益，必须在通话建立以后设置
    -- audio.setMicGain("call",7)
    -- 通话中音量测试
    sys.timerLoopStart(callVolTest, 5000)
    -- 通话中向对方播放TTS测试
    audio.play(7, "TTS", "通话中TTS测试", 7, nil, true, 2000)
    -- 110秒之后主动结束通话
    sys.timerStart(cc.hangUp, 110000, num)
end

--- “通话已结束”消息处理函数
-- @string discReason，通话结束原因值，取值范围如下：
--                                     "CHUP"表示本端调用cc.hungUp()接口主动挂断
--                                     "NO ANSWER"表示呼出后，到达对方，对方无应答，通话超时断开
--                                     "BUSY"表示呼出后，到达对方，对方主动挂断
--                                     "NO CARRIER"表示通话未建立或者其他未知原因的断开
--                                     nil表示没有检测到原因值
-- @return 无
local function disconnected(discReason)
    coIncoming = nil
    log.info("utilCall.disconnected", discReason)
    sys.timerStopAll(cc.hangUp)
    sys.timerStop(callVolTest)
    audio.stop()
end

--- “来电”消息处理函数
-- @string num，来电号码
-- @return 无
local function incoming(num)
    log.info("utilCall.incoming:" .. num)
    local now = os.date("*t")
    local time = string.format("%d/%02d/%02d %02d:%02d:%02d", now.year, now.month, now.day, now.hour, now.min, now.sec)

    -- 来电通知
    utilNotify.add({"未接来电: " .. num, "来电时间: " .. time}, nil, "未接来电")

    if not coIncoming then
        coIncoming = sys.taskInit(function()
            while true do
                audio.play(1, "FILE", "/lua/call.mp3", 4, function()
                    sys.publish("PLAY_INCOMING_RING_IND")
                end, true)
                sys.waitUntil("PLAY_INCOMING_RING_IND")
                break
            end
        end)
        -- 不接来电
        -- sys.subscribe("POWER_KEY_IND", function()
        --     audio.stop(function()
        --         cc.accept(num)
        --     end)
        -- end)
    end

end

--- “通话功能模块准备就绪””消息处理函数
-- @return 无
local function ready()
    log.info("utilCall.ready")
end

--- “通话中收到对方的DTMF”消息处理函数
-- @string dtmf，收到的DTMF字符
-- @return 无
local function dtmfDetected(dtmf)
    log.info("utilCall.dtmfDetected", dtmf)
end

-- 订阅消息的用户回调函数
sys.subscribe("NET_STATE_REGISTERED", ready)
sys.subscribe("CALL_INCOMING", incoming)
sys.subscribe("CALL_CONNECTED", connected)
sys.subscribe("CALL_DISCONNECTED", disconnected)
cc.dtmfDetect(true)
sys.subscribe("CALL_DTMF_DETECT", dtmfDetected)
