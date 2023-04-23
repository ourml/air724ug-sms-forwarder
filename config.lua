return {
    -- 通知类型, 支持配置多个
    NOTIFY_TYPE = {"bark", "next-smtp-proxy"},
    --
    -- bark 通知配置, https://github.com/Finb/Bark
    BARK_API = "https://api.day.app",
    BARK_KEY = "",
    -- next-smtp-proxy 通知配置, https://github.com/0wQ/next-smtp-proxy
    NEXT_SMTP_PROXY_API = "",
    NEXT_SMTP_PROXY_USER = "",
    NEXT_SMTP_PROXY_PASSWORD = "",
    NEXT_SMTP_PROXY_HOST = "smtp.office365.com",
    NEXT_SMTP_PROXY_PORT = 587,
    NEXT_SMTP_PROXY_FORM_NAME = "Air724UG",
    NEXT_SMTP_PROXY_TO_EMAIL = "test@outlook.com",
    NEXT_SMTP_PROXY_SUBJECT = "来自 Air724UG 的通知",
    --
    -- 定时查询流量间隔, 单位毫秒, 设置为 0 关闭 (建议检查 util_mobile.lua 文件中运营商号码和查询代码是否正确, 以免发错短信导致扣费, 收到查询结果短信发送通知会消耗流量)
    QUERY_TRAFFIC_INTERVAL = 1000 * 60 * 60 * 24 * 7,
    --
    -- 开机通知
    BOOT_NOTIFY = true,
    --
    -- 通知最大重发次数
    NOTIFY_RETRY_MAX = 100,
    --
    -- 短信重启指令, 当给指定号码发送此短信时(eg: SMS,手机号码,reboot)，会自动重启系统
    SMS_CTRL_REBOOT_KEY = "reboot",
    --
    -- 日志上报服务器地址（注释引用自 errDump.lua 库）
    --
    --- 配置调试服务器地址，启动错误信息上报给调试服务器的功能，上报成功后，会清除错误信息
    -- @string addr，调试服务器地址信息，支持http，udp，tcp
    -- 1、如果调试服务器使用http协议，终端将采用POST命令，把错误信息上报到addr指定的URL中，addr的格式如下
    --   (除protocol和hostname外，其余字段可选；目前的实现不支持hash)
    --   |------------------------------------------------------------------------------|
    --   | protocol |||   auth    |      host       |           path            | hash  |
    --   |----------|||-----------|-----------------|---------------------------|-------|
    --   |          |||           | hostname | port | pathname |     search     |       |
    --   |          |||           |----------|------|----------|----------------|       |
    --   "   http   :// user:pass @ host.com : 8080   /p/a/t/h ?  query=string  # hash  "
    --   |          |||           |          |      |          |                |       |
    --   |------------------------------------------------------------------------------|
    -- 2、如果调试服务器使用udp协议，终端将错误信息，直接上报给调试服务器，调试服务器收到信息后，要回复大写的OK；addr格式如下：
    --   |----------|||----------|------|
    --   | protocol ||| hostname | port |
    --   |          |||----------|------|
    --   "   udp    :// host.com : 8081 |
    --   |          |||          |      |
    --   |------------------------------|
    -- 3、如果调试服务器使用tcp协议，终端将错误信息，直接上报给调试服务器；addr格式如下：
    --   |----------|||----------|------|
    --   | protocol ||| hostname | port |
    --   |          |||----------|------|
    --   "   tcp    :// host.com : 8082 |
    --   |          |||          |      |
    --   |------------------------------|
    -- @number[opt=600000] period，单位毫秒，定时检查错误信息并上报的间隔
    -- @bool flag，当使用合宙调试服务器时，此参数填为true；使用自定义服务器时，此参数可省略
    -- @return bool result，成功返回true，失败返回nil
    -- @usage
    -- errDump.request("http://www.user_server.com/errdump")
    -- errDump.request("udp://www.user_server.com:8081")
    -- errDump.request("tcp://www.user_server.com:8082")
    -- errDump.request("tcp://www.user_server.com:8082",6*3600*1000)
    -- errDump.request("udp://www.hezhou_server.com:8083",6*3600*1000,true)
    ERROR_DUMP_HOST = "udp://www.user_server.com:8081",
    --
    -- 定时检查并发送本地短信间隔, 单位毫秒, 设置为 0 关闭
    CHECK_LOCAL_SMS_INTERVAL = 1000 * 60 * 2,
}
