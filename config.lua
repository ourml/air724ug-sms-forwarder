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
}
