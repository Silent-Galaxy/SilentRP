db = nil

local function initDatabase()
    local c = Config.db
    local connStr = string.format("dbname=%s;host=%s;port=%d;charset=%s", c.name, c.host, c.port, c.charset)
    db = dbConnect(c.type, connStr, c.user, c.pass)

    if not db then
        outputDebugString("[AUTH/DB] CRITICAL: Failed to connect to MySQL database!", 1)
        return
    end

    outputDebugString("[AUTH/DB] MySQL Connected successfully.", 3)

    dbExec(db, [[
        CREATE TABLE IF NOT EXISTS accounts (
            id INT AUTO_INCREMENT PRIMARY KEY,
            username VARCHAR(64) NOT NULL UNIQUE,
            password VARCHAR(64) NOT NULL,
            email VARCHAR(128) NOT NULL,
            phone_number VARCHAR(32) DEFAULT '',
            serial VARCHAR(64) NOT NULL,
            last_serial VARCHAR(64) NOT NULL,
            referred_by VARCHAR(64) DEFAULT NULL,
            money INT DEFAULT 1000,
            skin INT DEFAULT 0,
            x FLOAT DEFAULT 1742.8,
            y FLOAT DEFAULT -1863.8,
            z FLOAT DEFAULT 13.6,
            rotation FLOAT DEFAULT 0,
            remember_token VARCHAR(128) DEFAULT NULL,
            registered_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            last_login TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            admin_level INT DEFAULT -1,
            session_expire_days INT DEFAULT 7,
            accepted_rules_version INT DEFAULT 1,
            is_banned TINYINT(1) DEFAULT 0,
            ban_reason VARCHAR(255) DEFAULT NULL,
            banned_by VARCHAR(64) DEFAULT NULL,
            is_muted TINYINT(1) DEFAULT 0,
            mute_reason VARCHAR(255) DEFAULT NULL,
            admin_perms TEXT DEFAULT NULL,
            email_verified TINYINT(1) DEFAULT 0,
            phone_verified TINYINT(1) DEFAULT 0
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8;
    ]])

    dbExec(db, [[
        CREATE TABLE IF NOT EXISTS account_login_logs (
            id INT AUTO_INCREMENT PRIMARY KEY,
            account_id INT NOT NULL,
            ip VARCHAR(64) NOT NULL,
            serial VARCHAR(64) NOT NULL,
            status VARCHAR(32) NOT NULL,
            login_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8;
    ]])
end
addEventHandler("onResourceStart", resourceRoot, initDatabase)
