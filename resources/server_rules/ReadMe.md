# 📜 سامانه هوشمند مدیریت و نمایش قوانین سرور (MTA Server Rules System)

سیستمی ماژولار، گرافیکی و مبتنی بر وب (CEF) برای پلتفرم Multi Theft Auto (MTA:SA) جهت نمایش تعاملی، آرشیو نسخه‌ها، پذیرش اجباری قوانین و مدیریت آنلاین متن قوانین سرور به همراه انیمیشن و آبجکت‌های نقش‌آفرینی (RolePlay).

---

## 📌 فهرست مطالب
- [معرفی کلی ایده](#-معرفی-کلی-ایده)
- [هدف سازنده از تولید سیستم](#-هدف-سازنده-از-تولید-سیستم)
- [تجربه کاربر عادی (User Experience)](#-تجربه-کاربر-عادی-user-experience)
- [مزایا و معایب سیستم](#-مزایا-و-معایب-سیستم)
- [پشت صحنه کد و معماری فنی](#-پشت-صحنه-کد-و-معماری-فنی)
- [ساختار فایل‌ها](#-ساختار-فایلها)
- [دستورات و کلیدها](#-دستورات-و-کلیدها)
- [راهنمای راه‌اندازی و اتصال](#-راهنمای-راه‌اندازی-و-اتصال)
- [توابع خروجی (Exports)](#-توابع-خروجی-exports)

---

## 💡 معرفی کلی ایده
در بیشتر سرورهای سنتی سمپ و ام‌تی‌ای، قوانین به صورت متن‌های خسته‌کننده در چت‌باکس، منوهای خشک GUI یا هدایت بازیکن به فروم و دیسکورد نمایش داده می‌شوند.  
این ایده با هدف تبدیل قوانین سرور به یک **مرکز هوشمند، چندنسخه‌ای و تعاملی** درون بازی پیاده‌سازی شده است. قوانین به شکل یک صفحه وب مدرن (CEF UI) با طراحی دارک و راست‌چین باز شده، نسخه‌های تاریخی را نگهداری می‌کند و مدیران سرور می‌توانند مستقیماً از داخل بازی بدون ری‌استارت ریسورس یا دستکاری دیتابیس، قوانین را بازنویسی یا ویرایش کنند.

---

## 🎯 هدف سازنده از تولید سیستم
1. **پایان دادن به بهانه‌تراشی بازیکنان:** ثبت دقیق نسخه پذیرفته‌شده هر پلیر در دیتابیس؛ بازیکن دیگر نمی‌تواند ادعا کند «قوانین تغییر کرده بود و من ندیدم».
2. **بروزرسانی زنده بدون داون‌تایم:** ادمین متن را داخل بازی ادیت می‌کند و در کسری از ثانیه تغییرات برای تمام پلیرها پخش (Broadcast) می‌شود.
3. **افزایش کیفیت نقش‌آفرینی (RP Immersion):** کاراکتر حین خواندن قوانین بی‌حرکت نمی‌ماند، بلکه دفترچه‌ای فیزیکی در دست گرفته و انیمیشن مطالعه اجرا می‌کند.

---

## 🚶‍♂️ تجربه کاربر عادی (User Experience)

### ۱. حین ورود یا ثبت‌نام (First Join / Re-auth):
- پنجره قوانین سرور به صورت مودال تمام‌صفحه و مات بالا می‌آید.
- دکمه سبز رنگ **«قوانین را می‌پذیرم ✓»** ظاهر می‌شود.
- با کلیک روی آن، شماره نسخه جاری در پروفایل بازیکن ذخیره شده و بازی برای او باز می‌شود.

### ۲. حین بازی روزمره (In-Game):
- فشردن کلید **`F5`** یا تایپ دستور `/rules` در هر لحظه پنجره را احضار می‌کند.
- کاراکتر او یک دفترچه و خودکار در دست می‌گیرد و ژست مطالعه به خود اختصاص می‌دهد.
- کاربر به راحتی در آرشیو سمت چپ سوییچ کرده و تغییرات نسخه‌های مختلف سرور را ورق می‌زند.
- با فشردن مجدد **`F5`** یا کلید **`Escape`**، پنجره محو شده و انیمیشن کاراکتر متوقف می‌شود.

---

## ⚖️ مزایا و معایب سیستم

| مزایا (Pros) | معایب و چالش‌ها (Cons) |
| :--- | :--- |
| **کنترل نسخه (Versioning):** آرشیو کامل تغییرات همراه با نام نگارنده و تاریخ انتشار | **وابستگی به مرورگر کلاینت (CEF):** نیاز به لود موتور کرومیوم داخلی ام‌تی‌ای |
| **کدگذاری Hex برای پارسی‌نویسی:** حل قطعی مشکل به‌هم‌ریختگی حروف فارسی در ارتباط Lua به JS | **عدم وجود سیستم بازگشت تغییرات (Draft Undo):** هنوز دکمه واگرد تاریخچه ویرایش در فرانت وجود ندارد |
| **انیمیشن و آبجکت همگام‌سازی‌شده:** پنهان‌سازی خودکار و پاکسازی اشیاء در صورت مرگ یا خروج پلیر | **وابستگی مستقیم به MySQL:** عدم پشتیبانی پیش‌فرض از دیتابیس لوکال SQLite بدون تغییر در `server.lua` |
| **سیستم دسترسی چندلایه (Multi-tier Admin):** بررسی دیتا، ستون‌های دیتابیس و گروه‌های ACL به‌صورت خودکار | |

---

## ⚙️ پشت صحنه کد و معماری فنی

### ۱. معماری پل تبادل داده (Hex-Encoding Data Bridge):
انتقال رشته‌های حاوی کاراکترهای یونیکد (فارسی) میان دیتابیس MySQL، کدهای Lua و جاوااسکریپت مرورگر CEF عموماً با مشکل خراب شدن متون (Mojibake) همراه است.
- در کلاینت (`client.lua`): تمام داده‌های جدول از طریق تابع `stringToHex` به کد هگز تبدیل می‌شوند.
- در مرورگر (`rules.html`): متن هگز بدون درگیری با انکودینگ از پل گذشته و توسط `TextDecoder('utf-8')` مجدداً به متن سالم تبدیل می‌گردد.

### ۲. سیستم اتصال فیزیکی آبجکت (Prop & Bone Attachment):
هنگام باز شدن رابط کاربری، اسکریپت آبجکت شماره `2894` (دفترچه) را در دست کاراکتر اسپاون می‌کند. کد به‌صورت هوشمند بررسی می‌کند؛ اگر ریسورس `bone_attach` فعال باشد، آبجکت به استخوان مچ دست متصل می‌گردد، در غیر این صورت به عنوان فال‌بک با دستور استاندارد `attachElements` به بدن متصل می‌شود.

### ۳. مدیریت دسترسی و پایش امنیتی (Security & Permission Layer):
کلاینت هیچ اختیاری برای تغییر قوانین ندارد؛ با کلیک دکمه ذخیره، ایونت سمت سرور فراخوانی شده و سرور مجدداً سطح دسترسی بازیکن را از ۳ لایه مجزا بررسی می‌کند:
1. داده‌های کلاینتی کاراکتر (`admin_level`, `admin_perms`)
2. کوئری زنده روی جدول `accounts` بر اساس سریال کاراکتر
3. بررسی لیست سطوح دسترسی پیش‌فرض سرور (`ACL: Admin Group`)

---

## 📁 ساختار فایل‌ها

```text
resources/
└── server_rules/
    ├── meta.xml           # معرفی ماژول‌ها، خروجی‌ها و فایل‌های کلاینت/سرور
    ├── config.lua         # تنظیمات کلیدها، دستورات، اتصالات دیتابیس و دسترسی
    ├── server.lua         # لاجیک دیتابیس، کنترل دسترسی، انیمیشن و رویدادهای سرور
    ├── client.lua         # مدیریت مرورگر CEF، بایند کلیدها و ارسال داده
    └── ui/
        └── rules.html     # فرانت‌اند کامل (طراحی واکنش‌گرا، پنل مدیریت، رندرر)
```

---

## ⌨️ دستورات و کلیدها

| فرمان / کلید | سطح دسترسی | عملکرد |
| :--- | :--- | :--- |
| **`F5`** | عمومی (همه بازیکنان) | باز و بسته کردن آنی پنجره قوانین همراه با انیمیشن |
| **`/rules`** یا **`/ghavanin`** | عمومی (همه بازیکنان) | دستور متنی معادل برای نمایش پنل قوانین |
| **`Shift + F2`** | مدیران سرور (Admin) | باز کردن مستقیم حالت ویرایش و نگارش نسخه‌های دیتابیس |
| **`Escape`** | عمومی | بستن سریع پنل و بازگشت کنترل ماوس به بازی |

---

## 🛠️ راهنمای راه‌اندازی و اتصال

### ۱. پایگاه داده (MySQL)
جدول مربوطه به صورت کاملاً خودکار در اولین استارت ریسورس ساخته می‌شود. تنها کافی است در فایل `config.lua` اطلاعات هاست را وارد کنید:
```lua
RulesConfig = {
    db = {
        type = "mysql",
        host = "127.0.0.1",
        port = 3306,
        name = "mta_db",
        user = "root",
        pass = "",
        charset = "utf8mb4"
    },
    userKey = "f5",
    command = "rules",
    aliasCommand = "ghavanin"
}
```

### ۲. سازگاری با سیستم ثبت نام / لاگین (Auth Integration)
در صورتی که قصد دارید قوانین هنگام ثبت‌نام یا ورود برای کاربر باز شود و تا زمان تایید اجازه ادامه نداشته باشد، کافیست در اسکریپت Auth خود از تابع اکسپورت شده زیر استفاده فرمایید:

```lua
-- باز کردن قوانین برای بازیکن در وضعیت ثبت‌نام
exports.server_rules:openRulesForPlayer(playerElement, "register")

-- گوش دادن به تایید قوانین توسط کاربر در سرور:
addEventHandler("rules:onPlayerAcceptedRules", root, function(player, versionNumber, action)
    if action == "register" then
        outputChatBox("قوانین نسخه " .. versionNumber .. " توسط بازیکن تایید شد.", player)
        -- ادامه مراحل ثبت‌نام یا ریسپاون پلیر
    end
end)
```

---

## 📤 توابع خروجی (Exports)

```lua
-- دریافت شماره آخرین نسخه فعال سرور (سمت سرور)
local currentVersion = exports.server_rules:getActiveRuleVersion()

-- فراخوانی اجباری پنل قوانین برای یک بازیکن معین (سمت سرور)
exports.server_rules:openRulesForPlayer(playerElement, "login" --[[ یا "view" ]])
```




در ادامه، **۷ دیاگرام مهندسی مدرن و تفکیک‌شده** با سینتکس استاندارد **PlantUML** آماده شده است. این دیاگرام‌ها با بهره‌گیری از استایل مدرن (پالت‌های تاریک/نیلی مطابق رابط کاربری پروژه) طراحی شده‌اند و می‌توانید مستقیماً کدهای درون هر بلوک را در وب‌سایت [editor.plantuml.com](https://editor.plantuml.com/) تست یا در انتهای فایل `README.md` اضافه کنید.

---

## 📐 دیاگرام‌های تحلیل مهندسی معماری سیستم

---

### ۱. دیاگرام کلان معماری و اجزای سیستم (System Architecture & Component Diagram)
![1](image.png)
> تحلیل رابطه لایه‌ای میان هسته کلاینت، مرورگر محلی CEF، سرور، سرویس‌های جانبی و دیتابیس MySQL.

```plantuml
@startuml
!theme vibrant
skinparam roundcorner 12
skinparam componentStyle uml2
skinparam shadowing true
skinparam defaultFontName "Segoe UI, Tahoma"

package "Client Engine (MTA:SA Client)" {
    [CEF Browser Engine] as CEF
    component "ui/rules.html\n(HTML5 / Tailwind Dark CSS / JS)" as Frontend
    component "client.lua\n(Browser Bridge & Key Listener)" as ClientCore
    CEF -down-> Frontend : Renders
    Frontend <-> ClientCore : Hex IPC & Browser Events
}

package "External Dependencies" {
    [bone_attach Resource] as BoneAttach
    [MTA ACL Engine] as ACL
}

package "Server Engine (MTA:SA Server)" {
    component "server.lua\n(Controller & Event Dispatcher)" as ServerCore
    component "Permission Evaluator\n(3-Tier Guard)" as AuthGuard
    component "Roleplay Prop Manager\n(Notepad & Animation Sync)" as PropMgr
    
    ServerCore --> AuthGuard : Verify Requests
    ServerCore --> PropMgr : Trigger Anim/Object
}

database "MySQL Database (mta_db)" {
    [server_rules Table] as TblRules
    [accounts Table] as TblAccounts
}

ClientCore <..> ServerCore : Latency-Safe Net Events
PropMgr ..> BoneAttach : Attach to Bone 12
AuthGuard ..> ACL : ACL Fallback
AuthGuard --> TblAccounts : Query Account Data
ServerCore --> TblRules : CRUD Versioned Rules

@enduml
```

---

### ۲. دیاگرام توالی باز کردن پنل و انیمیشن نقش‌آفرینی (Player Immersion & Viewing Sequence)
![2](image-1.png)
> جریان داده و اقدامات همزمان در کلاینت و سرور هنگام فشردن کلید `F5` توسط کاربر عادی.

```plantuml
@startuml
!theme vibrant
autonumber
skinparam defaultFontName "Segoe UI, Tahoma"
skinparam sequenceMessageAlign center

actor "Player (User)" as P
participant "Client (client.lua)" as CL
participant "CEF Window\n(rules.html)" as CEF
participant "Server (server.lua)" as SV
entity "Notepad Prop\n(Model 2894)" as Prop
database "MySQL" as DB

P -> CL : Presses F5 Key
activate CL
CL -> SV : rules:serverRequestRulesData("view")
activate SV

par Character RP Immersion
    SV -> Prop : createObject(2894) at Player Pos
    SV -> Prop : Attach to Hand (Bone 12)
    SV -> P : setPedAnimation("COP_AMBIENT", "Coplook_think")
else Data Retrieval
    SV -> DB : SELECT * FROM server_rules ORDER BY version DESC
    DB --> SV : Return Rules Records
end

SV --> CL : rules:clientOpenModal(rulesList)
deactivate SV

CL -> CL : stringToHex(toJSON(rulesList))
CL -> CEF : executeBrowserJavascript(receiveRulesHex)
activate CEF
CEF -> CEF : hexToUtf8() & Parse JSON
CEF --> P : Render Dark UI with Rules & Archives
deactivate CEF

... پلیر قوانین را مطالعه می‌کند ...

P -> CL : Presses Escape or Close
CL -> CEF : guiSetVisible(false)
CL -> SV : rules:serverStopReadingAnim
activate SV
SV -> Prop : destroyElement()
SV -> P : setPedAnimation(false)
deactivate SV
deactivate CL
@enduml
```

---

### ۳. دیاگرام توالی چرخه حیات مدیریت و انتشار نسخه جدید (Admin Lifecycle & Live Broadcast)
![3](image-2.png)
> فرآیند تایید دسترسی ادمین، ثبت نسخه جدید در دیتابیس و همگام‌سازی زنده برای تمام کاربران سرور بدون ری‌استارت.

```plantuml
@startuml
!theme vibrant
autonumber
skinparam defaultFontName "Segoe UI, Tahoma"

actor "Admin" as Adm
participant "Admin UI" as UI
participant "Server Controller" as SV
participant "Auth Guard" as Auth
database "MySQL" as DB
collections "Connected Players" as Players

Adm -> UI : Edits Title/Text & Clicks "انتشار نسخه جدید"
UI -> SV : rules:serverPublishNewVersion(title, content)
activate SV

SV -> Auth : checkPlayerAdminAccess(client)
activate Auth
Auth --> SV : Access Granted (Admin Level / ACL Verified)
deactivate Auth

SV -> DB : SELECT MAX(version) FROM server_rules
DB --> SV : Returns Current Max Version (e.g. 3)

SV -> DB : UPDATE server_rules SET is_active = 0
SV -> DB : INSERT INTO server_rules (version=4, is_active=1, ...)
SV -> DB : UPDATE accounts SET accepted_rules_version=4 WHERE id=adminId

SV -> Adm : outputChatBox("نسخه جدید ثبت و فعال گردید")

group Real-Time Zero-Downtime Broadcast
    SV -> DB : Fetch All Latest Rules
    DB --> SV : Latest Rules List
    loop For Each Connected Player
        SV -> Auth : Check if Player is Admin
        Auth --> SV : Status
        SV -> Players : triggerClientEvent("rules:clientSyncRulesData", data, isAdmin)
    end
end

Players -> Players : Re-render Active Rules & Archive Tab in Background
deactivate SV
@enduml
```

---

### ۴. ماشین وضعیت چرخه حیات رابط کاربری و پلیر (State Machine Diagram)
![4](image-3.png)
> بررسی وضعیت‌های سیستم کلاینت و انیمیشن از حالت آماده‌باش تا مشاهده، ویرایش، و پاک‌سازی استثناها.

```plantuml
@startuml
!theme vibrant
skinparam defaultFontName "Segoe UI, Tahoma"
skinparam state {
    BorderColor #334155
    BackgroundColor #0f172a
    FontColor #f8fafc
}

[*] --> IDLE : Resource Initialized / Browser Loaded in Background

state IDLE {
    description: پلیر آزادانه در دنیای بازی در حال حرکت است
}

IDLE --> READING_SESSION : Press F5 / Command / Modal Auth
state READING_SESSION {
    state "Attaching Notepad & Starting Coplook_think Anim" as StartAnim
    state "CEF Focused & Input Mode Disabled" as FocusUI
    
    StartAnim --> FocusUI
    
    state VIEW_MODE {
        [*] --> BrowsingActiveRule
        BrowsingActiveRule --> BrowsingArchive : Click History Tab
        BrowsingArchive --> BrowsingActiveRule : Click Active Tab
        BrowsingActiveRule --> AcceptedModal : Click 'قوانین را می‌پذیرم'
    }

    state ADMIN_MODE {
        [*] --> EditingExisting
        EditingExisting --> DraftingNewVersion : Click '+ نسخه جدید'
        DraftingNewVersion --> PublishedState : Click Publish
    }

    FocusUI --> VIEW_MODE : Regular Player
    FocusUI --> ADMIN_MODE : Verified Admin (Toggle or Shift+F2)
    ADMIN_MODE --> VIEW_MODE : Toggle View Mode
}

READING_SESSION --> CLEANUP : Press Esc / F5 / Die / Disconnect
state CLEANUP {
    description: تخریب آبجکت دفترچه، ریست انیمیشن، بازگشت کنترل ماوس به بازی
}

CLEANUP --> IDLE : Ready for Next Interaction
@enduml
```

---

### ۵. فلوچارت تفصیلی پایش امنیتی سه لایه‌ای (3-Tier Security Authorization Pipeline)
![5](image-4.png)
> تصمیم‌گیری دقیق در تابع `checkPlayerAdminAccess` جهت جلوگیری از هرگونه دستکاری کلاینتی.

```plantuml
@startuml
!theme vibrant
skinparam defaultFontName "Segoe UI, Tahoma"
skinparam ConditionEndStyle hline

start
:Client triggers Protected Action (Publish / Update / Delete);
:Server receives Client Element Reference;

partition "Layer 1: Runtime ElementData Check" {
    if (ElementData 'admin_perms' contains 'rules'\nOR 'admin_level' >= 0?) then (Yes)
        :Grant Access (Fast Path);
        stop
    else (No / Nil)
    endif
}

partition "Layer 2: Live SQL Account Verification" {
    :Execute Async Query on 'accounts' Table\n(Match by Serial, Account ID or Character Name);
    if (DB Record Found AND (dbLvl >= 0 OR dbPerms contains 'rules')?) then (Yes)
        :Grant Access (DB Verified);
        stop
    else (No Match / Normal Player)
    endif
}

partition "Layer 3: MTA Native ACL Engine Fallback" {
    if (Player Account is Logged in?) then (Yes)
        if (Account is Object in 'Admin' ACL Group?) then (Yes)
            :Grant Access (ACL Verified);
            stop
        else (No)
        endif
    else (Guest Account)
    endif
}

:Reject Action (Access Denied);
:Send Warning Red Message to Player ChatBox;
stop
@enduml
```

---

### ۶. دیاگرام مدل داده و روابط جداول پایگاه داده (Entity-Relationship Diagram)
![6](image-5.png)
> نگاشت ساختار جدول‌های دیتابیس `server_rules` و نحوه ارتباط آن با اعتبارسنجی پذیرش در جدول `accounts`.

```plantuml
@startuml
!theme vibrant
skinparam defaultFontName "Segoe UI, Tahoma"
skinparam linetype ortho

entity "server_rules" as rules {
    * id : INT <<PK, AutoIncrement>>
    --
    * version : INT <<Unique/Incremental>>
    * title : VARCHAR(150)
    * content : TEXT
    * created_by : VARCHAR(50)
    * created_at : DATETIME
    * is_active : TINYINT(1) <<Default 1>>
}

entity "accounts" as acc {
    * id : INT <<PK, AutoIncrement>>
    --
    * username : VARCHAR(50)
    serial : VARCHAR(64)
    admin_level : INT
    admin_perms : TEXT
    accepted_rules_version : INT <<FK Reference>>
}

entity "Player ElementData\n(Virtual In-Memory Cache)" as vdata {
    account:id : INT
    account:username : STRING
    admin_level : INT
    admin_perms : STRING
}

acc ||..o{ rules : "references accepted version"
vdata ..> acc : "mirrors runtime session"
rules ||--o{ rules : "version archive history"
@enduml
```

---

### ۷. پایپ‌لاین عبور داده‌های فارسی و مکانیزم امن هگز (Hex-Encoding UTF-8 Pipe)
![7](image-6.png)
> تحلیل معماری مهندسی ضد-موجی‌باک (Anti-Mojibake) برای تضمین نمایش بی‌نقص الفبای فارسی در ام‌تی‌ای.

```plantuml
@startuml
!theme vibrant
skinparam defaultFontName "Segoe UI, Tahoma"
skinparam packageStyle rectangle

rectangle "MySQL Database" as S1 #090e1a {
    storage "UTF-8 Multi-byte Arabic/Persian String\n'قوانین و مقررات رسمی سرور'" as D1 #1e293b
}

rectangle "MTA Server (Lua)" as S2 #090e1a {
    storage "JSON Serialization\ntoJSON(rulesTable, true)" as D2 #1e293b
}

rectangle "MTA Client (Lua Bridge)" as S3 #090e1a {
    storage "stringToHex Conversion\n'd982d988d8a7d986db8cd986...'" as D3 #1e293b
}

rectangle "CEF Chromium (JavaScript)" as S4 #090e1a {
    storage "Uint8Array Byte Pair Parsing\nhex.match(/.{1,2}/g)" as D4 #1e293b
    storage "Native TextDecoder Engine\nnew TextDecoder('utf-8').decode(bytes)" as D5 #1e293b
}

rectangle "DOM View (HTML5)" as S5 #090e1a {
    storage "Clean, Glitch-Free Persian Text\nElement.innerText = Decoded String" as D6 #0284c7
}

D1 -right-> D2 : Direct utf8mb4 Driver Read
D2 -right-> D3 : triggerClientEvent Payload
D3 -down-> D4 : executeBrowserJavascript(code)
D4 -right-> D5 : Pure Binary Stream
D5 -right-> D6 : Pristine Unicode Injection into UI

@enduml
```