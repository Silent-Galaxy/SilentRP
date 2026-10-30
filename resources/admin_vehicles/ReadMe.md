# 🚗 سیستم هوشمند مدیریت وسایل نقلیه سرور (Admin Vehicles Manager)

[![MTA:SA](https://img.shields.io/badge/MTA%3ASA-Resource-blue.svg)](https://multitheftauto.com/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)]()
[![Lua](https://img.shields.io/badge/Language-Lua-000080.svg)](https://www.lua.org/)
[![UI](https://img.shields.io/badge/UI-CEF%20%7C%20HTML5%2FJS-orange.svg)]()

یک ابزار مدرن، گرافیکی و تعاملی تحت وب (CEF) برای ادمین‌های سرور MTA:SA جهت اسپاون، پارک دائمی در دیتابیس MySQL، ردیابی زنده و مدیریت هوشمند ناوگان نقلیه بدون ایجاد تداخل و انفجار فیزیکی.

---

## 📌 فهرست مطالب
- [💡 ایده چیست و چرا خلق شد؟](#-ایده-چیست-و-چرا-خلق-شد)
- [🎯 هدف توسعه‌دهنده](#-هدف-توسعهدهنده)
- [⚖️ بررسی مزایا و معایب](#️-بررسی-مزایا-و-معایب)
- [🔄 فرایند و تجربه کاربری (User Flow)](#-فرایند-و-تجربه-کاربری-user-flow)
- [⚙️ پشت کد چه می‌گذرد؟ (Behind The Code)](#️-پشت-کد-چه-میگذرد-behind-the-code)
- [📂 ساختار پروژه](#-ساختار-پروژه)
- [🚀 راه‌اندازی و نیازمندی‌ها](#-راه‌اندازی-و-نیازمندیها)
- [🎮 کلیدها و دستورات](#-کلیدها-و-دستورات)

---

## 💡 ایده چیست و چرا خلق شد؟
در سرورهای MTA، مدیریت خودروهای ثابت سرور (مثل ماشین‌های فکشن، تاکسی‌ها، اورژانس و خودروهای عمومی) معمولاً با دستورات متنی خسته‌کننده چت، ثبت دستی مختصات در کد و مشکلات رایجی نظیر اسپاون چندباره روی یکدیگر و **انفجار خودروها هنگام ریستارت سرور** همراه است.

این ایده پدید آمد تا یک پنل تماماً گرافیکی مدرن (Glassmorphism Web UI) جایگزین روش‌های سنتی شود؛ به‌طوری‌که ادمین در محیطی بصری خودرو را بسازد، تست کند و با یک کلیک در موقعیت دقیق فعلی، دائمی‌سازی کند.

---

## 🎯 هدف توسعه‌دهنده
1. **حذف خطای انسانی:** عدم نیاز به تایپ دستی مختصات `X, Y, Z, Rotation` در دیتابیس یا فایل Lua.
2. **پیشگیری از انفجار خودروها:** مکانیزم هوشمند بررسی خودروهای موجود برای جلوگیری از اسپاون تکراری روی یک نقطه.
3. **سرعت عملیات ادمینی:** ردیابی، ریست، تله‌پورت و حذف فوری خودروها بدون نیاز به دسترسی مستقیم به phpMyAdmin.
4. **طراحی مدرن:** بهره‌گیری از Chromium Embedded Framework (CEF) به جای رابط‌های کاربری قدیمی GUI/DX.

---

## ⚖️ بررسی مزایا و معایب

### ✅ مزایا
- **هوشمندسازی جلوگیری از تصادف اسپاون:** قبل از ساخت خودرو در لود مجدد، محدوده ۲ متری و ID دیتابیس بررسی می‌شود تا خودرویی روی خودروی دیگر منفجر نشود.
- **ثبت زنده وضعیت:** تشخیص اتوماتیک اینکه ادمین هم‌اکنون سوار چه خودرویی است و آیا این خودرو موقت است یا در دیتابیس ثبت شده.
- **ابزارهای ناوبری هوایی و زمینی:** قابلیت نمایش مارکر نئونی پیکان روی سقف خودرو همراه با Blip اختصاصی در مینی‌مپ برای پیدا کردن خودروهای گمشده.
- **طراحی سبک و ریسپانسیو:** پنل وب با فونت استاندارد، پشتیبانی کامل از زبان فارسی و راست‌چین (RTL).

### ❌ معایب
- وابستگی کامل به ساختار جدول استاندارد دیتابیس MySQL.
- نیاز به رندر موتور CEF در کلاینت (کلاینت‌های با سیستم‌های بسیار ضعیف ممکن است تأخیر جزئی در باز شدن پنجره داشته باشند).

---

## 🔄 فرایند و تجربه کاربری (User Flow)

کاربر دارای سطح دسترسی ادمین روند کاری زیر را طی می‌کند:

1. **فشردن کلید F6 یا دستور `/vehpanel`:** پنل گرافیکی بلوری تیره با رنگ‌بندی نئونی باز می‌شود و مکان‌نمای ماوس فعال می‌گردد.
2. **ورود به تب "اسپاون ماشین جدید":** انتخاب مدل دلخواه از لیست سریع (پژو، پراید، پلیس، آمبولانس و...) با یک کلیک.
3. **رانندگی تا مقصد:** ماشین بلافاصله زیر پای ادمین اسپاون شده و ادمین مستقیماً پشت فرمان قرار می‌گیرد و به مکان مورد نظر برای پارک رانندگی می‌کند.
4. **ثبت پارک با یک کلیک:** بالای پنل به‌صورت خودکار پیام `سوار ... هستید (موقت)` تغییر می‌کند. ادمین روی دکمه سبز رنگ **«💾 ثبت دائمی خودرو در همین نقطه»** کلیک می‌کند.
5. **مدیریت از تب "ماشین‌های فعال":** خودرو با یک شناسه یکتا ثبت شده و عملیات ۴ گانه زیر روی آن فعال می‌شود:
   - 🎯 **فلش:** پرتاب نور نئونی بالای سقف و علامت روی نقشه برای مکان‌یابی.
   - 🚀 **تلپورت:** انتقال سریع ادمین به خودرو.
   - 🔄 **ریست:** برگرداندن خودرو به نقطه پارکی که ثبت شده بود (در صورت واژگونی یا جابجایی).
   - 🗑️ **حذف:** نابودی فیزیکی خودرو و پاک شدن دائمی رکورد آن از دیتابیس MySQL.

---

## ⚙️ پشت کد چه می‌گذرد؟ (Behind The Code)

```
[ HTML5 UI (JS Event) ] 
         │ (mta.triggerEvent)
         ▼
[ Client (client.lua) ] 
         │ (triggerServerEvent)
         ▼
[ Server (server.lua) ] ───► [ MySQL Database ]
         │ (Sync & Spawn)
         ▼
[ GTA Game World Elements ]
```

1. **مدیریت ناهمگام دیتابیس:** کلیه استعلام‌ها از طریق `dbQuery` و `dbPoll` به شکل Non-blocking پردازش می‌شوند تا لگ در سرور ایجاد نشود.
2. **تکنیک ضد انفجار (Anti-Stack Check):**
   هنگام اجرای فانکشن `loadAllVehicles`، اسکریپت با `getElementsByType("vehicle")` بررسی می‌کند که آیا این شناسه دیتابیسی از قبل در نقشه وجود دارد یا فاصله‌ای کمتر از `2.0` متر با نقطه پارک ثبت‌شده دارد یا خیر؛ اگر بله، مشخصات خودروی حاضر همگام‌سازی می‌شود و آبجکت جدید ساخته نمی‌شود.
3. **انتقال دوجانبه داده (JSON Bridge):** اطلاعات خودروها سمت سرور به JSON فشرده تبدیل شده و از طریق `executeBrowserJavascript` به فانکشن `updatePanelData` در مرورگر تحویل داده می‌شود.

---

## 📂 ساختار پروژه

```bash
resources/admin_vehicles/
├── meta.xml           # پیکربندی ریسورس، بارگذاری اسکریپت‌ها و فایل وب
├── server.lua         # منطق پایگاه داده، اسپاون، همگام‌سازی و اعتبارسنجی ادمین
├── client.lua         # هندلر مرورگر اینترنال (CEF)، بایند کلید و پل ارتباطی سرور/وب
├── ui/
│   └── index.html     # رابط کاربری با ظاهر Glassmorphism، استایل CSS و کدهای JS
└── ReadMe.md          # مستندات کامل پروژه
```

---

## 🚀 راه‌اندازی و نیازمندی‌ها

### ۱. پیش‌نیاز دیتابیس
در فایل `server.lua` خط اول، اطلاعات دیتابیس خود را تنظیم کنید:
```lua
local db = dbConnect("mysql", "dbname=نام_دیتابیس;host=127.0.0.1;port=3306;charset=utf8mb4", "نام_کاربری", "رمز_عبور")
```
> **نکته:** ساختار جدول `server_vehicles` به‌صورت اتوماتیک در اولین اجرا در دیتابیس ساخته می‌شود (`CREATE TABLE IF NOT EXISTS`).

### ۲. تعریف دسترسی ادمین
سیستم به‌طور پیش‌فرض از جدول `accounts` ستون `admin_level` یا گروه ACL موسوم به `Admin` تبعیت می‌کند. مقدار دسترسی مجاز ادمین `>= 0` تعریف شده است.

### ۳. نصب ریسورس
1. پوشه را با نام `admin_vehicles` در مسیر `server/mods/deathmatch/resources/` قرار دهید.
2. کنسول سرور را باز کرده و دستورات زیر را وارد کنید:
   ```bash
   refresh
   start admin_vehicles
   ```

---

## 🎮 کلیدها و دستورات

| دستور / کلید | نقش |
| :--- | :--- |
| **`F6`** | باز و بسته کردن پنل مدیریت وب |
| **`/vehpanel`** | دستور متنی معادل برای باز کردن پنل |
| **`/park`** | دستور سریع متنی برای ثبت آنی مکان پارک خودرویی که سوار آن هستید |

---
**توسعه داده شده برای بهبود کیفیت و سرعت ادمینی در سرورهای ام‌تی‌ای.**








---

## 📊 دیاگرام‌های معماری، جریان داده و تجربه کاربری (PlantUML)

---

### ۱. معماری کلی سیستم و روابط فایل‌ها (Component Architecture)
![alt text](image.png)
> **توضیح:** این دیاگرام نحوه ارتباط فایل‌های پروژه از لایه مرورگر کلاینت تا هسته سرور و پایگاه‌داده MySQL را نشان می‌دهد. فایل `meta.xml` نقطه ورود است که وظیفه تزریق رابط کاربری و اسکریپت‌ها به محیط کلاینت و سرور را برعهده دارد.

```plantuml
@startuml
!theme plain
skinparam backgroundColor #0E121E
skinparam ArrowColor #00FFCC
skinparam ComponentBorderColor #00FFCC
skinparam ComponentBackgroundColor #1E293B
skinparam ComponentFontColor #FFFFFF
skinparam DatabaseBackgroundColor #1E293B
skinparam DatabaseBorderColor #00FFCC
skinparam DatabaseFontColor #FFFFFF

package "Client Environment (MTA Client)" {
    [meta.xml] ..> [ui/index.html] : بارگذاری در مرورگر CEF
    [meta.xml] ..> [client.lua] : اجرای اسکریپت کلاینت
    [ui/index.html] <--> [client.lua] : ارتباط مستقیم (JS / Lua Bridge)
}

package "Server Environment (MTA Server)" {
    [meta.xml] ..> [server.lua] : بارگذاری منطق سرور
    [client.lua] <..> [server.lua] : تبادل رویدادها (triggerServerEvent / triggerClientEvent)
    database "MySQL Database\n(server_vehicles)" as DB
    [server.lua] <--> DB : ذخیره، خواندن و حذف ناهمگام (dbExec / dbQuery)
    [server.lua] --> [Game World Elements] : ساخت و مدیریت خودروها (createVehicle)
}
@enduml
```

---

### ۲. نقشه سفر ادمین و جریان بصری (Admin Journey & Screen Flow)
![alt text](image-1.png)
> **توضیح:** زاویه دید ادمین از لحظه فشردن کلید تا انتخاب خودرو، رانندگی به سمت محل پارک، فشردن دکمه ثبت و مدیریت نهایی را به تصویر می‌کشد.

```plantuml
@startuml
!theme plain
skinparam backgroundColor #0E121E
skinparam ActivityBackgroundColor #1E293B
skinparam ActivityBorderColor #00FFCC
skinparam ActivityFontColor #FFFFFF
skinparam ArrowColor #00FFCC

start
:فشردن کلید F6 یا دستور /vehpanel;
:باز شدن پنل شیشه‌ای نئونی (CEF);

if (ادمین پیاده است یا سوار ماشین؟) then (پیاده)
    :ورود به تب "اسپاون ماشین جدید";
    :انتخاب مدل و کلیک روی دکمه "اسپاون";
    :انتقال خودکار ادمین پشت فرمان خودرو;
else (سوار ماشین)
    :شناسایی آنی مدل و وضعیت خودرو در بالای پنل;
endif

:رانندگی به محل دلخواه برای پارک دائمی;
:کلیک روی دکمه سبز رنگ "ثبت موقعیت پارک";
:ثبت مختصات در دیتابیس و نمایش شناسه خودرو (#ID);

fork
    :🎯 ارسال فلش روی سقف و علامت نقشه;
fork again
    :🚀 تلپورت در مواقع نیاز;
fork again
    :🔄 بازگردانی موقعیت (ریست پارک);
fork again
    :🗑️ حذف دائمی از نقشه و دیتابیس;
end fork

stop
@enduml
```

---

### ۳. دیاگرام توالی اسپاون و پارک دائمی (Sequence: Spawn & Save)
![alt text](image-2.png)
> **توضیح:** این دیاگرام چرخه تعاملی بین پنل تحت وب، اسکریپت کلاینت، اسکریپت سرور، دیتابیس و هسته بازی را در فرایند ساخت خودرو تا ذخیره‌سازی ابدی در دیتابیس نمایش می‌دهد.

```plantuml
@startuml
!theme plain
autonumber
skinparam backgroundColor #0E121E
skinparam ParticipantBorderColor #00FFCC
skinparam ParticipantBackgroundColor #1E293B
skinparam ParticipantFontColor #FFFFFF
skinparam ArrowColor #00FFCC
skinparam SequenceLifeLineBorderColor #00FFCC
skinparam SequenceGroupBackgroundColor #141B2D
skinparam SequenceGroupBorderColor #00FFCC
skinparam SequenceGroupFontColor #FFFFFF

actor "Admin" as Admin
participant "Web UI (JS)" as UI
participant "Client Lua" as Client
participant "Server Lua" as Server
database "MySQL" as DB
participant "Game Engine" as Engine

Admin -> UI : کلیک روی دکمه اسپاون مدل
UI -> Client : triggerMTA('onWebSpawnNew', id)
Client -> Server : triggerServerEvent("onAdminCreatePermanentVehicle")
Server -> Engine : createVehicle() & warpPlayerIntoVehicle()
Engine --> Admin : ادمین بلافاصله سوار خودرو می‌شود

Admin -> UI : کلیک روی دکمه "ثبت موقعیت پارک"
UI -> Client : triggerMTA('onWebSaveCurrentCar')
Client -> Server : triggerServerEvent("onAdminSaveCurrentOccupiedVehicle")

Server -> DB : INSERT INTO server_vehicles (coords, model)
DB --> Server : Return insertId
Server -> Engine : setVehicleRespawnPosition()
Server -> Client : triggerClientEvent("receiveSavedVehiclesList", list)
Client -> UI : executeBrowserJavascript(updatePanelData)
UI --> Admin : نمایش خودرو در لیست به همراه شناسه یکتا (#ID)
@enduml
```

---

### ۴. فلوچارت الگوریتم هوشمند ضد انفجار (Anti-Stack & Smart Sync)
![alt text](image-3.png)
> **توضیح:** هسته حیاتی پشت سرور! هنگام استارت سرور یا ریسورس، سیستم ابتدا دنیای بازی را اسکن می‌کند تا از ساخت خودروهای تکراری روی هم که منجر به پرتاب و انفجار آن‌ها می‌شود، جلوگیری کند.

```plantuml
@startuml
!theme plain
skinparam backgroundColor #0E121E
skinparam ActivityBackgroundColor #1E293B
skinparam ActivityBorderColor #00FFCC
skinparam ActivityFontColor #FFFFFF
skinparam ArrowColor #00FFCC
skinparam ConditionFontColor #FFFFFF

start
:رویداد onResourceStart / بارگذاری لیست دیتابیس;
:دریافت رکوردهای جدول `server_vehicles`;

while (آیا رکورد دیگری در جدول وجود دارد؟) is (بله)
    :خواندن مختصات (X, Y, Z) و ID دیتابیس;
    :اسکن خودروهای موجود در سرور (getElementsByType);
    
    if (خودرویی با این DBID یا در فاصله کمتر از 2.0 متر وجود دارد؟) then (بله - وجود دارد)
        :ارتقا و متصل‌کردن خودروی حاضر (Smart Sync);
        :تخصیص مجدد ElementData و بدون دست‌کاری آبجکت;
        note right: مانع از اسپاون مجدد و ترکیدن خودروها
    else (خیر - موجود نیست)
        :ساخت خودروی جدید با createVehicle();
        :تنظیم موقعیت ریسپاون خودکار;
        :ثبت ElementData (شناسه، تاریخ و وضعیت دائمی);
    endif
endwhile (خیر)

:پایان فرایند و آماده‌سازی پنل;
stop
@enduml
```

---

### ۵. مسیر تبادل داده و ارتباط دوطرفه (Full-Duplex Data Bus)
![alt text](image-4.png)
> **توضیح:** این دیاگرام نحوه تبدیل داده‌ها را نمایش می‌دهد: چطور اطلاعات دیتابیس سرور به صورت ساختار JSON فشرده شده و بدون افت فریم توسط وب‌ویو رندر می‌شود.

```plantuml
@startuml
!theme plain
skinparam backgroundColor #0E121E
skinparam RectangleBorderColor #00FFCC
skinparam RectangleBackgroundColor #1E293B
skinparam RectangleFontColor #FFFFFF
skinparam ArrowColor #00FFCC

rectangle "1. Web Layer\n(HTML5 DOM)" as Web {
    card "دکمه‌های UI و رویدادها\n(onclick, JS Events)" as W1
    card "تابع رندر مجدد\nupdatePanelData(cars, current)" as W2
}

rectangle "2. Client Lua Layer\n(Internal Browser Engine)" as Client {
    card "دریافت از وب با\naddEvent / triggerMTA" as C1
    card "تزریق مستقیم جاوااسکریپت\nexecuteBrowserJavascript" as C2
}

rectangle "3. Server Lua Layer\n(Network & Logic)" as Server {
    card "دریافت تقاضا و واکشی\n(dbQuery & dbPoll)" as S1
    card "تبدیل داده به رشته امن\ntoJSON(list, true)" as S2
}

database "MySQL Database" as DB

W1 -down-> C1 : Event Handlers
C1 -down-> S1 : triggerServerEvent
S1 -down-> DB : SELECT / UPDATE
DB -up-> S2 : Query Results
S2 -up-> C2 : triggerClientEvent
C2 -up-> W2 : Browser DOM Execution
@enduml
```

---

### ۶. دیاگرام وضعیت عملیات ادمینی روی وسایل نقلیه (Vehicle States & Actions)
![alt text](image-5.png)
> **توضیح:** نشان‌دهنده چرخه‌ای است که هر وسیله نقلیه در سرور طی می‌کند؛ از لحظه اسپاون اولیه تا حالت ثبت‌شده و عملیاتی که می‌تواند وضعیت آن را تغییر دهد.

```plantuml
@startuml
!theme plain
skinparam backgroundColor #0E121E
skinparam StateBorderColor #00FFCC
skinparam StateBackgroundColor #1E293B
skinparam StateFontColor #FFFFFF
skinparam ArrowColor #00FFCC

[*] --> خودروی_موقت : کلیک روی Spawn در پنل

state خودروی_موقت {
    خودروی_موقت : بدون ID دیتابیس
    خودروی_موقت : با ریستارت سرور از بین می‌رود
}

خودروی_موقت --> خودروی_دائمی : کلیک روی "ثبت موقعیت پارک" (/park)

state خودروی_دائمی {
    خودروی_دائمی : دارای ID دیتابیس ثابت
    خودروی_دائمی : بارگذاری خودکار بعد از ریستارت
    
    state "دارای فلش نئونی و Blip" as Marked
    state "مستقر در نقطه اولیه پارک" as Parked
    state "در حال رانندگی / جابجایی" as Moved
    
    Moved --> Parked : دکمه 🔄 ریست
    Parked --> Marked : دکمه 🎯 فلش
    Marked --> Parked : لغو یا حذف مارکر
}

خودروی_دائمی --> [*] : دکمه 🗑️ حذف (پاکسازی کامل از بازی و دیتابیس)
@enduml
```

---

### ۷. نمودار رابطه موجودیت پایگاه‌داده و متادیتا (ER & ElementData Schema)
![alt text](image-6.png)
> **توضیح:** نمایش فیلدهای ذخیره‌شده در پایگاه‌داده MySQL و نگاشت متناظر آن‌ها با شناسه و خواص زنده خودرو درون سرور MTA (`ElementData`).

```plantuml
@startuml
!theme plain
skinparam backgroundColor #0E121E
skinparam ClassBorderColor #00FFCC
skinparam ClassBackgroundColor #1E293B
skinparam ClassFontColor #FFFFFF
skinparam ArrowColor #00FFCC

entity "MySQL: server_vehicles" as Table {
    * **id** : INT (PK, AutoIncrement)
    --
    * **model** : INT (GTA Vehicle Model ID)
    * **x** : FLOAT (مختصات طول)
    * **y** : FLOAT (مختصات عرض)
    * **z** : FLOAT (مختصات ارتفاع)
    * **rx** : FLOAT (زاویه Roll)
    * **ry** : FLOAT (زاویه Pitch)
    * **rz** : FLOAT (زاویه پلاک / Yaw)
    * **plate** : VARCHAR(32)
    * **created_at** : TIMESTAMP
    * **updated_at** : TIMESTAMP
}

entity "GTA Vehicle ElementData" as Runtime {
    * **dbid** : عدد شناسه دیتابیس
    * **veh:id** : شناسه سازگار با سایر گیم‌مودها
    * **isPermanent** : بولین (true)
    * **created_at** : رشته زمان ایجاد
    * **updated_at** : رشته زمان آخرین پارک
}

Table ||--|| Runtime : "همگام‌سازی دوطرفه داده‌ها در زمان اجرا"
@enduml
```