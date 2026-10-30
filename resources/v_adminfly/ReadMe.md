# 🚀 سیستم پرواز روان ادمین | MTA:SA Smooth Admin Fly

> یک ریسورس بهینه‌سازی‌شده، کاملاً روان و مدرن برای سرورهای Multi Theft Auto (MTA:SA) جهت نظارت، بررسی موقعیت بازیکنان و جابجایی بدون برخورد (No-Clip) در نقشه با خودرو یا پیاده.

---

## 📌 فهرست مطالب
- [💡 ایده چیست و چرا تولید شد؟](#-ایده-چیست-و-چرا-تولید-شد)
- [🎯 هدف سازنده](#-هدف-سازنده)
- [⚖️ مزایا و معایب](#️-مزایا-و-معایب)
- [🎮 تجربه و فرایند مصرف کاربر عادی (User Flow)](#-تجربه-و-فرایند-مصرف-کاربر-عادی-user-flow)
- [⚙️ پشت صحنه کد چه اتفاقی می‌افتد؟](#️-پشت-صحنه-کد-چه-اتفاقی-می‌افتد)
- [🕹️ کلیدهای کنترل](#️-کلیدهای-کنترل)
- [📁 ساختار فایل‌ها](#-ساختار-فایل‌ها)
- [🚀 نحوه نصب و راه‌اندازی](#-نحوه-نصب-و-راه‌اندازی)

---

## 💡 ایده چیست و چرا تولید شد؟
در سرورهای نقش‌آفرینی (Roleplay) و شبیه‌سازها، ادمین‌ها نیازمند ابزاری سریع جهت رسیدگی به ریپورت‌ها، تله‌پورت آزادانه و سرکشی به متخلفان بدون گیر کردن لای در و دیوار ساختمان‌ها هستند. سیستم‌های پرواز سنتی معمولاً دچار لرزش (Stuttering)، افت فریم و عدم هماهنگی با زاویه دید دوربین بودند. این ریسورس برای برطرف کردن این چالش و ارائه‌ی حرکتی برداری و شبیه به دوربین آزاد (Freecam) توسعه داده شده است.

---

## 🎯 هدف سازنده
* **پایش نامحسوس:** امکان نظارت بر رفتارهای مشکوک بازیکنان از زاویه دلخواه و با سرعت متغیر.
* **آزادی در جابجایی:** عبور از آبجکت‌ها و موانع بدون اختلال در فیزیک کاراکتر یا خودروی ادمین.
* **کاهش مصرف منابع:** جایگزینی تله‌پورت‌های مکرر با سیستم حرکتی نرم و سبک روی فریم‌ریت کلاینت.

---

## ⚖️ مزایا و معایب

### ✅ مزایا
* **محاسبات نرم برداری:** چرخش و پیشروی کاملاً وابسته به زاویه دید دوربین (Look Vector).
* **پشتیبانی از وسیله نقلیه:** امکان پرواز همزمان بازیکن به همراه خودرویی که داخل آن است.
* **مستقل از نرخ فریم:** استفاده از دلتا-تایم (`dt`) در `onClientPreRender` برای یکنواختی سرعت در انواع مانیتورها.
* **امنیت داخلی:** بررسی سطح دسترسی کاربر از طریق سیستم پیش‌فرض ACL و دیتای سرور پیش از اجرای حالت پرواز.

### ⚠️ معایب
* در صورت قرار دادن اشتباه شرط‌های دیتابیس در سمت سرور، ممکن است بازیکنی با رنک معمولی اجازه دسترسی پیدا کند (نیازمند تنظیم صحیح خطوط بررسی ادمینی).
* همگام‌سازی موقعیت در کلاینت‌های دیگر با پینگ‌های بسیار بالا ممکن است کمی با وقفه دیده شود.

---

## 🎮 تجربه و فرایند مصرف کاربر عادی (User Flow)

```
[فشردن F12 یا دستور /fly]
            │
            ▼
[ارسال درخواست به سرور (Server Check)]
            │
   ┌────────┴────────┐
   ▼                 ▼
[ادمین نیست]       [ادمین تأیید شد]
   │                 │
   ▼                 ▼
خطای عدم دسترسی     حذف فیزیک و برخورد (Ghost Mode) + فعال شدن HUD
                     │
                     ▼
             حرکت روان در آسمان و در میان موانع
                     │
                     ▼
             [فشردن مجدد F12] ──► بازگشت فیزیک و جاذبه طبیعی
```

1. ادمین کلید `F12` یا دستور `/fly` را تایپ می‌کند.
2. سرور هویت و رنک او را می‌سنجد؛ در صورت عدم دسترسی، پیام خطا در چت صادر می‌شود.
3. در صورت تأیید، پلیر کمی شفاف (Ghost/Alpha 200) شده، جاذبه و فیزیک خاموش می‌شود و پنل وضعیت روی تصویر ظاهر می‌گردد.
4. با فشردن مجدد `F12` همه چیز بلافاصله به حالت طبیعی اول بازمی‌گردد.

---

## ⚙️ پشت صحنه کد چه اتفاقی می‌افتد؟

1. **مدیریت فیزیک و انیمیشن:** به محض روشن شدن حالت پرواز، توابع `setElementCollisionsEnabled(false)` و `setElementFrozen(true)` اجرا می‌شوند تا جاذبه و برخوردها قطع گردند؛ این موضوع مانع آسیب دیدن پلیر یا سقوط خودرو می‌شود.
2. **محاسبات برداری دوربین:** تابع `getCameraLookVectors` ماتریس جهت‌گیری چشم کاربر را در ۳ محور محاسبه و سپس نرمال‌سازی می‌کند. با محاسبه ضرب داخلی، بردار عمود بر دید به دست می‌آید که حرکت چپ/راست (`A`/`D`) را ممکن می‌سازد.
3. **همگام‌سازی سرعت (Delta Timing):** برای آنکه سرعت در سیستم‌های ۶۰ هرتز و ۱۴۴ هرتز برابر باشد، بردار جابجایی در ضریب `dt / 16.66` ضرب می‌شود.
4. **رندرینگ HUD:** تابع `renderFlightHUD` کادری مینیمال در گوشه تصویر رندر می‌کند که سرعت لحظه‌ای را به اپراتور گزارش می‌دهد.

---

## 🕹️ کلیدهای کنترل

| کلید | عملکرد |
| :--- | :--- |
| **`W` / `S`** | حرکت مستقیم به سمت دید دوربین / به عقب |
| **`A` / `D`** | حرکت جانبی به چپ و راست (Strafe) |
| **`Space`** | افزایش ارتفاع به صورت عمودی |
| **`Ctrl` یا `C`** | کاهش ارتفاع به صورت عمودی |
| **`Shift`** | توربو (افزایش سرعت ۴ برابری) |
| **`Alt`** | اسلوموشن (کاهش سرعت تا ۰.۲ جهت تنظیمات میلی‌متری) |
| **`Scroll Up/Down`** | کم و زیاد کردن سرعت پایه پرواز |
| **`F12`** | فعال‌سازی / خروج از حالت پرواز |

---

## 📁 ساختار فایل‌ها

```text
v_adminfly/
├── meta.xml         # تعریف ریسورس و فایل‌های کلاینت و سرور
├── client.lua       # محاسبات برداری، فیزیک، کلیدها و طراحی HUD
└── server.lua       # تأیید دسترسی ACL و امنیت دستورات
```

---

## 🚀 نحوه نصب و راه‌اندازی

1. پوشه‌ای به نام `v_adminfly` در مسیر `server/mods/deathmatch/resources/` سرور خود بسازید.
2. فایل‌های `meta.xml`، `server.lua` و `client.lua` را درون آن قرار دهید.
3. در کنسول سرور دستور زیر را بزنید:
```bash
refresh
start v_adminfly
```
4. حساب کاربری شما باید در یکی از گروه‌های `Admin`، `SuperAdmin` یا `Console` از فایل `acl.xml` وجود داشته باشد (یا مقدار متغیر `admin_level` معتبر باشد).











---

## 📊 دیاگرام‌های بصری سیستم (PlantUML)

> جهت مشاهده و رندر هر دیاگرام، کدهای داخل هر بلوک را مستقیماً در [ادیتور آنلاین PlantUML](https://editor.plantuml.com/) جای‌گذاری کنید.

---

### ۱. دیاگرام توالی (Sequence Diagram) - احراز هویت و فعال‌سازی پرواز
این دیاگرام چرخه برقراری ارتباط بین کلاینت، سرور و لایه ACL را نشان می‌دهد.

```plantuml
@startuml
!theme plain
autonumber
skinparam roundcorner 8
skinparam BoxPadding 10
skinparam ParticipantPadding 15
skinparam sequence {
    ArrowColor #00E5FF
    ActorBorderColor #38BDF8
    LifeLineBorderColor #64748B
    ParticipantBorderColor #0284C7
    ParticipantBackgroundColor #0F172A
    ParticipantFontColor #F8FAFC
}

actor "ادمین (بازیکن)" as Admin #38BDF8
participant "کلاینت (client.lua)" as Client
participant "سرور (server.lua)" as Server
database "سیستم مجوز (ACL / Data)" as ACL #1E293B

Admin -> Client : فشردن کلید [F12] یا تایپ /fly
activate Client #0284C7

Client -> Server : triggerServerEvent("adminfly:requestToggle")
activate Server #0284C7

Server -> ACL : بررسی سطح دسترسی (isPlayerAdmin)
activate ACL #334155

alt دسترسی مجاز است (Admin / SuperAdmin)
    ACL --> Server : تأیید صلاحیت (True)
    Server -> Client : triggerClientEvent("adminfly:toggleState")
    Client -> Client : startFlying() [خاموشی فیزیک + HUD]
    Client --> Admin : فعال‌سازی پرواز + پیام سبز
else دسترسی غیرمجاز
    ACL --> Server : رد صلاحیت (False)
    deactivate ACL
    Server --> Admin : ارسال پیام خطای دسترسی (#FF4444)
end

deactivate Server
deactivate Client
@enduml
```

---

### ۲. دیاگرام وضعیت (State Machine) - چرخه‌حیات کاراکتر در بازی
وضعیت‌های مختلف بازیکن و شرایط تغییر وضعیت از راه رفتن عادی تا پرواز و خروج اضطراری.

```plantuml
@startuml
!theme plain
skinparam state {
    BackgroundColor #0F172A
    BorderColor #00E5FF
    FontColor #F8FAFC
    StartColor #10B981
    EndColor #EF4444
    AttributeFontColor #94A3B8
}

[*] --> OnGround : ورود به بازی / پیاده یا سواره

state OnGround as "وضعیت عادی (Normal)" {
    OnGround : برخوردها فعال (Collisions: True)
    OnGround : فیزیک و گرانش فعال (Frozen: False)
    OnGround : شفافیت کامل (Alpha: 255)
}

OnGround --> Flying : فشردن F12 [در صورت داشتن دسترسی]

state Flying as "حالت پرواز (Admin Fly Active)" {
    state "شبح نامرئی (Ghost Physics)" as Ghost
    state "کنترل دوربین و HUD" as Movement
    
    Ghost : خاموشی برخورد با اشیاء (Collisions: False)
    Ghost : فریز فیزیک پایه (Frozen: True)
    Ghost : شفافیت شبح (Alpha: 200)
    
    Movement : گوش به زنگ PreRender
    Movement : محاسبه بردارهای دیداری
}

Flying --> OnGround : فشردن مجدد F12 (خروج عادی)
Flying --> Terminated : کشته شدن بازیکن (onClientPlayerWasted)
Terminated --> OnGround : اسپاون مجدد
@enduml
```

---

### ۳. دیاگرام فعالیت (Activity Diagram) - هسته فیزیک و هر فریم رندر
فرایند خط به خط پردازش در رویداد `onClientPreRender` و تبدیل ضربان کلیدها به مختصات فضایی سه بعدی.

```plantuml
@startuml
!theme plain
skinparam activity {
    BackgroundColor #0F172A
    BorderColor #38BDF8
    FontColor #F8FAFC
    DiamondBackgroundColor #1E293B
    DiamondBorderColor #00E5FF
    DiamondFontColor #F8FAFC
    ArrowColor #00E5FF
}

start
:فراخوانی رویداد onClientPreRender (dt);

if (آیا پرواز فعال است؟) then (بله)
    :محاسبه ضریب سرعت پایه (baseSpeed);
    
    if (کلید Shift فشرده شده؟) then (بله)
        :افزایش سرعت (Speed * 4.0);
    elseif (کلید Alt فشرده شده؟) then (بله)
        :کاهش سرعت (Speed * 0.2);
    endif
    
    :دریافت ماتریس دوربین (getCameraMatrix);
    :محاسبه بردار روبرو (fx, fy, fz) و بردار افقی (rx, ry);
    :بررسی کلیدهای حرکتی [W, A, S, D, Space, Ctrl];
    
    if (کلیدی فشرده شده؟) then (بله)
        :نرمال‌سازی بردار جهت (Normalize Magnitude);
        :محاسبه دلتا تایم جابجایی (dt / 16.66);
        :تغییر موقعیت المنت (setElementPosition);
        :هم‌جهت سازی زاویه چرخش با دوربین (setElementRotation);
    endif
else (خیر)
    :توقف پردازش;
endif

stop
@enduml
```

---

### ۴. دیاگرام ساختار و کامپوننت‌ها (Component Diagram)
نگاشت ارتباط ماژولار میان فایل‌های ریسورس MTA، حافظه کلاینت و سرویس‌های هسته.

```plantuml
@startuml
!theme plain
skinparam componentStyle rectangle
skinparam component {
    BackgroundColor #0F172A
    BorderColor #00E5FF
    FontColor #F8FAFC
}
skinparam interface {
    BackgroundColor #1E293B
    BorderColor #38BDF8
}

package "v_adminfly Resource" {
    [meta.xml] as Meta #1E293B
    
    package "کلاینت (Client-Side)" {
        [client.lua] as ClientScript
        [HUD Renderer] as HUD
        [Vector Math Engine] as MathEngine
        [Input Manager] as Input
    }

    package "سرور (Server-Side)" {
        [server.lua] as ServerScript
        [ACL Validator] as Auth
    }
}

cloud "MTA:SA Core C++" as Engine {
    () "Camera Matrix API" as CamAPI
    () "Element Data API" as DataAPI
    () "DirectX Drawing API" as DxAPI
}

ClientScript ..> MathEngine : محاسبات بردار
ClientScript ..> HUD : رسم در صفحه
ClientScript ..> Input : شنود دکمه‌ها
HUD --> DxAPI : رندر مستطیل و متن
MathEngine --> CamAPI : خواندن ماتریس
ServerScript --> Auth : بررسی گروه ادمین
ServerScript ..> DataAPI : خواندن سطح ادمینی
ClientScript <--> ServerScript : ارتباط رویدادها (Trigger Latent/Event)
@enduml
```

---

### ۵. دیاگرام موارد استفاده (Use Case Diagram)
نقش‌های کاربری و کنش‌های تعاملی هر بازیگر با ماژول‌های پرواز ادمین.

```plantuml
@startuml
!theme plain
left to right direction
skinparam actorStyle awesome
skinparam packageStyle rectangle
skinparam usecase {
    BackgroundColor #0F172A
    BorderColor #38BDF8
    FontColor #F8FAFC
    ArrowColor #00E5FF
}

actor "ادمین سرور" as Admin #38BDF8
actor "سیستم فیزیک سرور" as Physics #EF4444

rectangle "سیستم پرواز (Admin Fly System)" {
    usecase "روشن/خاموش کردن پرواز (F12)" as UC_Toggle
    usecase "تنظیم سرعت پرواز (اسکرول موس)" as UC_Speed
    usecase "عبور از در و دیوار (No-Clip)" as UC_NoClip
    usecase "مشاهده وضعیت سرعت و HUD" as UC_HUD
    usecase "پرواز با وسیله نقلیه (Vehicle Fly)" as UC_VehFly
    usecase "بررسی سطح دسترسی (ACL Check)" as UC_Auth
}

Admin --> UC_Toggle
Admin --> UC_Speed
Admin --> UC_VehFly

UC_Toggle .> UC_Auth : <<شامل می‌شود>>
UC_Toggle --> UC_NoClip : غیرفعال‌سازی برخورد
UC_Toggle --> UC_HUD : رسم روی صفحه

Physics --> UC_NoClip : مسدودسازی سقوط و ضربه
@enduml
```

---

### ۶. دیاگرام جریان داده و کنترل (Data Flow Diagram)
جریان ورود اطلاعات از کنترلرها به محاسبات ریاضی و در نهایت تغییر ویژگی‌های جهان بازی.

```plantuml
@startuml
!theme plain
skinparam rectangle {
    BackgroundColor #0F172A
    BorderColor #00E5FF
    FontColor #F8FAFC
    RoundCorner 10
}
skinparam arrow {
    Color #38BDF8
    FontColor #94A3B8
}

rectangle "ورودی‌های کاربر\n(WASD, Shift, Space, Mouse Wheel)" as Inputs #1E293B
rectangle "موتور دوربین MTA\n(Camera Look & Position)" as Camera #1E293B
rectangle "موتور پردازش بردارها\n(Look & Right Normalization)" as Vectors #0369A1
rectangle "تطبیق فریم‌ریت\n(Delta-Time Normalizer)" as Delta #0284C7
rectangle "دستکاری المنت هدف\n(Player / Vehicle Position)" as Target #0F172A
rectangle "رندر آنی HUD\n(DirectX Graphics)" as Render #0F172A

Inputs --> Vectors : سیگنال محورها (dx, dy, dz)
Inputs --> Delta : مقادیر ضریب شتاب و اسلوموشن
Camera --> Vectors : ماتریس cx, cy, cz, lx, ly, lz
Inputs --> Render : مقدار سرعت لحظه‌ای
Vectors --> Delta : بردار نهایی جهت
Delta --> Target : اعمال موقعیت نهایی با setElementPosition
Delta --> Target : تنظیم زاویه دید با setElementRotation
@enduml
```

---

### ۷. دیاگرام ذهنی معماری سیستم (MindMap)
کالبدشکافی مفهومی تمام بخش‌ها و قابلیت‌های این اسکریپت در یک نگاه.

```plantuml
@startmindmap
!theme plain
skinparam mindmap {
    NodeBackgroundColor #0F172A
    NodeBorderColor #00E5FF
    NodeFontColor #F8FAFC
    EdgeColor #38BDF8
}

* **سیستم پرواز روان ادمین (v_adminfly)**
 * **ریاضیات و بردارها (Vector Math)**
  * استخراج ماتریس دوربین (Camera Matrix)
  * بردار مستقیم دید (Look Vector)
  * بردار افقی متقاطع (Right-hand Normal)
  * تعدیل‌ساز زمانی (Delta Timing dt)
 * **سیستم کنترل (Key Mapping)**
  * کلیدهای جهت‌نما: W/A/S/D
  * تغییر ارتفاع: Space / Ctrl
  * بوستر شتاب: Shift (۴ برابر)
  * کنترل دقیق: Alt (۰.۲ برابر)
  * اسکرول چرخ موس: تنظیم بازه ۰.۱ تا ۱۵
 * **فیزیک و المنت‌ها**
  * پشتیبانی کامل از کاراکتر پیاده
  * پشتیبانی از خودروی سوار شده
  * ایزوله‌سازی برخورد (No Collisions)
  * افکت نیمه‌شفاف (Alpha 200)
 * **امنیت و سرور (Security)**
  * استعلام از گروه ACL Admin
  * پشتیبانی از دیتای سفارشی (admin_level)
  * جلوگیری از اجرای کلاینتی بدون تایید سرور
 * **رابط کاربری (UI/HUD)**
  * کادر مدرن با خط نئونی آبی
  * نمایش زنده سرعت فعلی
  * لغو خودکار در صورت مرگ کاراکتر
@endmindmap
```