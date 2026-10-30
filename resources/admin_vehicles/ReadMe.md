سیستم مدیریت وسایل نقلیه پایدار (Admin Permanent Vehicle Management System)

📖 معرفی کاربردی برای عموم (High-Level Overview)

این سیستم چیست و چه کاربردی دارد؟
در سرورهای بازی آنلاین MTA:SA، وسایل نقلیه‌ای که توسط مدیران ظاهر (اسپاون)
می‌شوند، ماهیتی موقت دارند؛ با ری‌استارت شدن سرور، کرش کردن یا خالی شدن بازی،
این خودروها ناپدید می‌شوند. از سوی دیگر، اگر دو ماشین روی یک نقطه هم‌زمان ساخته
شوند، به دلیل باگ فیزیک بازی بلافاصله به پرواز درآمده یا منفجر می‌شوند!
این ریسورس این چالش‌ها را به طور کامل رفع کرده است:

  - رابط گرافیکی تحت وب مدرن (CEF): با فشردن دکمه F6 یا دستور /vehpanel،
    پنجره‌ای شیشه‌ای (Glassmorphic) و راست‌چین باز می‌شود تا مدیران تمام
    ماشین‌های ثبت‌شده را با مشخصات کامل ببینند یا ماشین دلخواه را در لحظه
    بسازند.
  - ذخیره ابدی در پایگاه داده (MySQL Persistence): ادمین می‌تواند هر خودرویی را
    به نقطه دلخواه منتقل کند و دکمه «ثبت موقعیت پارک» را بزند؛ پس از آن حتی در
    صورت ری‌استارت سرور، ماشین‌ها در همان مختصات باقی می‌مانند.
  - موتور ضد انفجار و اسپاون هوشمند: سیستم قبل از ساخت هر خودرو بررسی می‌کند اگر
    خودرویی با همان مشخصات یا در شعاع ۲ متری آن نقطه وجود دارد، شیء تکراری نسازد
    تا مانع از همپوشانی فیزیکی و انفجار خودروها شود.
  - ابزارهای مدیریت ناوبری زنده: امکان تله‌پورت به ماشین، بازگرداندن موقعیت
    (ریست) به محل پارک، حذف دائم از بازی و دیتابیس، و فعال‌سازی مارکر سه‌بعدی
    نئونی بالای سقف همراه با علامت نقشه.

۱. خلاصه مدیریتی و اهداف طراحی (Executive Summary)

۱.۱. بیان مسئله

در معماری کلاینت-سرور پلتفرم Multi Theft Auto (مبتنی بر موتور RenderWare و فیزیک
GTA: SA)، موجودیت‌های محیطی (Elements) فرار (Volatile) هستند. مدیریت ناوگان ثابت
(نظیر خودروهای پلیس، تاکسی‌رانی، امداد و خدمات شهری) مستلزم حفظ مشخصات فضایی
برداری P(x, y, z) و دوران زاویه‌ای R(rx, ry, rz) به شکل پایدار است. رویکردهای
سنتی فاقد یکپارچگی اتمیک بوده و در صورت بازنشانی مکرر سرور، با مشکل جدی تداخل
فیزیکی (Mesh Intersection Detonation) و پرتاب آبجکت‌ها در فضا روبرو می‌شوند.

۱.۲. راهکار مهندسی پیاده‌سازی‌شده

این ریسورس با هدف حل بنیادین چالش‌های فوق بر پایه اصول مهندسی نرم‌افزار توسعه
یافته است:

  - معماری رویدادمحور ناهمگام (Asynchronous Event-Driven Architecture): کلیه
    تبادلات دیتابیس و اعتبارسنجی‌ها در Worker Threadهای پس‌زمینه بدون مسدودسازی
    حلقه اصلی تیک سرور انجام می‌پذیرد.
  - رابط کاربری مجزا بر بستر CEF: جداسازی کامل لایه ارائه (Presentation Layer)
    از لایه منطق با استفاده از موتور مرورگر کرومیوم درون‌بازی.
  - الگوریتم تعیین وضعیت انطباقی (Adaptive State Reconciliation): تضمین برابری
    شیء فیزیکی فعال در RAM با رکوردهای جدول MySQL بدون بازتولید تکراری عناصر.

۲. کالبدشکافی فنی فایل‌ها و نقش هر لایه (Architecture Stack)

resources/admin_vehicles/
├── meta.xml                  # شناسنامه ماژول، تعاریف دسترسی و پیوند فایل‌های ایستا
├── client.lua                # لایه کنترلی کلاینت، نمونه‌سازی مرورگر CEF و مدیریت IPC
├── server.lua                # موتور منطقی بک‌اند، مدیریت استخر اتصالات دیتابیس و اسپاون فیزیکی
└── ui/
    └── index.html            # رابط کاربری تحت وب مدرن (HTML5/CSS3/ES6 Glassmorphic Engine)

+---------------------------------------------------------------------------------+
|                                 CEF Web UI                                      |
|                       (HTML5 / CSS3 / ES6 Logic)                                |
+---------------------------------------------------------------------------------+
                                       |
                   window.mta.triggerEvent (DOM to Lua)
                   executeBrowserJavascript (JSON Payload)
                                       v
+---------------------------------------------------------------------------------+
|                              client.lua                                         |
|                     (GUI Broker / Event Forwarder)                              |
+---------------------------------------------------------------------------------+
                                       |
                         triggerServerEvent (RPC via UDP)
                         triggerClientEvent (Snapshot Sync)
                                       v
+---------------------------------------------------------------------------------+
|                              server.lua                                         |
|                 (ACL Guard / Physics Controller / Cache)                        |
+---------------------------------------------------------------------------------+
                                       |
                          dbQuery / dbExec (Async Worker)
                          Result Callback (Non-blocking)
                                       v
+---------------------------------------------------------------------------------+
|                            MySQL Database                                       |
|                     (InnoDB Engine / UTF8MB4 Schema)                            |
+---------------------------------------------------------------------------------+

۲.۱. فایل تعاریف و فراداده (meta.xml)

این فایل مانیفست اصلی ریسورس است که نسخه اجرایی، اسکریپت‌های سرور و کلاینت و
مسیر بارگذاری فایل‌های محلی وب را مشخص می‌نماید.

۲.۲. لایه واسط تعاملی کاربر (ui/index.html)

رابط کاربری با استانداردهای مدرن فرانت‌اند و بدون اتکا به پکیج‌های سنگین جانبی
توسعه داده شده است:

  - طراحی مبتنی بر شیشه‌گرایی (Glassmorphism) با استفاده از فیلتر پردازشی
    backdrop-filter: blur(15px).
  - ساختار تعاملی تب‌های مجزا برای مدیریت ناوگان موجود و کاتالوگ اسپاون بر اساس
    نگاشت عددی شناسه‌ها.
  - مدیریت مستقیم پاسخ‌های دریافتی با متد updatePanelData(cars, currentCar).

۲.۳. لایه کارگزار کلاینت (client.lua)

این اسکریپت نقش آداپتور و هدایت‌کننده پکت‌ها میان رابط وب و سرور را بر عهده
دارد:

  - Lazy Allocation: بارگذاری و ساخت شیء مرورگر توسط guiCreateBrowser فقط در
    صورت نیاز و احراز هویت اولیه محلی رخ می‌دهد تا حافظه سیستم آزاد بماند.
  - JSON Serialization: داده‌های دریافتی از سرور را به فرمت JSON فشرده تبدیل
    کرده و به متد جاوااسکریپتی مرورگر تزریق می‌کند.

۲.۴. لایه هسته و پردازش منطق سرور (server.lua)

هسته پایدار سیستم که تمامی اختیارات فیزیکی و پایگاه داده را کنترل می‌کند:

  - استخر کش محلی (In-Memory Cache): ثبت موجودیت‌های فعال در ساختار جدول هش
    spawnedVehicles جهت دستیابی به پیچیدگی زمانی \mathcal{O}(1) در عملیات‌های
    روتین.
  - سیستم احراز هویت دومرحله‌ای: استعلام همزمان از پایگاه داده و گروه‌های کنترل
    دسترسی سازمانی سرور (MTA ACL).

۳. چرخه حیات و منطق‌های الگوریتمی حیاتی (Algorithmic Logic)

۳.۱. الگوریتم حل تعارض فضایی و پیشگیری از انفجار (Anti-Detonation Engine)

بارگذاری خام رکوردهای دیتابیس در زمان راه‌اندازی سرور، در صورتی که وسایل نقلیه
از قبل در حافظه حضور داشته باشند، سبب ایجاد دو شیء فیزیکی با مش‌های متقاطع
می‌گردد. موتور فیزیک بازی برای خنثی‌سازی برخورد دو مش صلب هم‌مرکز، نیروی دافعه
بینهایت اعمال کرده که منجر به انفجار خودروها می‌شود.

       [شروع بارگذاری رکوردهای پایگاه داده]
                         │
                         ▼
             [خوانش سطر خودرو (Row)]
                         │
                         ▼
        آیا خودرویی با همین dbid در بازی هست؟
                      /      \
                  (بله)      (خیر)
                   /            \
[استفاده مجدد از شیء]    آیا فاصله‌اش با خودروی دیگر < 2.0m است؟
                  \            /      \
                   \       (بله)      (خیر)
                    \       /            \
          [عدم اسپاون مجدد]     [تثبیت ارتفاع Z + 0.15m]
                    │                    │
                    │           [ساخت شیء فیزیکی createVehicle]
                    │                    │
                    ▼                    ▼
     [به‌روزرسانی ElementData و اعمال متدهای Respawn]

شبه‌کد الگوریتم ممانعت از اسپاون موازی:

local existingVeh = false
for _, v in ipairs(getElementsByType("vehicle")) do
    local vDbId = tonumber(getElementData(v, "dbid")) or tonumber(getElementData(v, "veh:id"))
    if vDbId == rowId then
        existingVeh = v
        break
    else
        local vx, vy, vz = getElementPosition(v)
        if getDistanceBetweenPoints3D(x, y, z, vx, vy, vz) < 2.0 then
            existingVeh = v
            break
        end
    end
end

if isElement(existingVeh) then
    -- تطبیق شیء موجود بدون ایجاد موجودیت فیزیکی جدید (جلوگیری قطعی از انفجار)
    setElementData(existingVeh, "dbid", rowId)
    spawnedVehicles[rowId] = existingVeh
else
    -- اعمال شیفت ایمنی روی محور Z جهت جلوگیری از قفل شدن چرخ‌ها در بافت نقشه
    local veh = createVehicle(model, x, y, z + 0.15, rx, ry, rz, plate)
    setVehicleRespawnPosition(veh, x, y, z + 0.15, rx, ry, rz)
    toggleVehicleRespawn(veh, true)
    spawnedVehicles[rowId] = veh
end

۴. مدل داده و تعامل با پایگاه داده (Data Model & Schema)

۴.۱. شماتیک DDL جدول اصلی پایگاه داده

CREATE TABLE IF NOT EXISTS `server_vehicles` (
    `id` INT UNSIGNED AUTO_INCREMENT,
    `model` SMALLINT UNSIGNED NOT NULL,
    `x` FLOAT(10, 4) NOT NULL,
    `y` FLOAT(10, 4) NOT NULL,
    `z` FLOAT(10, 4) NOT NULL,
    `rx` FLOAT(10, 4) NOT NULL DEFAULT 0.0000,
    `ry` FLOAT(10, 4) NOT NULL DEFAULT 0.0000,
    `rz` FLOAT(10, 4) NOT NULL DEFAULT 0.0000,
    `plate` VARCHAR(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'IRAN',
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    INDEX `idx_model` (`model`),
    INDEX `idx_coords` (`x`, `y`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

۴.۲. تحلیل عملکردی I/O

  - عملیات ناهمگام (Async I/O): تمام کوئری‌ها از طریق صف داخلی dbQuery و
    کالبک‌های مربوطه ارسال می‌شوند. این امر باعث می‌شود فراخوانی‌های سنگین، هیچ
    مکثی (Freeze) در تیک فریم کلاینت‌ها ایجاد نکنند.
  - رویکرد Prepared Statements: در تمام دستورات جهت مقابله قطعی با حملات SQL
    Injection، پارامترها با نماد جایگزین (?) ارسال شده و بایندر داخلی نوع
    متغیرها را اعتبارسنجی می‌کند.

۵. ماتریس امنیت و اعتبارسنجی شبکه (Security Architecture)

۵.۱. مقابله با جعل پکت‌ها و رویدادهای ریموت (Packet Spoofing Defense)

کلاینت آلوده یا هک‌شده می‌تواند رویدادهای سرور نظیر onAdminDeleteVehicle را
مستقیماً فراخوانی کند. سیستم تدابیر امنیتی زیر را در سطح معماری لحاظ کرده است:

[دریافت پکت در لایه شبکه]
           │
           ▼
[استخراج پارامتر رزرو شده client]
           │
           ▼
آیا منبع پکت معتبر و کلاینت فرستنده موجود است؟
          /        \
      (خیر)        (بله)
       /              \
[قطع پردازش پکت]   ارزیابی سطوح دسترسی:
                   1. بررسی getElementData(client, "admin_level")
                   2. پایش گروه ACL ادمین سرور
                      /        \
                  (رد)         (تأیید)
                  /                \
          [انصراف امن]       [اعتبارسنجی نوع ورودی با tonumber()]
                                   │
                                   ▼
                           [اجرای امن رویداد در سرور]

۵.۲. جدول ماتریس امنیت و مجوزها

| بردار حمله / ریسک     | نقطه نفوذ احتمالی          | سازوکار حفاظتی تعبیه‌شده                                      | وضعیت  |
| :-------------------- | :------------------------- | :------------------------------------------------------------ | :----: |
| **Spoofed Source ID** | جعل پارامتر هویت ادمین     | عدم پذیرش هویت ارسالی و اتکا به متغیر سیستمی `client`         | ✅ ایمن |
| **Remote Event Spam** | اجرای متدهای تغییر دیتابیس | سنجش اجباری `getAdminLevel(player) < 0` پیش از هر کوئری       | ✅ ایمن |
| **Type Injection**    | ارسال رشته به عنوان ID     | تبدیل صریح و اعتبارسنجی داده با `tonumber(dbid)`              | ✅ ایمن |
| **SQL Injection**     | دستکاری پکت‌های ورودی      | استفاده انحصاری از Prepared Statements با پارامترهای فرمت‌شده | ✅ ایمن |

۶. تجربیات توسعه و نقشه راه پیشرفت (Extensibility Roadmap)

۶.۱. چالش‌های فنی پشت‌سر گذاشته‌شده

1.  قفل شدن تایرها درون آسفالت بعد از اسپاون: به دلیل خطای گرد کردن اعداد ممیز
    شناور در فایل‌های برخورد نقشه، با تزریق آفست +0.15\text{m} خودرو بدون آسیب
    روی سطح تراز می‌شود.
2.  ارتباط ناهمزمان مرورگر با لوآ: در هنگام شروع به کار مرورگر داخلی، اجرای فوری
    کدهای جاوااسکریپت ممکن بود با شکست مواجه شود؛ با معماری Handshake و رویداد
    onWebReady، انتقال داده تنها پس از تثبیت کامل DOM انجام می‌گیرد.

۶.۲. نقشه راه توسعه‌پذیری (Future Enhancements)

- [ ] فاز ۱ (داده‌های تکمیلی): ثبت خودکار رنگ‌های خودرو، ارتقاهای مکانیکی
  (Tuning)، پینت‌جاب و وضعیت سلامت موتور در فیلد متنی JSON.
- [ ] فاز ۲ (بهینه‌سازی فضایی): ارتقای پیمایش خطی \mathcal{O}(N) عناصر بازی به
  ساختار داده مش‌بندی فضایی (Spatial Hash Grid).
- [ ] فاز ۳ (ثبت وقایع سازمانی): ثبت لاگ تراکنش‌های اداری در جدولی مجزا شامل
  گزارش تغییر موقعیت، حذف یا ایجاد خودرو همراه با آی‌پی و سریال مدیر.

۷. بخش دیاگرام‌های مهندسی بر پایه PlantUML

دیاگرام ۱: معماری کلی و تبادل پیام چندلایه‌ای (Component Architecture Diagram)

@startuml
!theme plain
skinparam componentStyle uml2
skinparam backgroundColor #FAFAFA

package "کلاینت بازی (MTA Client Sandbox)" {
    [مرورگر وب داخلی (CEF)] as CEF #E0F2FE
    interface "mta.triggerEvent()" as JS_Bridge
    [ماژول کنترلر کلاینت (client.lua)] as ClientLua #BAE6FD
    
    CEF -right-> JS_Bridge
    JS_Bridge -right-> ClientLua : رویدادهای DOM
    ClientLua ..> CEF : executeBrowserJavascript()
}

cloud "شبکه امن MTA (UDP Protocol)" {
    interface "triggerServerEvent" as TSE
    interface "triggerClientEvent" as TCE
}

ClientLua --> TSE : ارسال بسته‌های داده به سرور
TCE --> ClientLua : ارسال وضعیت و لیست خودروها

package "سرور اختصاصی (MTA Server Core)" {
    [دروازه اعتبارسنجی دسترسی (ACL Guard)] as Sentinel #FEE2E2
    [موتور منطق خودروها (server.lua)] as CoreEngine #FEF08A
    [کش هش‌مپ حافظه رم (spawnedVehicles)] as MemCache #DCFCE7
    
    TSE --> Sentinel : رهگیری پکت ورودی
    Sentinel --> CoreEngine : تایید هویت کلاینت
    CoreEngine <-> MemCache : خوانش و ثبت سریع در رم
}

database "لایه داده‌های پایدار (MySQL)" {
    [پایگاه داده سرور (server_vehicles)] as DB #F3E8FF
    interface "استخر اتصالات ناهمگام (dbQuery/dbExec)" as DB_API
}

CoreEngine --> DB_API : صدور کوئری غیرمسدودکننده
DB_API --> DB : صف اجرای پس‌زمینه
DB --> DB_API : بازگشت سطرها
DB_API --> CoreEngine : کالبک نتیجه
TCE <-- CoreEngine : پخش داده‌ها به کلاینت
@enduml

دیاگرام ۲: توالی همگام‌سازی و بارگذاری داده از دیتابیس به رابط وب (Sequence Diagram - Data Sync)

@startuml
!theme plain
autonumber
skinparam sequenceMessageAlign center

actor "مدیر سرور" as Admin
boundary "رابط وب (CEF UI)" as UI
control "اسکریپت کلاینت" as CL
control "هسته سرور" as SE
database "پایگاه داده" as DB

Admin -> CL: فشردن کلید F6 / دستور vehpanel
activate CL
CL -> UI: ایجاد شیء مرورگر و نمایش پنجره
activate UI
UI -> CL: مخابره رویداد "onWebReady"
deactivate UI
CL -> SE: triggerServerEvent("requestSavedVehiclesList")
activate SE
SE -> SE: اعتبارسنجی سطح ادمینی (admin_level >= 0)
SE -> DB: dbQuery("SELECT * FROM server_vehicles")
activate DB
DB --> SE: برگرداندن داده ردیف‌های ذخیره‌شده
deactivate DB
SE -> SE: بازبینی خودروهای فعال در حافظه و هماهنگ‌سازی
SE -> CL: triggerClientEvent("receiveSavedVehiclesList", list, currentCar)
deactivate SE
CL -> UI: executeBrowserJavascript("updatePanelData(...)")
activate UI
UI -> UI: پارس داده‌ها و رندر پویای جدول
UI --> Admin: نمایش خودروها و فعال‌سازی دکمه‌ها
deactivate UI
deactivate CL
@enduml

دیاگرام ۳: فلوچارت الگوریتم پیشگیری از اسپاون تکراری و تداخل فیزیک (Activity Diagram)

@startuml
!theme plain
start
:فراخوانی متد بارگذاری خودروها (loadAllVehicles);
:اجرای ناهمگام SELECT * FROM server_vehicles;
:دریافت نتایج در رشته پردازشی دیتابیس;

while (سطر پردازش‌نشده‌ای باقی مانده است؟) is (بله)
    :استخراج مدل و مختصات (x, y, z, rx, ry, rz);
    :پیمایش خودروهای زنده سرور (Loop);
    if (آیا عنصری با همین شناسه دیتابیس وجود دارد؟) then (بله)
        :انتخاب به عنوان شیء موجود;
    else (خیر)
        if (فاصله عنصر زنده تا مختصات مورد نظر < 2.0m ؟) then (بله)
            :انتخاب به عنوان شیء مجاور و دارای تعارض فیزیکی;
        else (خیر)
            :بررسی عنصر بعدی سرور;
        endif
    endif

    if (شیء معتبری در بازی شناسایی شد؟) then (بله)
        #LightGreen:به‌روزرسانی ElementData بدون ساخت شیء جدید;
        :افزودن شیء به جدول هش spawnedVehicles;
    else (خیر)
        #LightYellow:اعمال لایه محافظتی ارتفاع (z = z + 0.15);
        :ساخت عنصر فیزیکی خودرو (createVehicle);
        :تنظیم موقعیت ری‌اسپاون رسمی (setVehicleRespawnPosition);
        :فعال‌سازی Respawn خودکار بر اساس محل پارک;
        :ثبت در آرایه حافظه سرور spawnedVehicles;
    endif
endwhile (خیر)

:ثبت اتمام عملیات در گزارشات سیستمی سرور;
stop
@enduml

دیاگرام ۴: توالی ذخیره‌سازی و پارک خودرو در لحظه (Sequence Diagram - Vehicle Park/Update)

@startuml
!theme plain
autonumber
skinparam sequenceMessageAlign center

actor "مدیر سرور" as Admin
boundary "رابط وب" as UI
control "کلاینت لوآ" as CL
control "سرور لوآ" as SL
database "دیتابیس MySQL" as DB

Admin -> UI: کلیک روی دکمه "ثبت موقعیت پارک"
UI -> CL: triggerMTA("onWebSaveCurrentCar")
CL -> SL: triggerServerEvent("onAdminSaveCurrentOccupiedVehicle")
activate SL

SL -> SL: استخراج خودرو با getPedOccupiedVehicle(client)
alt مدیر داخل هیچ خودرویی نیست
    SL --> Admin: ارسال پیام خطا در چت باکس
else مدیر در خودرو مستقر است
    SL -> SL: استخراج دقیق مختصات مکانی و زاویه دوران
    alt خودرو شناسه دیتابیس دارد (عملیات UPDATE)
        SL -> DB: dbExec("UPDATE server_vehicles SET x=?, y=?, z=?...")
        SL -> SL: setVehicleRespawnPosition()
        SL --> Admin: اعلام به‌روزرسانی موقعیت پارک
    else خودرو جدید است و شناسه ندارد (عملیات INSERT)
        SL -> DB: dbQuery("INSERT INTO server_vehicles (...)")
        activate DB
        DB --> SL: تحویل ID تازه تولیدشده (insertId)
        deactivate DB
        SL -> SL: مقداردهی متادیتای dbid روی خودرو
        SL -> SL: ثبت رفرنس در جدول هش spawnedVehicles
        SL --> Admin: اعلام ثبت دائمی خودرو در پایگاه داده
    end
    SL -> SL: فراخوانی رویداد بازخوانی مجدد لیست
    SL --> CL: ارسال پکت جدید اطلاعات خودروها
    CL --> UI: به‌روزرسانی جدول و نشانگرها در پنل
end
deactivate SL
@enduml

دیاگرام ۵: مدل موجودیت-رابطه پایگاه داده (Entity-Relationship Diagram - ERD)

@startuml
!theme plain
hide circle
skinparam linetype ortho

entity "**accounts**" as acc {
  * **username** : VARCHAR(64) [PK]
  --
  * **admin_level** : INT DEFAULT -1
  * **serial** : VARCHAR(64)
  * **last_login** : TIMESTAMP
}

entity "**server_vehicles**" as sv {
  * **id** : INT UNSIGNED [PK, AUTO_INCREMENT]
  --
  * **model** : SMALLINT UNSIGNED
  * **x** : FLOAT(10,4)
  * **y** : FLOAT(10,4)
  * **z** : FLOAT(10,4)
  * **rx** : FLOAT(10,4)
  * **ry** : FLOAT(10,4)
  * **rz** : FLOAT(10,4)
  * **plate** : VARCHAR(32)
  * **created_at** : TIMESTAMP
  * **updated_at** : TIMESTAMP
}

entity "**MTA_ACL_Groups**" as acl <<Logical System>> {
  * **group_name** : "Admin"
  --
  * **object_entry** : "user." + accountName
}

acc ||..o{ acl : "اعتبارسنجی عضویت در لیست دسترسی"
acc ||..o{ sv : "تغییر و مدیریت ناوگان سرور"
@enduml

دیاگرام ۶: ماشین وضعیت چرخه حیات شیء در حافظه و بازی (State Machine Diagram)

@startuml
!theme plain

[*] --> موقت_در_حافظه : ایجاد خودروی موقت (اسپاون از تب دوم)
[*] --> پایدار_در_دیتابیس : بارگذاری اولیه از رکوردهای جدول

state موقت_در_حافظه {
    description: "عنصر در رم ساخته شده اما در پایگاه داده ثبت نیست"
}

state پایدار_در_دیتابیس {
    state مستقر_در_محل_پارک : حضور در مختصات اصلی تعیین‌شده
    state در_حال_جابجایی : جابجایی در بازی توسط پلیرها یا ادمین
    
    مستقر_در_محل_پارک --> در_حال_جابجایی : سوار شدن و رانندگی
    در_حال_جابجایی --> مستقر_در_محل_پارک : ریست یا ری‌اسپاون (respawnVehicle)
}

موقت_در_حافظه --> پایدار_در_دیتابیس : اجرای دستور پارک (عملیات INSERT)
پایدار_در_دیتابیس --> پایدار_در_دیتابیس : ثبت موقعیت جدید (عملیات UPDATE)

state نشانه‌گذاری_شده {
    description: "مارکر متحرک نئونی و آیکون روی نقشه فعال است"
}

پایدار_در_دیتابیس --> نشانه‌گذاری_شده : کلیک روی فلش ردیاب (onWebToggleMarker)
نشانه‌گذاری_شده --> پایدار_در_دیتابیس : خاموش‌سازی ردیاب

پایدار_در_دیتابیس --> [*] : حذف قطعی از بازی و دیتابیس (onWebDelete)
موقت_در_حافظه --> [*] : خاموش شدن سرور یا انهدام شیء
@enduml

دیاگرام ۷: جریان احراز هویت و پایش دسترسی ادمین (Security Flow Diagram)

@startuml
!theme plain
start
:دریافت بسته شبکه فراخوانی رویداد (RPC Event);
:استخراج متغیر حفاظت‌شده سرور 'client';

if (آیا آبجکت 'client' معتبر و از نوع بازیکن زنده است؟) then (بله)
    :بررسی سطح دسترسی getAdminLevel(client);
    if (سطح دسترسی admin_level >= 0 است؟) then (بله)
        #LightGreen:تأیید مجوز: مجاز به اجرای متد;
        :اعتبارسنجی مقادیر ورودی با تابع tonumber();
        if (شناسه‌ها و ورودی‌ها اعداد معتبر هستند؟) then (بله)
            :اجرای تراکنش پایگاه داده / اعمال تغییر فیزیکی;
            :ارسال بازخورد موفقیت با outputChatBox به مدیر;
        else (خیر)
            #Pink:نادیده گرفتن پکت معیوب و جلوگیری از خطا;
        endif
    else (خیر)
        #Tomato:تلاش دسترسی غیرمجاز: رد کامل پکت;
        stop
    endif
else (خیر)
    #Red:درخواست جعلی و فاقد ارجاع کلاینت: بلوکه شدن آنی;
    stop
endif
stop
@enduml

۸. ارزیابی نهایی و نتیجه‌گیری فنی

ریسورس admin_vehicles با ارائه معماری ایزوله و مستقل، پایداری اشیای سه‌بعدی را
در کنار تجربه کاربری مدرن محقق ساخته است. ممانعت قطعی از تداخلات فیزیکی،
کوئری‌های غیرمسدودکننده بر بستر پایگاه داده MySQL و فیلترینگ شدید بسته‌های شبکه
در سطح سرور، این ماژول را به یک نرم‌افزار قابل اتکا و صنعتی برای سرورهای شلوغ و
پرترافیک مبدل می‌سازد.
