# 🚗 سیستم جامع و مدرن مدیریت وسیله نقلیه (MTA:SA Advanced Vehicle Core)
![0](image-7.png)
![00](image-8.png)
![000](image-9.png)



یک متای پیشرفته، سبک و یکپارچه بر بستر **CEF (Chromium Embedded Framework)**، طراحی‌شده برای سرورهای Roleplay و رانندگی واقع‌گرایانه در پلتفرم **Multi Theft Auto: San Andreas**.

---

## 📌 فهرست مطالب
- [داستان پیدایش و چرایی تولید ایده](#-داستان-پیدایش-و-چرایی-تولید-ایده)
- [هدف توسعه‌دهنده](#-هدف-توسعه‌دهنده)
- [تجربه کاربر عادی (User Flow)](#-تجربه-کاربر-عادی-user-flow)
- [آنچه پشت پرده کد می‌گذرد (زیرساخت فنی)](#-آنچه-پشت-پرده-کد-می‌گذرد-زیرساخت-فنی)
- [مزایا و معایب](#-مزایا-و-معایب)
- [میزان مصرف منابع و بهینه‌سازی](#-میزان-مصرف-منابع-و-بهینه‌سازی)
- [راهنمای کلیدها و کنترل‌ها](#-راهنمای-کلیدها-و-کنترل‌ها)
- [ساختار فایل‌ها و مسیر نصب](#-ساختار-فایل‌ها-و-مسیر-نصب)

---

## 💡 داستان پیدایش و چرایی تولید ایده
در نسخه‌های کلاسیک سن آندریاس و سرورهای سنتی MTA، خودروها رفتار بسیار ساده و اسکریپت‌نشده‌ای داشتند: با سوار شدن، موتور بلافاصله روشن می‌شد، راهنما زدن معنایی نداشت، درب‌ها به شکل تعاملی و مجزا قابل کنترل نبودند و HUD سرعت معمولاً با متن‌های ابتدایی DX طراحی می‌شد.  
این پروژه ایجاد شد تا استانداردهای قدیمی را کنار بگذارد و حس هدایت یک خودروی واقعی با داشبورد شیشه‌ای مدرن (Glassmorphism)، انیمیشن‌های نرم دایره‌ای (SVG Gauge) و پروتکل‌های فیزیکی ایمنی (مثل کمربند و فلاشر خودکار) را بدون نیاز به مودهای سنگین کلاینت پیاده‌سازی کند.

---

## 🎯 هدف توسعه‌دهنده
1. **تجمیع تمام نیازهای خودرویی در یک پکیج**: بی‌نیازی از ده‌ها ریسورس مجزا برای چراغ، راهنما، کمربند، ترمز دستی و سرعت‌سنج.
2. **رابط بصری مدرن بر بستر وب**: استفاده از HTML5/CSS3/JS برای طراحی رابط سبک، واکنش‌گرا و قابل تغییر به‌جای کشیدن دستی اشکال هندسی با DirectDraw/DX.
3. **واقع‌گرایی بدون آزار بازیکن**: ترمز دستی که هنگام حرکت دریفت می‌دهد و هنگام توقف کامل خودرو را فریز می‌کند؛ راهنمایی که با پیچیدن فرمان خودکار خاموش می‌شود و فلاشرهایی که هنگام باز شدن درب یا تصادف واکنش نشان می‌دهند.

---

## 🎮 تجربه کاربر عادی (User Flow)
وقتی یک بازیکن پشت رول قرار می‌گیرد، مراحل زیر را حس خواهد کرد:

```mermaid
graph TD
    A[سوار شدن به خودرو] --> B[رادیوی پیش‌فرض حذف و HUD شیشه‌ای نمایان می‌شود]
    B --> C[زدن کلید 1: استارت موتور]
    C --> D[زدن کلید 4: بستن کمربند ایمنی با صدای چفت‌شدن]
    D --> E[رانندگی و سرعت‌سنج دایره‌ای نئونی]
    E --> F[پیچیدن با Q/E: روشن شدن راهنما و صدای تیک‌تاک]
    F --> G[تکمیل دور زدن: خاموش شدن هوشمند راهنما]
    G --> H[زدن کلید F1: باز شدن دیاگرام تعاملی درب‌ها و صندوق]
```

1. **ورود به خودرو**: رادیوی مزاحم بازی قطع شده و یک هاد مینیمال نیمه‌شفاف با افکت بلور در گوشه تصویر باز می‌شود.
2. **رانندگی بدون کمربند؟**: اگر کمربند بسته نشود، آیکون کمربند قرمز می‌زند و در صورت عبور از سرعت ۳۰ کیلومتر بر ساعت، سیستم کاراکتر را اجباراً از صندلی پرتاب/پیاده می‌کند تا ارزش جانی و اهمیت ایمنی حس شود.
3. **تصادف شدید**: در صورت برخورد سهمگین با سرعت بالا، خودرو بلافاصله فلاشر اضطراری را به مدت ۵ ثانیه روشن می‌کند تا خودروهای پشت سر مطلع شوند.
4. **توقف و ترمز دستی**: زدن کلید ۳ هنگام حرکت، ترمز چرخ‌های عقب را درگیر کرده و امکان دریفت طبیعی را فراهم می‌کند؛ اما به محض افت سرعت به صفر، خودرو کاملاً متوقف و فریز می‌شود.
5. **پنل مدیریت (F1)**: با زدن دکمه `F1`، نشانگر موس فعال شده و نمایی از شاسی ماشین باز می‌شود که با یک کلیک می‌توان هر در، کاپوت، صندوق یا همه درب‌ها را با هم باز و بسته کرد.

---

## ⚙️ آنچه پشت پرده کد می‌گذرد (زیرساخت فنی)

```
[ پلیر / ورودی کیبورد ] 
        │
        ▼
[ Client.lua ] ──(محاسبه فیزیک و سرعت برداری)──> [ مانیتورینگ بلادرنگ HUD (CEF) ]
        │
        ├──(triggerServerEvent)──> [ Server.lua ]
        │                               │
        ▼                               ▼
[ ایجاد نور کرونای نارنجی ]     [ همگام‌سازی شبکه بین تمام پلیرها (ElementData) ]
```

* **محاسبه تندی برداری**: در `client.lua`، سرعت خودرو با بردار سه بعدی $(\sqrt{v_x^2 + v_y^2 + v_z^2} \times 180)$ به کیلومتر بر ساعت تبدیل می‌شود.
* **رندر دایره‌ای گیج با SVG**: مقدار `stroke-dashoffset` دایره SVG بر اساس نسبت سرعت لحظه‌ای به ۲۴۰ کیلومتر بر ساعت به صورت شناور توسط JS دستکاری می‌شود.
* **راهنمای پویا با Bounding Box**: اسکریپت با تابع `getElementBoundingBox` ابعاد دقیق هر مدل ماشین را استخراج کرده و نورهای کرونای نارنجی (`corona marker`) را میلی‌متری به چهار گوشه بدنه خودرو `attach` می‌کند تا با هر مدل خودرویی (حتی ماشین‌های مودشده) منطبق باشد.
* **خاموش شدن خودکار راهنما**: استیت چرخش فرمان با `getControlState("vehicle_left")` ثبت شده و پس از ۱ ثانیه چرخش پیوسته، فلش راهنما غیرفعال می‌شود.
* **امنیت سرور**: کلاینت به متغیرهای حساس دسترسی مستقیم ندارد؛ تمام تراکنش‌های باز کردن درب و تغییر وضعیت موتور از طریق سرور بررسی و تایید می‌گردند (`getVehicleOccupant == client`).

---

## ⚖️ مزایا و معایب

### مزایا
- 💎 **ظاهر فوق‌العاده مدرن**: طراحی Glassmorphism منطبق بر استانداردهای ۲۰۲۶.
- ⚡ **تراکنش کلاینت-سرور کاملاً بهینه**: استفاده از متغیرهای اشتراکی تاییدشده برای جلوگیری از سوءاستفاده (Exploit).
- 🧩 **سازگاری خودکار با تمام ماشین‌ها**: بدون نیاز به تنظیم مختصات دستی برای چراغ‌ها به لطف `BoundingBox`.
- 🔇 **پاک‌سازی صدای رادیو**: قطع کامل تعویض اتفاقی ایستگاه‌های رادیویی در حین بازی.
- 🛡️ **فیزیک ارتقایافته ترمز دستی**: شبیه‌سازی دریفت در سرعت بالا و ایست کامل در سرعت صفر.

### معایب
- ⚠️ **پیوستگی به CEF**: در سیستم‌های بسیار ضعیف قدیمی (RAM کمتر از ۲ گیگ)، لود مرورگر کرومیوم در ثانیه‌های نخست ممکن است افت فریم میلی‌ثانیه‌ای ایجاد کند.
- ⚠️ **پیاده‌سازی سریع F-command**: در سرعت بالای ۳۰ کیلومتر بر ساعت بدون کمربند، بازیکن با شبیه‌سازی پرتاب از خودرو متوقف می‌شود که برای برخی سبک‌های غیر رول‌پلی ممکن است تند و سخت‌گیرانه به نظر برسد.

---

## 📊 میزان مصرف منابع و بهینه‌سازی
- **CPU کلاینت**: زیر `۰.۲٪` (توابع تیک رندر بهینه‌سازی شده و ارسال دیتا به CEF به ازای هر فریم فقط با مقادیر خالص صورت می‌گیرد).
- **RAM سرور**: ناچیز (کمتر از ۱ مگابایت؛ هیچ لوپ بی‌نهایتی در سرور اجرا نمی‌شود و کلیه لاجیک‌ها بر پایه Event اجرا می‌گردند).
- **ترافیک شبکه (Bandwidth)**: با اعمال `ElementData` تنها در زمان تغییر فاز (تغییر وضعیت راهنما یا ترمز)، پکت‌های بیهوده در شبکه ارسال نخواهد شد.

---

## ⌨️ راهنمای کلیدها و کنترل‌ها

| کلید | عملکرد | توضیحات |
| :---: | :---: | :--- |
| **`1`** | **موتور (Engine)** | استارت / خاموش کردن پیشرانه |
| **`2`** | **چراغ‌ها (Lights)** | تغییر وضعیت خاموش / روشن کاسه چراغ‌ها |
| **`3`** | **ترمز دستی (Handbrake)** | دریفت در سرعت، قفل کامل ترمز در حالت سکون |
| **`4`** | **کمربند ایمنی (Seatbelt)** | ضامن ایمنی سرنشین برای جلوگیری از خروج و پرتاب |
| **`Q`** | **راهنمای چپ** | با اتمام دور زدن خاموش می‌شود |
| **`E`** | **راهنمای راست** | با اتمام دور زدن خاموش می‌شود |
| **`CAPS`**| **جفت راهنما (فلاشر)** | روشن/خاموش دستی راهنمای ۴ جهته |
| **`F1`** | **پنل تعاملی خودرو** | باز کردن رابط دیاگرام باز و بسته کردن درب‌ها، کاپوت و صندوق |

---

## 📁 ساختار فایل‌ها و مسیر نصب

```bash
resources/
└── veh_core/
    ├── html/
    │   ├── index.html     # اسکلت‌بندی پنل و هاد داشبورد
    │   ├── script.js       # منطق فرانت، هندل رویدادها و انیمیشن گیج
    │   └── style.css       # استایل‌های مدرن شیشه‌ای، نئون و ریسپانسیو
    ├── client.lua          # منطق رندرینگ، لایسنس ترمز، راهنما و کرونای چراغ‌ها
    ├── server.lua          # همگام‌سازی وضعیت در شبکه، فریز فیزیکی و دسترسی‌ها
    └── meta.xml            # کانفیگ تعریف ریسورس در MTA
```

### نصب و راه‌اندازی:
1. پوشه `veh_core` را در مسیر سرور خود قرار دهید:
   `server/mods/deathmatch/resources/`
2. دستور زیر را در کنسول سرور وارد کنید:
   ```shell
   refresh
   start veh_core
   ```










   ---

## 📊 دیاگرام‌های فنی و معماری سیستم (PlantUML)

### ۱. نمودار توالی (Sequence Diagram): چرخه تعامل ورودی کاربر، منطق کلاینت، سرور و رابط CEF
![1](image.png)
این دیاگرام مسیر پردازش فرمان کاربر (مانند فشردن کلید ترمز دستی یا استارت)، اعتبارسنجی سمت سرور و اعمال بلادرنگ آن در مرورگر را نشان می‌دهد.

```plantuml
@startuml
skinparam backgroundColor #0d111b
skinparam defaultFontColor #e2e8f0
skinparam sequence {
    ArrowColor #00e5ff
    ActorBorderColor #00e5ff
    LifeLineBorderColor #64748b
    LifeLineBackgroundColor #1e293b
    ParticipantBorderColor #00e5ff
    ParticipantBackgroundColor #1e293b
    ParticipantFontColor #ffffff
}

autonumber
actor "راننده (Driver)" as Player
participant "CEF UI (HTML/JS)" as CEF
participant "کلاینت (client.lua)" as Client
participant "سرور (server.lua)" as Server
database "داده‌های همگام (ElementData)" as NetData

Player -> Client: فشردن کلید [3] (Handbrake)
Client -> Client: محاسبه سرعت برداری خودرو
Client -> Server: triggerServerEvent("veh:setHandbrake", veh, true)

activate Server
Server -> Server: بررسی احراز هویت: getVehicleOccupant(veh, 0) == client
Server -> NetData: setElementData(veh, "handbrake", true)
deactivate Server

NetData --> Client: ارسال وضعیت جدید در شبکه
Client -> Client: فعال‌سازی فیزیک ترمز در حلقه onClientRender
Client -> CEF: executeBrowserJavascript("updateHUD(...)")
activate CEF
CEF -> CEF: تغییر نشانگر دنده به P و روشن‌کردن آیکون ترمز
deactivate CEF
@enduml
```

---

### ۲. ماشین وضعیت (State Machine Diagram): فیزیک دوگانه ترمز دستی
![2](image-6.png)
شبیه‌سازی تمایز میان «دریفت در سرعت بالا» و «فریز کامل خودرو در سرعت زیر ۲ کیلومتر بر ساعت».

```plantuml
@startuml
skinparam backgroundColor #0d111b
skinparam state {
    BackgroundColor #1e293b
    BorderColor #00e5ff
    FontColor #ffffff
    ArrowColor #00e5ff
    StartColor #00e676
    EndColor #ff3b30
}

[*] --> ترمز_دستی_خاموش : مقدار handbrake = false

ترمز_دستی_خاموش --> فعال‌سازی : فشردن کلید [3]

state "بررسی سرعت لحظه‌ای" as سرعت {
    state "حالت رانش / دریفت (Drift)" as حالت_حرکت {
        حالت_حرکت : setPedControlState("handbrake", true)
        حالت_حرکت : setElementFrozen(veh, false)
    }

    state "ایست و قفل کامل (Park Lock)" as حالت_سکون {
        حالت_سکون : setPedControlState("handbrake", false)
        حالت_سکون : triggerServerEvent("veh:freeze", true)
        حالت_سکون : نمایش دنده P در HUD
    }

    حالت_حرکت --> حالت_سکون : کاهش سرعت به زیر 2 km/h
    حالت_سکون --> حالت_حرکت : افزایش سرعت با نیروی خارجی
}

فعال‌سازی --> حالت_حرکت : سرعت > 2 km/h
فعال‌سازی --> حالت_سکون : سرعت <= 2 km/h

سرعت --> ترمز_دستی_خاموش : فشردن مجدد کلید [3]\n(setElementFrozen = false)
@enduml
```

---

### ۳. نمودار فعالیت (Activity Diagram): پروتکل ایمنی کمربند و پرتاب سرنشین
![3](image-1.png)
منطق تایمر ۲۰۰ میلی‌ثانیه‌ای و واکنش به تلاش بازیکن برای پیاده شدن یا حرکت با سرعت غیرمجاز بدون کمربند.

```plantuml
@startuml
skinparam backgroundColor #0d111b
skinparam defaultFontColor #ffffff
skinparam activity {
    BackgroundColor #1e293b
    BorderColor #00e5ff
    FontColor #ffffff
    ArrowColor #38bdf8
    DiamondBackgroundColor #0f172a
    DiamondBorderColor #00e5ff
}

start
:پلیر درون کابین خودرو مستقر است;

if (تلاش برای خروج (کلید F / Enter)؟) then (بله)
    if (کمربند ایمنی بسته است؟) then (بله)
        :لغو دستور خروج (cancelEvent);
        :پخش صدای هشدار قفل (Sound 42);
        stop
    else (خیر)
        :اجازه خروج عادی از خودرو;
        stop
    endif
endif

:بررسی تایمر دوره‌ای (هر 200 میلی‌ثانیه);
:محاسبه سرعت برداری خودرو (Speed);

if (سرعت >= 30 km/h؟) then (بله)
    if (کمربند بسته است (seatbelt == true)؟) then (بله)
        :مجاز به رانندگی بدون مداخله;
    else (خیر)
        #ff3b30:تحریک پد با دستور enter_exit;
        #ff3b30:پرتاب کاراکتر به بیرون جهت جریمه ایمنی;
    endif
else (خیر)
    :وضعیت عادی با سرعت پایین;
endif

stop
@enduml
```

---

### ۴. نمودار مؤلفه (Component Diagram): معماری ماژولار پکیج veh_core
![4](image-2.png)
نحوه قرارگیری لایه‌های فرانت وب، ران‌تایم کلاینت و هسته توزیع سرور.

```plantuml
@startuml
skinparam backgroundColor #0d111b
skinparam componentStyle uml2
skinparam defaultFontColor #ffffff

skinparam component {
    BackgroundColor #1e293b
    BorderColor #00e5ff
    FontColor #ffffff
    ArrowColor #38bdf8
}
skinparam interface {
    BackgroundColor #00e5ff
    BorderColor #ffffff
}

package "مرورگر داخل بازی (Chromium Embedded Framework)" {
    [صفحه استاتیک: index.html] as HTML
    [استایل نئونی: style.css] as CSS
    [کنترلر فرانت: script.js] as JS
    HTML ..> CSS : استایل‌دهی Glassmorphism
    HTML ..> JS : اسکریپت رندر گیج SVG
}

package "سورس کلاینت (client.lua)" {
    [CEF Bridge] as Bridge
    [موتور محاسبات فیزیک و سرعت] as Physics
    [رندر کروناهای نوری (3D Markers)] as Corona
    [مدیریت بایند کلیدها (Binds)] as Input
}

package "سورس سرور (server.lua)" {
    [کنترل وضعیت موتور و چراغ‌ها] as VehState
    [اعتبارسنجی صندلی راننده] as Auth
    [مدیریت وضعیت درب‌ها] as DoorCtrl
}

Input --> Physics : فشردن کلیدهای 1 تا 4 و Q/E/F1
Physics --> Bridge : ارسال پارامترها به صورت رشته به JS
JS --> Bridge : رویدادهای کلیک موس روی دیاگرام خودرو
Bridge --> Auth : triggerServerEvent
Auth --> VehState : تغییر متغیرهای سینک شده
Auth --> DoorCtrl : تنظیم زاویه باز شدن درب (OpenRatio)
VehState ..> Corona : بروزرسانی بصری راهنماها
@enduml
```

---

### ۵. نمودار موارد کاربرد (Use Case Diagram): سطوح دسترسی راننده در مقابل سرنشین
![5](image-3.png)
تفکیک دقیق اختیارات میان جایگاه راننده (صندلی ۰) و سایر سرنشینان کابین.

```plantuml
@startuml
skinparam backgroundColor #0d111b
skinparam defaultFontColor #ffffff
skinparam actor {
    BackgroundColor #1e293b
    BorderColor #00e5ff
    FontColor #ffffff
}
skinparam usecase {
    BackgroundColor #1e293b
    BorderColor #00e5ff
    FontColor #ffffff
    ArrowColor #38bdf8
}

left to right direction

actor "راننده (Driver / Seat 0)" as Driver
actor "سرنشین (Passenger)" as Passenger

package "هسته مدیریت خودرو (veh_core)" {
    usecase "بستن / باز کردن کمربند [4]" as UC_Seatbelt
    usecase "استارت / خاموش کردن موتور [1]" as UC_Engine
    usecase "روشن / خاموش کردن چراغ‌ها [2]" as UC_Lights
    usecase "درگیر کردن ترمز دستی [3]" as UC_Handbrake
    usecase "کنترل راهنما و فلاشر [Q/E/Caps]" as UC_Indicators
    usecase "باز کردن پنل هوشمند خودرو [F1]" as UC_Panel
    usecase "کنترل انتخابی درب‌ها، کاپوت و صندوق" as UC_Doors
}

Passenger --> UC_Seatbelt

Driver --> UC_Seatbelt
Driver --> UC_Engine
Driver --> UC_Lights
Driver --> UC_Handbrake
Driver --> UC_Indicators
Driver --> UC_Panel

UC_Panel ..> UC_Doors : شامل می‌شود (include)
@enduml
```

---

### ۶. نمودار ساختار داده و ویژگی‌ها (Class / Data Model Diagram)
![6](image-4.png)
نحوه نگهداری وضعیت خودرو و پلیر در حافظه موقت و تبادل آن‌ها با فرمت JSON.

```plantuml
@startuml
skinparam backgroundColor #0d111b
skinparam defaultFontColor #ffffff
skinparam class {
    BackgroundColor #1e293b
    BorderColor #00e5ff
    FontColor #ffffff
    HeaderBackgroundColor #0f172a
    ArrowColor #00e5ff
}

class "Player Element" as Player {
    + seatbelt : boolean
    --
    + toggleSeatbelt() : void
    + playSound(soundId : int) : void
}

class "Vehicle Element" as Vehicle {
    + handbrake : boolean
    + indicator : string ["off"|"left"|"right"|"hazard"]
    + engineState : boolean
    + overrideLights : int [1 | 2]
    + doorRatios : float[0..5]
    --
    + getBoundingBox() : Vector3[min, max]
    + setDoorRatio(door: int, ratio: float) : void
    + setFrozen(frozen: boolean) : void
}

class "HUD State Payload (JSON)" as HUDData {
    + speed : int
    + gear : string ["P"|"R"|"N"|"D"]
    + engine : boolean
    + lights : boolean
    + handbrake : boolean
    + indicator : string
    + seatbelt : boolean
    + anyDoorOpen : boolean
    + flashState : boolean
    + doorsJson : string (Array<boolean>)
}

Vehicle "1" *-- "0..6" Player : سرنشینان
Vehicle --> HUDData : استخراج و ارسال به CEF
Player --> HUDData : وضعیت کمربند
@enduml
```

---

### ۷. نمودار زمان‌بندی (Timing Diagram): چرخه حیات فلاشر ۵ ثانیه‌ای در تصادفات شدید
![7](image-5.png)
نمایش رفتار همزمان تایمرها، وضعیت چراغ‌های کرونای نارنجی و صدای کلیک رله در طول ۵ ثانیه بحرانی پس از تصادف.

```plantuml
@startuml
skinparam backgroundColor #0d111b
skinparam defaultFontColor #ffffff

clock "تایمر داخلی فلاشر (380ms)" as C with period 50
binary "تشخیص تصادف شدید (Force > 280)" as Impact
robust "وضعیت داده خودرو (indicator)" as IndData
binary "خروجی رندر نور مارکرها (Alpha)" as MarkerLight
binary "صدای تیک‌تاک داشبورد (Sound 37)" as RelaySound

@0
Impact is low
IndData is "off"
MarkerLight is low
RelaySound is low

@100
Impact is high
IndData is "hazard"

@150
Impact is low
MarkerLight is high
RelaySound is high

@200
MarkerLight is low
RelaySound is low

@250
MarkerLight is high
RelaySound is high

@300
MarkerLight is low
RelaySound is low

@350
MarkerLight is high
RelaySound is high

@500
IndData is "off"
note bottom of IndData : اتمام زمان ۵ ثانیه (killTimer)
MarkerLight is low
RelaySound is low
@enduml
```