# ⚡ Web Scoreboard (CEF Modern RP Scoreboard)

> اسکوربورد مدرن، فوق‌سریع و شیشه‌ای (Dark-Glass) مبتنی بر وب (CEF) برای سرورهای رول‌پلی ام‌تی‌ای (MTA:SA) با پشتیبانی کامل از زبان فارسی و راست‌چین (RTL).

---

## 📌 فهرست مطالب
- [💡 ایده چیست و چرا متولد شد؟](#-ایده-چیست-و-چرا-متولد-شد)
- [🎯 هدف سازنده](#-هدف-سازنده)
- [👤 تجربه و فرایند مصرف کاربر عادی](#-تجربه-و-فرایند-مصرف-کاربر-عادی)
- [⚙️ پشت صحنه کد چه اتفاقی می‌افتد؟](#️-پشت-صحنه-کد-چه-اتفاقی-می‌افتد)
- [⚖️ مزایا و معایب](#️-مزایا-و-معایب)
- [📂 ساختار فایل‌ها](#-ساختار-فایل‌ها)
- [🚀 راهنمای نصب و راه‌اندازی](#-راهنمای-نصب-و-راه‌اندازی)

---

## 💡 ایده چیست و چرا متولد شد؟

در اکثر سرورهای بازی Multi Theft Auto، اسکوربوردها با کدهای قدیمی رندرینگ گرافیکی (`dxDraw`) نوشته شده‌اند؛ خروجی این روش معمولاً فونت‌های بی‌کیفیت و دندانه‌دار فارسی، سنگین شدن کلاینت و ظاهری خشک و قدیمی است.

**ایده‌ی این پروژه:** جایگزینی سیستم رندر سنتی با موتور مرورگر کلاینت (**CEF - Chromium Embedded Framework**). با این کار، طراحی رابط کاربری مستقیماً با فناوری‌های وب مدرن (HTML5 ،CSS3 و Vanilla JS) اجرا می‌شود و خروجی فوق‌العاده نرم، شفاف و مینیمال با تایپوگرافی تمیز فارسی پدید می‌آید.

---

## 🎯 هدف سازنده

1. **ارتقای هویت رول‌پلی سرور:** اطلاع آنی از وضعیت ارگان‌های حیاتی شهر (پلیس، امداد، مکانیک، مدیریت و حضور شخص شهردار).
2. **بهینگی و حذف افت فریم (FPS Drop):** جلوگیری از پردازش‌های سنگین ریاضی در حلقه رندر با انتقال بار بصری به لایه وب و رندر مستقیم DOM.
3. **انعطاف در شخصی‌سازی:** ایجاد محیطی که توسعه‌دهنده بتواند تنها با تغییر چند خط CSS، استایل را بدون دستکاری منطق سرور دگرگون کند.

---

## 👤 تجربه و فرایند مصرف کاربر عادی

یک پلیر عادی در سرور دقیقاً با سناریوی زیر مواجه می‌شود:

1. **فشردن و نگه‌داشتن کلید `TAB`:**
   - صفحه مات و تاریک پشت اسکوربورد همراه با پنل شیشه‌ای لوکس پدیدار می‌شود.
   - وضعیت آنلاین یا آفلاین بودن شهردار با کادر نئونی سبز یا قرمز بالای صفحه جلب توجه می‌کند.
   - آمار لحظه‌ای افراد آنلاین و تعداد نیروهای وظیفه (On-Duty) ارگان‌ها نمایش داده می‌شود.
2. **اسکرول روان حین بازی:**
   - کاربر نیاز به فعال‌سازی ماوس ندارد؛ صرفاً با چرخاندن اسکرول ماوس (Mouse Wheel) لیست بازیکنان به بالا و پایین جابه‌جا می‌شود.
3. **رها کردن کلید `TAB`:**
   - منو به سرعت و بدون تأخیر مخفی می‌شود تا دید کاربر برای مبارزه یا رانندگی مختل نماند.
4. **حالت قفل پین (`/tab`):**
   - کاربر با تایپ کامند `/tab` می‌تواند پنل را روی صفحه ثابت نگه دارد، نشانگر ماوس فعال شده و امکان بررسی راحت‌تر یا یادداشت آیدی‌ها برای او فراهم شود.

---

## ⚙️ پشت صحنه کد چه اتفاقی می‌افتد؟

```
[ پلیر کلید TAB را می‌فشارد ]
             │
             ▼
[ Client (client.lua) ] ── (بررسی کول‌داون ۱.۵ ثانیه‌ای) ──► [ Server (server.lua) ]
                                                                      │
                                                           استخراج و پردازش اطلاعات:
                                                           - شناسایی شهردار با سریال/اکانت
                                                           - شمارش تفکیکی ارگان‌های On-Duty
                                                           - فیلتر پدها (NPC/Bots)
                                                           - سورت کردن (شهردار در صدر)
                                                                      │
[ Client Browser (CEF) ] ◄── (ارسال دیتای JSON) ◄─────────────────────┘
             │
   (اجرای تابع renderData)
             │
   - تغییر کلاس کادر شهردار
   - بهینه‌سازی تزریق با innerHTML
   - پاکسازی و ضدعفونی رشته‌ها (XSS Escape)
```

1. **محدودسازی درخواست (Anti-Spam / Throttle):** داخل کلاینت با متغیر `lastRequestTime` جلوی اسپم کلید `TAB` گرفته شده است؛ اگر زیر ۱.۵ ثانیه دوباره TAB فشرده شود، همان اطلاعات قبلی نشان داده می‌شود و درخواست بیهوده به سرور ارسال نخواهد شد.
2. **بررسی نقش‌ها و ارگان‌ها در سرور:** سرور لیست کامل بازیکنان را می‌گیرد، سریال و اکانت شهردار (`MAYOR_SERIAL`) را مقایسه می‌کند، سپس از روی `ElementData` ارگان‌ها، تعداد افراد در حال شیفت (پلیس، امدادگر و مکانیک) را می‌شمارد.
3. **امنیت در رندرینگ وب (Anti-XSS):** در سمت جاوااسکریپت با تابع `escapeText`، کاراکترهای خطرناک مانند `<`، `>` یا کوتیشن‌ها فیلتر می‌شوند تا کسی با نام کاربری آلوده قادر به تزریق اسکریپت در کلاینت بقیه نباشد.

---

## ⚖️ مزایا و معایب

### ✅ مزایا
- **زیبایی مدرن:** رابط کاربری دارک گلس شفاف، سازگار با استانداردهای مدرن فرانت‌اند.
- **اسکرول هوشمند:** قابلیت اسکرول با چرخ ماوس بدون نیاز به قفل کردن ماوس و فعال‌سازی کرسر.
- **تفکیک خودکار و اولویت‌بندی:** قرارگیری خودکار شهردار در ردیف نخست با استایل طلایی و شاخص پینگ رنگی (سبز، زرد، قرمز).
- **فوق‌العاده سبک برای ترافیک سرور:** مصرف پهنای باند بسیار اندک به دلیل بسته‌بندی در قالب سبک JSON.

### ❌ معایب
- **وابستگی به سخت‌افزار پلیر برای CEF:** در سیستم‌های به شدت ضعیف، مرورگر داخلی MTA ممکن است در اولین باز شدن (First Load) کسر میلی‌ثانیه‌ای مکث داشته باشد.
- **شناسه ثابت (هاردکد) برای شهردار:** در فایل `server.lua` سریال شهردار به شکل ایستا درج شده است و برای تغییر آن نیاز به ویرایش کد یا افزودن سیستم دیتابیس/ACL خواهد بود.

---

## 📂 ساختار فایل‌ها

```bash
resources/web_scoreboard/
├── meta.xml           # پیکربندی اسکریپت‌ها و فایل‌های مجاز وب
├── server.lua         # پردازش اطلاعات ارگان‌ها و پلیرها
├── client.lua         # کنترل CEF، مانیتورینگ کلیدها و رندر نهایی
└── html/
    ├── index.html     # اسکلت اصلی اسکوربورد
    ├── style.css      # استایل‌های دارک‌گلس و فونت‌ها
    └── script.js      # کنترل انیمیشن‌ها و رندر داده‌های کلاینت
```

---

## 🚀 راهنمای نصب و راه‌اندازی

1. پوشه `web_scoreboard` را درون مسیر منابع سرور خود کپی کنید:
   ```path
   server/mods/deathmatch/resources/web_scoreboard
   ```
2. در صورتی که تمایل دارید صاحب امتیاز شهردار عوض شود، خط اول و دوم فایل `server.lua` را مطابق نیاز ادیت کنید:
   ```lua
   local MAYOR_SERIAL = "سریال_مورد_نظر"
   local MAYOR_ACCOUNT = "نام_اکانت_شهردار"
   ```
3. در کنسول سرور دستور زیر را تایپ کنید:
   ```bash
   start web_scoreboard
   # یا برای بارگذاری مجدد:
   restart web_scoreboard
   ```
4. وارد سرور شوید و با فشردن کلید **TAB** از عملکرد آن لذت ببرید!























---

### ۱. نمودار معماری کلان و کامپوننت‌ها (Component Architecture)
![1](image.png)
> **زاویه دید:** تفکیک لایه‌های سرور، کلاینت، مرورگر داخلی (CEF) و تعامل فایل‌ها با موتور MTA.

```plantuml
@startuml
!theme vibrant
title معماری ماژولار و اجزای سیستم Web Scoreboard

package "MTA Server Host" {
    [meta.xml] as Meta
    [server.lua] as ServerScript
    database "ElementData Store\n(faction, duty, id)" as EData
}

package "MTA Client PC" {
    [client.lua] as ClientScript
    
    package "Chromium Embedded Framework (CEF)" {
        [index.html] as HTML
        [style.css] as CSS
        [script.js] as JS
    }
    
    component "DirectX Render Pipeline\n(dxDrawImage)" as DX
}

Meta ..> ServerScript : بارگذاری ماژول سرور
Meta ..> ClientScript : بارگذاری ماژول کلاینت

ClientScript -right-> ServerScript : triggerServerEvent ("scoreboard:requestSync")
ServerScript -left-> ClientScript : triggerClientEvent ("scoreboard:receiveSync")
ServerScript --> EData : استعلام اطلاعات بازیکنان

ClientScript --> HTML : ایجاد و راه‌اندازی CEF
HTML --> CSS : اعمال استایل دارک‌گلس
HTML --> JS : پردازش منطق فرانت‌اند

ClientScript --> JS : executeBrowserJavascript (renderData)
ClientScript --> DX : ترسیم فریم خروجی در صفحه
@enduml
```

---

### ۲. نمودار توالی سناریوی فشردن کلید (Sequence Diagram)
![2](image-1.png)
> **زاویه دید:** مسیر زمانی از لحظه فشردن کلید TAB توسط بازیکن تا رندر پیکسل‌ها در وب‌ویو و اسکرول با ماوس.

```plantuml
@startuml
!theme cerulean
autonumber
actor "پلیر (Player)" as User
participant "Client Lua\n(client.lua)" as CL
participant "Server Lua\n(server.lua)" as SL
participant "CEF Browser\n(Chromium)" as CEF
participant "JS Engine\n(script.js)" as JS

User -> CL: فشردن کلید [TAB]
activate CL

CL -> CL: بررسی کول‌داون (now - lastRequestTime > 1500ms)
alt زمان سپری شده مجاز است
    CL -> SL: triggerServerEvent("scoreboard:requestSync")
    activate SL
    SL -> SL: تحلیل وضعیت شهردار و ارگان‌ها
    SL -> SL: مرتب‌سازی داده‌ها (شهردار در صدر)
    SL --> CL: triggerClientEvent("scoreboard:receiveSync", payload)
    deactivate SL
    CL -> JS: executeBrowserJavascript("renderData(...)")
    activate JS
    JS -> JS: ایمن‌سازی متون (Anti-XSS escapeText)
    JS -> CEF: به‌روزرسانی DOM و استایل‌ها
    deactivate JS
end

CL -> JS: executeBrowserJavascript("toggleView(true)")
JS -> CEF: اضافه کردن کلاس CSS "show"

User -> CL: اسکرول چرخ ماوس (Mouse Wheel Down)
CL -> JS: executeBrowserJavascript("scrollList(70)")
JS -> CEF: افزایش scrollTop اسکرول‌بار جدول

User -> CL: رها کردن کلید [TAB]
CL -> JS: executeBrowserJavascript("toggleView(false)")
JS -> CEF: حذف کلاس CSS "show" (پنهان‌سازی)
deactivate CL
@enduml
```

---

### ۳. فلوچارت پردازش داده و فیلترینگ سرور (Activity Diagram)
![3](image-2.png)
> **زاویه دید:** الگوریتم منطقی سرور برای تفکیک شهردار، شمارش ارگان‌های وظیفه و چیدمان رتبه‌ها.

```plantuml
@startuml
!theme blueprint
start
:دریافت سیگنال "scoreboard:requestSync" از کلاینت;
:شمارش کل بازیکنان و پدها (NPCs/Bots);
:مقداردهی اولیه شمارنده‌ها (پلیس=۰، امداد=۰، مکانیک=۰، استف=۰);

partition "حلقه پیمایش بازیکنان" {
    while (بازیکن بعدی وجود دارد؟) is (بله)
        :دریافت Serial و نام بازیکن;
        if (تطبیق با اکانت یا سریال شهردار؟) then (بله)
            :علامت‌گذاری شهردار به عنوان آنلاین (Online);
            :ثبت نشان👑 برای بازیکن;
        else (خیر)
        endif

        :بررسی فکشن و وضعیت Duty (خدمت);
        if (فکشن پلیس و در حال خدمت؟) then (بله)
            :افزایش شمارنده پلیس;
        elseif (فکشن امداد/EMS و در حال خدمت؟) then (بله)
            :افزایش شمارنده امدادگر;
        elseif (فکشن مکانیک و در حال خدمت؟) then (بله)
            :افزایش شمارنده مکانیک;
        endif

        if (سطح دسترسی ادمین > ۰؟) then (بله)
            :افزایش شمارنده Staff;
        endif

        :افزودن رکورد بازیکن به لیست نهایی;
    endwhile (خیر)
}

:مرتب‌سازی لیست:
1) شهردار در صدر لیست (Top Priority)
2) سایر بازیکنان بر اساس صعودی ID;

:تبدیل دیتا به ساختار مجاز JSON;
:ارسال پلود دیتا به کلاینت متقاضی (receiveSync);
stop
@enduml
```

---

### ۴. نمودار ماشین وضعیت رابط کاربری (State Machine Diagram)
![4](image-3.png)
> **زاویه دید:** چرخه‌ی حیات اسکوربورد روی کلاینت (تغییر از حالت پنهان به حالت موقت و حالت قفل‌شده).

```plantuml
@startuml
!theme materia-outline
scale 650 width

[*] --> Hidden : لود ریسورس (start)

state Hidden {
    Hidden : opacity: 0
    Hidden : visibility: hidden
    Hidden : کرسر ماوس غیرفعال
}

state EphemeralView {
    EphemeralView : opacity: 1
    EphemeralView : پاسخگویی به چرخ ماوس (Scroll)
    EphemeralView : کرسر ماوس پنهان (دید بازی آزاد)
}

state LockedView {
    LockedView : showCursor(true)
    LockedView : پنل قفل روی صفحه
    LockedView : اسکرول آزادانه و تعامل کامل
}

Hidden --> EphemeralView : فشردن و نگه‌داشتن کلید TAB
EphemeralView --> Hidden : رها کردن کلید TAB

Hidden --> LockedView : اجرای دستور /tab
LockedView --> Hidden : اجرای مجدد دستور /tab

EphemeralView --> LockedView : اجرای دستور /tab حین نگه‌داشتن TAB
@enduml
```

---

### ۵. ساختار و مدل داده‌های تبادلی (Class & Data Structure Diagram)
![5](image-4.png)
> **زاویه دید:** نگاشت ساختار شیء JSON ارسالی از Lua سرور به JavaScript کلاینت.

```plantuml
@startuml
!theme amiga

class ScoreboardPayload <<JSON Payload>> {
    +String mayorName
    +Boolean mayorOnline
    +Integer total
    +Integer max
    +Integer police
    +Integer medic
    +Integer mech
    +Integer staff
    +Integer bots
    +List<PlayerRecord> players
}

class PlayerRecord <<Data Transfer Object>> {
    +Variant id
    +String name
    +String role
    +Boolean isDuty
    +Integer ping
    +Boolean isMayor
}

enum PingStatusColor <<CSS Class>> {
    PING_FAST: 0-80ms (#10b981)
    PING_MED: 81-130ms (#f59e0b)
    PING_SLOW: >130ms (#ef4444)
}

enum MayorStatusStyle <<CSS Class>> {
    ONLINE: Green Border/Background
    OFFLINE: Red Border/Background
}

ScoreboardPayload "1" *-- "0..*" PlayerRecord : شامل لیست
PlayerRecord ..> PingStatusColor : محاسبه کلاس پینگ
ScoreboardPayload ..> MayorStatusStyle : ارزیابی وضعیت شهردار
@enduml
```

---

### ۶. نمودار لایه‌بندی و استقرار پشته (Deployment Diagram)
![6](image-5.png)
> **زاویه دید:** نحوه‌ی تفکیک محیط اجرایی درون سخت‌افزار سرور و سیستم کلاینت بازیکن.

```plantuml
@startuml
!theme carbon-gray
node "Client Gaming Rig" {
    artifact "Grand Theft Auto: San Andreas" as GTA
    
    node "MTA Client Core (Netcode & DX)" {
        component "client.lua (Key Hooker & Render loop)" as CLua
        
        node "Embedded Chromium Container" {
            file "index.html" as Index
            file "style.css" as Style
            file "script.js" as Script
        }
    }
}

node "MTA Dedicated Linux/Windows Server" {
    node "MTA Server Engine" {
        component "server.lua (Game Logic Sandbox)" as SLua
        database "Memory/Element Trees" as Mem
    }
}

GTA --> CLua : فراخوانی دایرکت‌ایکس
CLua --> Index : پل ارتباطی لوآ و جاوااسکریپت (CEF Bridge)
Index .. Style
Index .. Script

CLua <===> SLua : تبادل پکت‌های شبکه (UDP / RPC Network Events)
SLua <---> Mem : خواندن وضعیت‌های سنکرون‌شده
@enduml
```

---

### ۷. نمودار موارد استفاده و تعامل نقش‌ها (Use Case Diagram)
![7](image-6.png)
> **زاویه دید:** تفکیک قابلیت‌ها و ارزش ارائه‌شده برای انواع نقش‌ها (شهروند عادی، ارگان‌ها، شهردار و کادر مدیریت).

```plantuml
@startuml
!theme minty
left to right direction

actor "شهروند / پلیر عادی" as Player
actor "شهردار (Mayor)" as Mayor
actor "تیم مدیریت (Staff)" as Admin

rectangle "سامانه Web Scoreboard" {
    usecase "مشاهده حضور ارگان‌های امدادی\n(Duty Counters)" as UC_Stats
    usecase "بررسی پینگ و شناسه شهروندان\n(Ping / ID)" as UC_Ping
    usecase "اسکرول سریع لیست بازیکنان\n(Mouse Wheel)" as UC_Scroll
    usecase "بررسی وضعیت آنلاین بودن شهردار\n(Mayor Status)" as UC_MayorCheck
    usecase "قفل کردن پنل با نشانگر ماوس\n(/tab Command)" as UC_Lock
    usecase "نمایش استایل و نشان طلایی ویژه\n(Mayor Badge)" as UC_GoldMayor
    usecase "نظارت بر آمار پدها و تیم مدیریت\n(Bots & Staff Count)" as UC_AdminStat
}

Player --> UC_Stats
Player --> UC_Ping
Player --> UC_Scroll
Player --> UC_MayorCheck
Player --> UC_Lock

Mayor --|> Player
Mayor --> UC_GoldMayor

Admin --|> Player
Admin --> UC_AdminStat
@enduml
```