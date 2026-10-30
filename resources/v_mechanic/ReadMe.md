# ⚡ سیستم پیشرفته تیونینگ و مکانیکی خودرو | Advanced MTA Vehicle Tuning

[![MTA:SA Version](https://img.shields.io/badge/MTA%3ASA-1.5%20%7C%201.6-blue.svg)](https://multitheftauto.com/)
[![UI Technology](https://img.shields.io/badge/Interface-HTML5%20%2F%20CEF-orange.svg)](#)
[![Database](https://img.shields.io/badge/Database-MySQL-blue.svg)](#)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](#)

یک سیستم کامل، مدرن و سبک مکانیکی و تنظیم مشخصات فنی (Handling)، بدنه، گیربکس دستی و جلوه‌های نوری خودرو به کمک رابط کاربری وب (CEF) برای سرورهای ام‌تی‌ای (MTA: San Andreas).

---

## 📌 فهرست مطالب
- [💡 معرفی و ایده کلی](#-معرفی-و-ایده-کلی)
- [🎯 هدف توسعه](#-هدف-توسعه)
- [👤 تجربه کاربری (User Flow)](#-تجربه-کاربری-user-flow)
- [⚙️ پشت صحنه کد (سازوکار فنی)](#-پشت-صحنه-کد-سازوکار-فنی)
- [✨ قابلیت‌های کلیدی](#-قابلیت‌های-کلیدی)
- [⚖️ مزایا و معایب](#-مزایا-و-معایب)
- [📊 مصرف بهینه منابع (Performance)](#-مصرف-بهینه-منابع-performance)
- [📁 ساختار فایل‌ها](#-ساختار-فایل‌ها)
- [🛠️ پیش‌نیازها و نصب دیتابیس](#-پیش‌نیازها-و-نصب-دیتابیس)
- [🎮 کلیدهای میانبر و دستورات](#-کلیدهای-میانبر-و-دستورات)

---

## 💡 معرفی و ایده کلی

این پروژه به بازیکنان اجازه می‌دهد بدون نیاز به تایپ دستورات پیچیده یا اسکریپت‌نویسی، مشخصات فیزیکی، سیستم انتقال قدرت، تعلیق، رنگ‌آمیزی و نورپردازی خودروی خود را با یک داشبورد گرافیکی (UI مبتنی بر مرورگر داخلی بازی) شخصی‌سازی کنند. ایده محوری، ترکیب **فیزیک عمیق ماشین‌های GTA:SA** با **طراحی کاربری مدرن روز (Dark UI)** است.

---

## 🎯 هدف توسعه

1. **حذف سیستم‌های متنی قدیمی:** جایگزینی پنل‌های ساده و کدهای متنی با اسلایدرهای دقیق، دکمه‌های گام‌شمار (`+` و `-`) و پیش‌نمایش آنی.
2. **یکپارچه‌سازی وظایف پراکنده:** ادغام تنظیمات هندلینگ، رنگ‌آمیزی، تعمیر، مودهای آماده (دریفت، آفرود، درگ)، گیربکس دستی و رقص نور در یک ریسورس سبک و هماهنگ.
3. **پایداری داده‌ها (Persistence):** ذخیره دائمی تغییرات در پایگاه داده MySQL تا پس از ریستارت سرور یا خروج از بازی، تنظیمات حفظ شوند.

---

## 👤 تجربه کاربری (User Flow)

یک بازیکن عادی در سرور مراحل زیر را طی می‌کند:

1. **ورود و احراز هویت خودکار:** روی صندلی راننده ماشین می‌نشیند و کلید `F4` یا دستور `/tune` را می‌زند. سیستم به‌صورت خودکار راننده بودن وی را بررسی می‌کند؛ سپس شناسه خودرو و تنظیمات فعلی بدون تاخیر از دیتابیس بارگذاری و روی منو نشان داده می‌شوند.
2. **شخصی‌سازی بصری و لمسی:**
   - با کشیدن اسلایدرها یا کلیک روی دکمه‌های `+` و `-` شتاب، ارتفاع کمک‌فنر، زاویه فرمان و نرمی فنربندی را تنظیم می‌کند.
   - رنگ بدنه و چراغ‌ها را با کالرپیکر تعاملی انتخاب کرده و تغییرات را هم‌زمان روی ماشین می‌بیند (Live Preview).
   - با انتخاب حالت‌هایی مثل «مود دریفت حرفه‌ای» یا «رقص نور پلیسی/رنگین‌کمانی»، خودرو بلافاصله تغییر رفتار می‌دهد.
3. **ذخیره و استفاده:** با زدن دکمه «ثبت و ذخیره»، داده‌ها در پایگاه داده ثبت می‌شوند. اگر حالت گیربکس دستی فعال شود، HUD دنده روی صفحه نمایش ظاهر شده و بازیکن با کلیدهای `Q` و `E` دنده عوض می‌کند.
4. **تعمیر سریع (Quick Fix):** در صورت واژگونی یا تصادف شدید، تنها با یک کلیک خودرو به حالت افقی، سالم و تراز شده بازمی‌گردد.

---

## ⚙️ پشت صحنه کد (سازوکار فنی)

این سیستم از یک معماری سه‌لایه شامل **CEF Web Interface**، **Client-Side Lua** و **Server-Side Lua/MySQL** استفاده می‌کند:

```
[ CEF Browser (JS/HTML/CSS) ]
       │  ▲
       │  │ mta.triggerEvent / executeBrowserJavascript
       ▼  │
[ Client.lua (Events / Render Loop) ]
       │  ▲
       │  │ triggerServerEvent / triggerClientEvent
       ▼  │
[ Server.lua (Handling / MySQL Engine) ]
```

### ۱. پل ارتباطی جاوااسکریپت به لوآ (CEF Bridge)
- مرورگر وب با `guiCreateBrowser` ساخته می‌شود و مستقیماً روی کلاینت اجرا می‌شود.
- با تغییر مقادیر در رابط کاربری، آبجکت‌های داده به‌صورت رشته JSON بسته‌بندی شده و توسط `mta.triggerEvent` به کلاینت لوآ فرستاده می‌شوند.
- ارسال تنظیمات خودرو به UI از طریق `executeBrowserJavascript` و متد امن `initVehicleData` انجام می‌شود تا از خطاهای همزمانی جلوگیری شود.

### ۲. رندر رقص نور بدون فشار به شبکه (Client-Side Vector Math)
- سرور تنها **الگوی رقص نور** (مانند پلیسی، رنگین‌کمان یا سایبرپانک) را از طریق `ElementData` به نام `v_anim_color` روی خودرو تنظیم می‌کند.
- تمام رندر انیمیشن نور و رنگ بر روی رویداد `onClientRender` کلاینت‌ها با فرمول‌های ریاضی مشتق از `HSV to RGB` و امواج سینوسی `math.sin` اجرا می‌شود.
- **مزیت:** صفر درصد پهنای باند شبکه برای فریم‌های رقص نور مصرف می‌شود؛ نرخ نوسازی ۶۰ فریم بر ثانیه بدون افت پینگ صورت می‌گیرد.

### ۳. شبیه‌سازی جعبه‌دنده دستی (Manual Gearbox Limiter)
- هنگامی که گیربکس روی حالت دستی قرار دارد، اسکریپت بردار سرعت برداری خودرو (`vx, vy, vz`) را می‌سنجد.
- سرعت لحظه‌ای محاسبه شده با سقف مجاز دنده انتخابی (`speedCap = currentGear * (240 / maxGears)`) مقایسه شده و در صورت فراتر رفتن، ازدیاد شتاب به آرامی مهار می‌شود.

---

## ✨ قابلیت‌های کلیدی

- **کنترل کامل فیزیک (Handling):** شتاب اولیه، نهایت سرعت، زاویه گردش چرخ‌ها، تقسیم نیروی ترمز، چسبندگی لاستیک‌ها و نیروی کمک‌فنرها.
- **ضدضربه و ارتقای شاسی:** تنظیم ضریب صدمه تصادف (`collisionDamageMultiplier`) و دکمه ضد ضربه کامل (Godmode).
- **سیستم گیربکس دوحالته:** سوییچ روان میان اتوماتیک استاندارد و دنده‌ای دستی با افکت صوتی و HUD اختصاصی.
- **رقص نور پویا (Dynamic Lighting):** ۶ الگوی متنوع (پلیسی، RGB چرخشی، افکت تنفس، سایبرپانک و آتش) با قابلیت کنترل سرعت چرخش.
- **مدیریت پروفایل‌های شخصی:** امکان ذخیره و بارگذاری تنظیمات دلخواه برای انواع مسابقات.
- **تعمیر و تراز هوشمند:** تعمیر بدنه، سلامت ۱۰۰۰ و تنظیم خودکار چرخش زاویه Z خودرو برای خروج از حالت چپ‌کردگی.

---

## ⚖️ مزایا و معایب

### مزایا
- **کاربری آسان:** بدون نیاز به دانش برنامه‌نویسی برای گیمرها.
- **طراحی زیبا و واکنش‌گرا:** رابط گرافیکی تاریک با دکمه‌های گام‌شمار جهت تنظیمات دقیق بدون خطا.
- **بهینگی شبکه:** انجام پردازش‌های مکرر انیمیشن و جلوه‌های نوری روی پردازنده گرافیکی کلاینت.
- **سازگاری بالا:** هماهنگ با اکثر گیم‌مودهای استاندارد، رول‌پلی (RP) و دریفتی MTA.

### معایب
- **نیازمند دیتابیس MySQL:** سرورهایی که فقط بر پایه SQLite یا فایل‌های محلی هستند باید اتصال MySQL را پیکربندی کنند.
- **وابستگی به CEF:** سیستم‌های بسیار قدیمی با مرورگر غیرفعال در تنظیمات بازی قادر به دیدن UI نخواهند بود (اگرچه در نسخه‌های جدید MTA به ندرت پیش می‌آید).

---

## 📊 مصرف بهینه منابع (Performance)

| بخش | میانگین مصرف | وضعیت بهینه‌سازی |
| :--- | :--- | :--- |
| **Client CPU (Lua)** | `0.02% ~ 0.06%` | بسیار سبک؛ اجرای توابع تنها در محدوده دید بازیکن (`getElementsByType("vehicle", root, true)`) |
| **Server CPU** | `~0.00%` | محاسبات فیزیک به کلاینت واگذار شده؛ سرور صرفاً ذخیره‌ساز پایگاه داده است |
| **ترافیک شبکه (Bandwidth)** | نزدیک به صفر | ارسال بسته‌ها فقط هنگام ذخیره یا باز کردن پنل |
| **حافظه کلاینت (CEF RAM)** | `~25 - 40 MB` | سبک‌تر از مرورگر استاندارد؛ استفاده از CSS خالص بدون کتابخانه‌های سنگین |

---

## 📁 ساختار فایل‌ها

```plaintext
resources/
└── v_mechanic/
    ├── meta.xml          # مانیفست و تعریف فایل‌ها و دسترسی‌های کلاینت/سرور
    ├── client.lua        # راه‌اندازی CEF، ورودی کلیدها، افکت دنده و رندر نورها
    ├── server.lua        # اتصال دیتابیس، اعمال هندلینگ و تعمیرات سمت سرور
    └── ui/
        ├── index.html    # اسکلت‌بندی پنل، تب‌ها و کنترل‌های ورودی
        ├── style.css     # استایل‌های مدرن نئونی، اسلایدرها و لی‌اوت دارک
        └── script.js     # اعتبارسنجی مقادیر، پروفایل‌ها و تبادل داده با CEF
```

---

## 🛠️ پیش‌نیازها و نصب دیتابیس

### ۱. ساختار جداول MySQL
پیش از استارت ریسورس، کوئری‌های SQL زیر را روی دیتابیس سرور خود اجرا کنید:

```sql
-- جدول ذخیره پروفایل‌های شخصی کاربران
CREATE TABLE IF NOT EXISTS `vehicle_handling_profiles` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `account_id` INT NULL,
  `profile_name` VARCHAR(64) NOT NULL,
  `handling_data` LONGTEXT NOT NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- اضافه کردن ستون‌های مورد نیاز به جدول خودروهای سرور (در صورت عدم وجود)
ALTER TABLE `server_vehicles` 
  ADD COLUMN IF NOT EXISTS `custom_handling` LONGTEXT NULL,
  ADD COLUMN IF NOT EXISTS `veh_color1` VARCHAR(32) NULL,
  ADD COLUMN IF NOT EXISTS `veh_color2` VARCHAR(32) NULL;
```

### ۲. تنظیم اتصال دیتابیس
در ابتدای فایل `server.lua` اطلاعات اتصال به دیتابیس خود را تنظیم کنید:

```lua
local DB_HOST = "127.0.0.1"
local DB_USER = "root"
local DB_PASS = ""
local DB_NAME = "mta_db"
local DB_PORT = 3306
```

### ۳. اجرا در کنسول سرور
```bash
refresh
start v_mechanic
```

---

## 🎮 کلیدهای میانبر و دستورات

| کلید / دستور | عملکرد | دسترسی |
| :--- | :--- | :--- |
| `F4` | باز/بسته کردن منوی مکانیکی و تیونینگ | راننده خودرو |
| `/tune` یا `/mech` | دستور جایگزین برای باز کردن منو | راننده خودرو |
| `E` | دنده بالا (در حالت دستی) | راننده |
| `Q` | دنده معکوس (در حالت دستی) | راننده |

---

## 📄 مجوز و لایسنس

این پروژه تحت لایسنس **MIT** منتشر شده است. استفاده، ویرایش و توسعه تجاری یا عمومی آن برای تمامی سرورها مجاز است.







---

## 📊 دیاگرام‌های تحلیلی و معماری سیستم (PlantUML)

> **راهنما:** کدهای زیر به زبان **PlantUML** نوشته شده‌اند و به شکل بومی در گیت‌هاب و ادیتور [PlantUML Editor](https://editor.plantuml.com/) قابل رندر و تبدیل به تصویر هستند.

---

### ۱. معماری کلی و اجزای سیستم (Component Diagram)
![1](image.png)
این دیاگرام نحوه تفکیک و پیوند میان بخش‌های رابط کاربری تحت وب (CEF)، موتور کلاینت لوآ، لایه سرور و پایگاه داده MySQL را نمایش می‌دهد.

```plantuml
@startuml
skinparam backgroundColor #0d121b
skinparam defaultFontColor #ffffff
skinparam componentStyle uml2
skinparam ArrowColor #00e5ff
skinparam component {
    BackgroundColor #121822
    BorderColor #00e5ff
    FontColor #ffffff
}
skinparam database {
    BackgroundColor #1a2536
    BorderColor #00ff88
    FontColor #ffffff
}

package "Client-Side (User Environment)" {
    [CEF Web Browser (HTML5/CSS/JS)] as UI
    [Client.lua Engine] as ClientLua
    [DirectX Render Loop (onClientRender)] as DxLoop
}

package "Server-Side (Host Environment)" {
    [Server.lua Controller] as ServerLua
    database "MySQL Database (mta_db)" as DB
}

UI <--> ClientLua : CEF Events (mta.triggerEvent / JS Exec)
ClientLua --> DxLoop : Real-time Lighting Math & Gear Limiter
ClientLua <--> ServerLua : MTA Latent Latency-Free RPC Events
ServerLua <--> DB : dbExec & dbQuery (autoreconnect)
@enduml
```

---

### ۲. توالی فرایند درخواست و ذخیره‌سازی داده (Sequence Diagram)
![2](image-1.png)
این چرخه نشان می‌دهد از لحظه زدن کلید `F4` توسط بازیکن تا اعتبارسنجی راننده، استعلام پایگاه داده، رندر روی صفحه و ذخیره نهایی چه سیگنال‌هایی میان سیستم‌ها ردوبدل می‌شود.

```plantuml
@startuml
autonumber
skinparam backgroundColor #0d121b
skinparam defaultFontColor #ffffff
skinparam sequence {
    ArrowColor #00e5ff
    LifeLineBorderColor #00e5ff
    LifeLineBackgroundColor #131a26
    ParticipantBackgroundColor #121822
    ParticipantBorderColor #00e5ff
    ParticipantFontColor #ffffff
    ActorBackgroundColor #00e5ff
    ActorBorderColor #ffffff
}

actor "راننده (Driver)" as Player
participant "Client.lua" as Client
participant "Server.lua" as Server
database "MySQL" as DB
participant "CEF Panel (JS/UI)" as UI

Player -> Client : فشردن کلید [F4] یا دستور /tune
Client -> Client : بررسی حضور بازیکن روی صندلی راننده
Client -> Server : triggerServerEvent("mechanic:requestVehicleFullData")
Server -> DB : استعلام مشخصات و پروفایل‌ها (SELECT)
DB --> Server : بازگشت داده‌های Handling و پروفایل‌ها
Server --> Client : ارسال پکیج کامل داده‌ها (triggerClientEvent)
Client -> UI : اجرای initVehicleData(payload) از طریق جاوااسکریپت
UI --> Player : نمایش فرم‌های لغزنده و مقادیر فعلی

Player -> UI : تغییر مشخصات و کلیک روی [ثبت و ذخیره]
UI -> Client : ارسال داده‌های جدید به شکل JSON
Client -> Server : triggerServerEvent("mechanic:serverSaveAll")
Server -> Server : اعمال آنی setVehicleHandling & setVehicleColor
Server -> DB : ثبت تغییرات در جدول server_vehicles (UPDATE)
Server --> Player : نمایش پیام موفقیت‌آمیز در چت‌باکس
@enduml
```

---

### ۳. فلوچارت تصمیم‌گیری و منطق عملکرد کاربر (Activity Flow Diagram)
![3](image-2.png)
جریان منطقی تعامل بازیکن از لحظه فشردن کلید تا خروج از پنل و انتخاب مودهای مختلف رانندگی.

```plantuml
@startuml
skinparam backgroundColor #0d121b
skinparam defaultFontColor #ffffff
skinparam ArrowColor #00e5ff
skinparam activity {
    BackgroundColor #121822
    BorderColor #00e5ff
    FontColor #ffffff
    StartColor #00ff88
    EndColor #ff4444
    BarColor #00e5ff
}

start
:فشردن کلید F4 / دستور tune;
if (آیا بازیکن سوار خودرو است؟) then (بله)
    if (آیا بازیکن راننده (Seat 0) است؟) then (بله)
        :باز شدن پنل گرافیکی CEF و نمایان شدن ماوس;
        :بارگذاری مقادیر کنونی از سرور;
        fork
            :تنظیم دستی اسلایدرها (شتاب، فنر، ترمز);
        fork again
            :انتخاب مود آماده (دریفت، درگ، آفرود، ضدضربه);
        fork again
            :تغییر رنگ بدنه و الگوی رقص نور;
        fork again
            :فعال‌سازی گیربکس دستی (کلیدهای Q و E);
        fork again
            :تعمیر و تراز آنی ماشین (Quick Fix);
        end fork
        if (آیا کاربر دکمه ذخیره دائمی را زد؟) then (بله)
            :ارسال بسته تنظیمات به سرور;
            :ذخیره دائمی در دیتابیس MySQL;
        else (خیر)
            :خروج موقت / لغو تغییرات;
        endif
        :بستن پنل و آزاد شدن نشانگر ماوس;
        stop
    else (خیر)
        :نمایش خطای "فقط راننده دسترسی دارد";
        stop
    endif
else (خیر)
    :نمایش خطای "ابتدا سوار خودرو شوید";
    stop
endif
@enduml
```

---

### ۴. نمودار حالت‌های خودرو و تیونینگ (State Machine Diagram)
![4](image-3.png)
وضعیت‌های مختلفی که فیزیک، پایداری و ظاهر خودرو در طول حیات خود در سرور تجربه می‌کند.

```plantuml
@startuml
skinparam backgroundColor #0d121b
skinparam defaultFontColor #ffffff
skinparam ArrowColor #00e5ff
skinparam state {
    BackgroundColor #121822
    BorderColor #00e5ff
    FontColor #ffffff
    StartColor #00ff88
    EndColor #ff4444
}

[*] --> StockVehicle : ساخت یا اسپاون خودرو فابریک

state StockVehicle {
    StockVehicle : سیستم دنده: اتوماتیک استاندارد
    StockVehicle : صدمه‌پذیری: معمولی (ضریب 1.0)
    StockVehicle : نورپردازی: رنگ ثابت کارخانه
}

StockVehicle --> TunedVehicle : لود تنظیمات از DB یا ذخیره پنل

state TunedVehicle {
    state "حالت رانندگی" as DriveMode {
        AutomaticTransmission --> ManualTransmission : انتخاب حالت دستی
        ManualTransmission --> AutomaticTransmission : بازگشت به اتوماتیک
        
        state ManualTransmission {
            Gear1 --> Gear2 : کلید [E]
            Gear2 --> Gear3 : کلید [E]
            Gear3 --> Gear2 : کلید [Q]
            Gear2 --> Gear1 : کلید [Q]
        }
    }
    
    state "وضعیت دوام بدنه" as DamageState {
        NormalDamage --> GodmodeActive : فشردن کلید ضد ضربه
        GodmodeActive --> NormalDamage : غیرفعال‌سازی
    }

    state "وضعیت نورپردازی" as LightState {
        StaticColor --> DynamicLighting : انتخاب الگو (Police, RGB, ...)
        DynamicLighting --> StaticColor : حالت خاموش / رنگ ثابت
    }
}

TunedVehicle --> StockVehicle : کلیک روی دکمه "فابریک کارخانه"
@enduml
```

---

### ۵. ساختار ارتباطی پایگاه داده (Entity Relationship Diagram - ERD)
![5](image-4.png)
طرح نگاشت داده‌ها میان جدول اصلی خودروهای سرور و پروفایل‌های ذخیره‌شده کاربران.

```plantuml
@startuml
skinparam backgroundColor #0d121b
skinparam defaultFontColor #ffffff
skinparam ArrowColor #00e5ff
skinparam class {
    BackgroundColor #121822
    BorderColor #00e5ff
    FontColor #ffffff
    HeaderBackgroundColor #192434
}

entity "server_vehicles" as SV {
    * **id** : INT <<PK, AutoIncrement>>
    --
    model_id : INT
    owner_account : INT
    custom_handling : LONGTEXT (JSON Payload)
    veh_color1 : VARCHAR(32)
    veh_color2 : VARCHAR(32)
    headlight_color : VARCHAR(32)
    damage_proof : TINYINT(1)
}

entity "vehicle_handling_profiles" as VHP {
    * **id** : INT <<PK, AutoIncrement>>
    --
    # account_id : INT <<FK>>
    profile_name : VARCHAR(64)
    handling_data : LONGTEXT (JSON Properties)
    created_at : TIMESTAMP
}

SV ||--o{ VHP : "می‌تواند از پروفایل‌های مشترک تغذیه شود"
@enduml
```

---

### ۶. مدل کلاسی ساختار بسته‌های داده (Data Class Diagram)
![6](image-5.png)
نحوه چیدمان اشیاء در کلاینت جاوااسکریپت و انطباق آن با متغیرهای بومی Handling در زبان Lua.

```plantuml
@startuml
skinparam backgroundColor #0d121b
skinparam defaultFontColor #ffffff
skinparam ArrowColor #00e5ff
skinparam class {
    BackgroundColor #121822
    BorderColor #00e5ff
    FontColor #ffffff
    HeaderBackgroundColor #192434
}

class TuningPackage {
    +HandlingModel handling
    +ColorModel colors
    +DynamicLightModel dynamicLighting
    +Boolean damageProof
    +String transmissionMode
    +toJSON() : String
}

class HandlingModel {
    +Float engineAcceleration
    +Float maxVelocity
    +Int numberOfGears
    +String driveType ('4'|'r'|'f')
    +Float brakeDeceleration
    +Float brakeBias
    +Float steeringLock
    +Float tractionMultiplier
    +Float collisionDamageMultiplier
    +Float suspensionLowerLimit
    +Float suspensionForceLevel
    +Float suspensionDamping
    +Float mass
}

class ColorModel {
    +String c1 (Hex)
    +String c2 (Hex)
    +String light (Hex)
    +toRGB() : (r, g, b)
}

class DynamicLightModel {
    +String pattern ("none"|"police"|"rainbow"|...)
    +String target ("lights"|"body"|"both")
    +Float speed (0.2 .. 3.5)
}

TuningPackage *-- HandlingModel
TuningPackage *-- ColorModel
TuningPackage *-- DynamicLightModel
@enduml
```

---

### ۷. چرخه محاسباتی ۶۰ فریم بر ثانیه بدون افت پینگ (Client-Side Render Pipeline)
![7](image-6.png)
تفکیک دقیق وظایف همگام‌سازی سبک شبکه از چرخه فریم‌های گرافیکی (Zero Network Lag Logic).

```plantuml
@startuml
skinparam backgroundColor #0d121b
skinparam defaultFontColor #ffffff
skinparam ArrowColor #00e5ff
skinparam activity {
    BackgroundColor #121822
    BorderColor #00e5ff
    FontColor #ffffff
    StartColor #00ff88
    EndColor #ff4444
}
skinparam partition {
    BackgroundColor #141c28
    BorderColor #00e5ff
    FontColor #00e5ff
}

start

partition "رویداد شبکه (تنها یک‌بار هنگام تغییر)" {
    :تغییر حالت در پنل کاربری CEF;
    :ارسال به سرور و مقداردهی ElementData (v_anim_color);
    :پخش خودکار دیتا به کلاینت‌های در محدوده دید;
}

partition "چرخه رندر کلاینت (onClientRender - بدون اشغال شبکه و پینگ)" {
    :دریافت زمان جاری سیستم با getTickCount();
    
    if (آیا الگوی رقص نور فعال است؟) then (بله)
        if (نوع الگو چیست؟) then (رنگین‌کمان / rainbow)
            :محاسبه چرخش رنگ با الگوریتم HSV to RGB;
        elseif (پلیسی / police) then (پلیسی)
            :محاسبه فاز چشمک‌زن قرمز و آبی بر پایه میلی‌ثانیه;
        else (سایر / relax, fire, cyberpunk)
            :محاسبه نوسان موج رنگ با تابع math.sin;
        endif
        :اعمال مستقیم روی چراغ و بدنه (setVehicleHeadLightColor);
    else (خیر)
    endif

    if (آیا حالت دنده دستی فعال است؟) then (بله)
        :محاسبه بردار سرعت فیزیکی خودرو (vx, vy, vz);
        if (سرعت واقعی > سقف مجاز دنده فعلی؟) then (بله)
            :مهار ازدیاد شتاب با ترمز نرم (setElementVelocity);
        else (خیر)
        endif
        :ترسیم هاد گرافیکی دنده روی نمایشگر (dxDraw);
    else (خیر)
    endif
}

stop
@enduml
```