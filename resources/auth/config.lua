Config = {
    db = {
        type = "mysql",
        host = "127.0.0.1",
        port = 3306,
        name = "mta_db",
        user = "root",
        pass = "",
        charset = "utf8"
    },
    spawn = {
        x = 1742.8,
        y = -1863.8,
        z = 13.6,
        rot = 0,
        skin = 0,
        money = 1000
    },
    referral = {
        starterBonus = 1500,
        referrerReward = 5000
    },
    security = {
        maxAttempts = 5,
        lockoutSeconds = 25,
        cooldownMs = 500,
        defaultExpireDays = 7,
        purgeCountdown = 300
    }
}
