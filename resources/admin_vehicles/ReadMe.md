سند جامع فنی و مهندسی سیستم مدیریت وسایل نقلیه دائمی (Admin Vehicle Management System)

راهنمای کاربردی و مفهوم کلی برای عموم (High-Level Overview)

این سیستم یک جعبه‌ابزار هوشمند و همه‌کاره برای مدیران سرورهای بازی آنلاین MTA:SA
(Multi Theft Auto: San Andreas) است. در سرورهای بازی آنلاین سنتی، هنگامی که
مدیری ماشینی را در بازی ظاهر (اسپاون) می‌کند، با خروج بازیکن یا ری‌استارت شدن
سرور، آن خودرو ناپدید می‌شود؛ یا در حالتی بدتر، اگر دو خودرو روی یک نقطه ظاهر
شوند، موتور فیزیک بازی دچار باگ شده و هر دو خودرو فوراً منفجر می‌شوند!

این ریسورس تمام این مشکلات را برای همیشه حل کرده است:

1.  رابط کاربری شیشه‌ای و مدرن (CEF Web Panel): مدیران با فشردن کلید F6 یک پنجره
    وب شیک، فارسی و بدون لگ باز می‌کنند و تمام ماشین‌های سرور را مانند یک پنل وب
    با جزئیات کامل می‌بینند.
2.  پارک و ذخیره ابدی در پایگاه داده (MySQL Persistence): ادمین می‌تواند سوار هر
    ماشینی شود، آن را در پارکینگ یا جلوی یک اداره قرار دهد و دکمه «ثبت موقعیت»
    را بزند؛ ماشین فوراً در دیتابیس ثبت شده و حتی پس از خاموش و روشن شدن سرور،
    سر جای دقیق خود باقی می‌ماند.
3.  مکانیزم ضد انفجار و ضد اسپاون تکراری (Anti-Detonation Engine): سیستم پیش از
    اسپاون هر ماشین بررسی می‌کند که آیا خودرویی با این شناسه یا در فاصله ۲ متری
    آن نقطه وجود دارد یا خیر. اگر ماشینی بود، به جای ساخت دوباره، همان ماشین
    موجود را احیا و همگام می‌کند تا از پرتاب شدن و انفجار خودروها جلوگیری شود.
4.  ابزارهای ناوبری زنده: امکان تله‌پورت فوری به سمت ماشین، ریست کردن مکان ماشین
    به جای پارک اولیه، حذف کامل از بازی و دیتابیس، و قرار دادن فلش نئونی متحرک و
    مارکر روی نقشه جهت ردیابی موقعیت مکانی.

Platform: MTA:SA Engine: Lua 5.1 UI: CEF / HTML5 Database: MySQL / MariaDB
Security: Dual-Tier Validation Code Architecture: Event--Driven

۱. خلاصه مدیریتی و اهداف طراحی (Executive Summary)

۱.۱. بیان مسئله (Problem Statement)

در معماری کلاینت-سرور پلتفرم Multi Theft Auto (بر پایه موتور فیزیک GTA: San
Andreas)، ماهیت موجودیت‌های محیطی (Elements) به صورت پیش‌فرض فرّار (Volatile) و
وابسته به حافظه رم سرور است. مدیریت موجودیت‌های حیاتی نظیر خودروهای سازمانی
(پلیس، امداد، حمل‌ونقل شهری) با سه چالش بنیادین مواجه بوده است:

  - تداخل اسپاون و انفجار فیزیکی (Physics Collision Detonation): ساخت دو شیء در
    یک حجم فضایی مشترک منجر به انفجار ناشی از برخورد شدید و خطای محاسباتی موتور
    فیزیک صلب (Rigid-body) می‌شود.
  - ناپایداری در چرخه بازنشانی (State Loss on Reboot): نبود چرخه ثبت دائم مختصات
    برداری موقعیت (X, Y, Z) و دوران فضایی (R_x, R_y, R_z).
  - ناکارآمدی رابط‌های کاربری سنتی (Legacy GUI Inefficiency): واسط‌های قدیمی بر
    پایه توابع رندرینگ DX درون‌بازی، فاقد پاسخگویی بصری، واکنش‌گرایی، صفحه‌بندی
    داده‌ها و فیلترینگ بدون افت فریم (Frame Drop) هستند.

۱.۲. راهکار مهندسی (Engineered Solution)

این زیرسیستم یک راه‌حل تمام‌پشته (Full-Stack) برای حل تعارض فیزیک، همگام‌سازی
وضعیت پایگاه‌داده با حافظه زنده سرور و ارائه رابط کاربری فوق‌العاده سریع از طریق
مرورگر توکار کرومیوم (CEF) است. معماری سامانه بر مبنای الگوی جداسازی پردازش
ناهمگام (Non-blocking Asynchronous I/O) و گذرگاه پیام‌رسانی رویدادمحور
(Event-Driven IPC) پیاده‌سازی شده است تا بار پردازشی سرور را روی حلقه اصلی
پردازش (Main Tick Loop) به صفر نزدیک کند.

۲. کالبدشکافی فنی فایل‌ها و نقش لایه‌ها (Technical File Architecture)

resources/admin_vehicles/
├── meta.xml                  # توصیف‌گر ماژول، تعریف سطح دسترسی، بارگذاری فایل‌ها و اسکریپت‌ها
├── client.lua                # پل ارتباطی CEF به موتور سرور، کنترل رندرینگ، مدیریت رویدادهای کاربر
├── server.lua                # موتور منطقی بک‌اند، پردازشگر تراکنش‌های پایگاه داده، احراز هویت و اسپاونر
└── ui/
    └── index.html            # رابط کاربری کلاینت مبتنی بر وب (HTML5/CSS3/ES6 Modern Glassmorphic Dashboard)

۲.۱. توصیف‌گر مانیفست (meta.xml)

تعیین‌کننده سیاست‌های دسترسی و کامپایل منابع. این فایل نقطه ورودی برای ماشین
مجازی کلاینت و سرور بوده و فایل‌های ایستای وب را جهت کش محلی کلاینت تعریف
می‌کند.

۲.۲. لایه واسط تعاملی وب (ui/index.html)

پیاده‌سازی شده بر پایه استانداردهای مدرن فرانت‌اند، بدون وابستگی به فریم‌ورک‌های
حجیم خارجی جهت کمینه‌سازی بار رندرینگ حافظه:

  - پشته فناوری: HTML5 سمانتیک، CSS3 Flexbox/CSS-Grid پیشرفته با افکت
    backdrop-filter: blur().
  - مکانیسم IPC مرورگر: تعامل دوسویه با محیط بازی از طریق آبجکت بومی تزریق‌شده
    window.mta.
  - مدیریت وضعیت لوکال (Local State): کنترل آرایه‌های ساختاری خودروها، تفکیک
    حالت سوار/پیاده، نگاشت شناسه‌های عددی (Model IDs) به اسامی بومی با کمترین
    پیچیدگی زمانی \mathcal{O}(1).

۲.۳. لایه کلاینت لوآ (client.lua)

این لایه به عنوان یک لایه واسط (Broker / Adapter Layer) میان DOM مرورگر کرومیوم
و شبکه بازی عمل می‌کند:

  - تخصیص پویا: نمونه‌سازی تنبل (Lazy Instantiation) کنترلر مرورگر با تابع
    guiCreateBrowser به منظور جلوگیری از مصرف رم قبل از درخواست ادمین.
  - پل ارتباطی داده‌ای: ترجمه پکت‌های سرور به قالب آرایه‌های استاندارد جاوا
    اسکریپت از طریق متد اختصاصی toJSON و فراخوانی آنی executeBrowserJavascript.
  - مدیریت ورودی‌ها: کنترل تمرکز ماوس و کلیدهای میانبر نظیر F6 و کامند اختصاصی
    /vehpanel.

۲.۴. لایه سرور لوآ (server.lua)

هسته پردازشی و مدیر پایگاه داده:

  - ارتباط با دیتابیس: برقراری کانکشن پول پایدار با درایور درونی dbConnect روی
    پروتکل MySQL با انکودینگ کامل utf8mb4.
  - مدیریت حافظه کش محلی (In-Memory Lookup): دیکشنری‌های لوکال spawnedVehicles،
    adminMarkers و adminBlips جهت پیشگیری از فراخوانی کوئری‌های پرهزینه دیتابیس
    و بهینه‌سازی دسترسی در زمان \mathcal{O}(1).
  - سازمان‌دهنده احراز هویت: پایش ترکیبی سطوح دسترسی شامل گروه مدیران سیستم
    داخلی (MTA ACL) و فیلد پایگاه داده متمرکز accounts.admin_level.

۳. چرخه حیات و منطق‌های الگوریتمی حیاتی (Algorithmic Logic)

        موقعیت مورد نظر اسپاون (X, Y, Z)
                     │
                     ▼
          آیا شناسه دیتابیس قبلاً
         در حافظه رم ثبت شده است؟
                /          \
            (بله)          (خیر)
              /              \
    بازیابی رفرنس شیء       آیا عنصری در شعاع
    از جدول هش محلی          r < 2.0m قرار دارد؟
                             /           \
                         (بله)           (خیر)
                           /               \
         تطبیق شیء موجود به عنوان     ساخت عنصر فیزیکی جدید
         خودروی دیتابیس بدون ساخت مجدد    با متغیر ارتفاع Z + 0.15m
                           \               /
                            \             /
                             ▼           ▼
                         همگام‌سازی فراداده‌ها
                     (ElementData Sync & Respawn Set)

۳.۱. مسئله انفجار دوقلوها و الگوریتم حل تعارض فضایی (Anti-Explosion Logic)

در موتور بازی، بارگذاری کورکورانه سوابق پایگاه داده در صورت ری‌استارت ریسورس
موجب می‌شود وسایل نقلیه‌ای که پیش‌تر توسط کلاینت رندر شده‌اند، مجدداً در همان
مختصات تکرار شوند. برخورد همپوشان مش‌های سه‌بعدی برخورد فیزیکی (Collision Boxes)
موجب آزاد شدن ناگهانی انرژی الاستیک توسط موتور Havok/RenderWare و در نتیجه پرتاب
و انفجار قطعی وسیله می‌گردد.

الگوریتم حل تعارض در متد loadAllVehicles:

1.  بررسی شناسه یکتای داده‌ای: پیمایش تمامی وسایل نقلیه سطح سرور
    (getElementsByType("vehicle")) و مقایسه متادیتای dbid با سوابق جدول
    server_vehicles.
2.  پایش همسایگی مجاورتی (Proximity Check): محاسبه فاصله اقلیدسی فضایی:
    D = \sqrt{(x_2 - x_1)^2 + (y_2 - y_1)^2 + (z_2 - z_1)^2}
3.  در صورتی که D < 2.0\text{m} باشد، شیء موجود به عنوان بازنمایی فیزیکی همان
    سطر دیتابیس شناخته می‌شود و از فراخوانی متد createVehicle ممانعت به عمل
    می‌آید.
4.  تراز ارتفاعی ایمن (Z-Axis Elevation Cushion): اعمال ضریب +0.15\text{m} یا
    +0.5\text{m} در هنگام بارگذاری جهت خنثی‌سازی فرورفتگی تایرها در مش‌های
    نامنظم زمین سرور.

۳.۲. فرآیند ذخیره‌سازی و تثبیت در لحظه (Instant Position Committing)

با اجرای /park یا کلیک روی رابط کاربری وب، وضعیت شیء به‌صورت اتمیک ارزیابی
می‌شود:

  - در صورتی که خودرو پیش‌تر ثبت شده باشد (dbid != nil): یک کوئری UPDATE مختصات
    جدید را روی شناسه موجود می‌نشاند.
  - در صورتی که خودرو یک نمونه موقت باشد (dbid == nil): تراکنش INSERT ایجاد شده،
    شناسه انتسابی (insertId) به عنوان متادیتای هویتی به عنصر بازی پیوست می‌شود و
    خودرو بلافاصله به وضعیت «دائمی» ارتقا می‌یابد.

۴. مدل داده و تعامل با پایگاه داده (Data Model & Schema)

۴.۱. اسکیما DDL پایگاه داده

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
    INDEX `idx_spatial` (`x`, `y`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

۴.۲. ملاحظات بهینه‌سازی و معماری I/O

  - موتور ذخیره‌سازی InnoDB: استفاده از قفل‌گذاری سطحی (Row-level Locking) جهت
    ممانعت از ایجاد گلوگاه روی عملیات همزمان خواندن/نوشتن.
  - عملیات ناهمگام (Non-blocking Asynchronous Queries): استفاده از متدهای
    dbQuery و dbExec توکار سرور که در رشته‌های پردازشی مجزا (Worker Threads)
    اجرا شده و با مکانیزم Callback نتایج را پس از آزادسازی به Thread اصلی سرور
    تحویل می‌دهند تا تیک‌ریت (Tick-rate) سرور همواره روی حداکثر مقدار ثابت
    بماند.

۵. ماتریس امنیت، سطوح مجوز و اعتبارسنجی شبکه (Security Architecture)

۵.۱. مدل تهدید پکت‌های دستکاری‌شده (Remote Packet Tampering)

کلاینت دستکاری‌شده (Hacked Client) با دسترسی مستقیم به کنسول اجرای اسکریپت یا
حافظه می‌تواند بدون باز کردن پنل گرافیکی، اقدام به انتشار رویدادهای سرور نظیر
onAdminDeleteVehicle یا onAdminCreatePermanentVehicle با آرگومان‌های مخرب کند.

۵.۲. سیاست‌های دفاع در عمق (Defense-in-Depth Mechanisms)

| تهدید امنیتی                                   | روش اعتبارسنجی در کالبد کدهای ارائه‌شده                                                                 | وضعیت محافظت   |
| :--------------------------------------------- | :------------------------------------------------------------------------------------------------------ | :------------: |
| **جعل مبدأ درخواست (Origin Spoofing)**         | ارزیابی شناسه کلاینت با متغیر حفاظت‌شده سرور: `local player = client` (عدم اعتماد به پارامترهای کلاینت) | پیاده‌سازی شده |
| **تزریق ریموت بدون دسترسی (Unauthorized RPC)** | سنجش اجباری `getAdminLevel(player) < 0` در تمام توابع مقصد رویدادها                                     | پیاده‌سازی شده |
| **ارتقای دسترسی محلی (Client Data Tampering)** | تأیید هویت مجدد سمت سرور بر مبنای جدول `accounts` و اعتبارسنجی با `isObjectInACLGroup`                  | پیاده‌سازی شده |
| **تزریق SQL (SQL Injection)**                  | استفاده انحصاری از Prepared Statements با پارامترهای جایگزین (`?`) در تمام دستورات                      | پیاده‌سازی شده |
| **سرریز نوع داده (Type Mismatch/Overflow)**    | تبدیل و اعتبارسنجی اجباری تمام شناسه‌های ورودی از طریق `tonumber()` پیش از مصرف                         | پیاده‌سازی شده |

۶. تجربیات توسعه، چالش‌های فنی و نقشه راه توسعه‌پذیری (Engineering Roadmap)

۶.۱. چالش‌های فنی شناسایی‌شده در کد فعلی

1.  پیچیدگی زمانی پیمایش عناصر در هنگام بارگذاری: تابع loadAllVehicles در هر
    تکرار حلقه خودروهای ثبت‌شده، کل عناصر بازی را با
    getElementsByType("vehicle") جستجو می‌کند. این منطق دارای پیچیدگی
    \mathcal{O}(M \times N) است که در صورت بالا رفتن تعداد عناصر سرور به بیش از
    ۱۰۰۰، موجب تاخیر در لود اولیه می‌شود.
2.  پایش فاصله تک‌نقطه‌ای: پایش مجاورت فقط در ۲ متر ابتدایی بررسی می‌شود، در
    حالی که خودروهای طویل نظیر تریلرها و اتوبوس‌ها (DFT-30، Linerunner) به شعاع
    خطای بیشتری بر پایه هیت‌باکس (Bounding Sphere) نیاز دارند.

۶.۲. نقشه راه فازهای آتی (Extensibility Roadmap)

- [ ] فاز اول (Refactoring): بازنویسی نگاشت خودروهای حافظه از پیمایش خطی به
  ساختار داده Spatial Hash Grid / Quadtree برای کاهش مرتبه به \mathcal{O}(1).
- [ ] فاز دوم (Extended Attributes): افزودن ذخیره‌سازی رنگ‌های RGB بدنه،
  ارتقاهای تیونینگ (Modifications / Upgrades)، میزان سلامت موتور (health) و
  آسیب‌های بدنه به ستون JSON درون دیتابیس.
- [ ] فاز سوم (Audit Logging System): ایجاد جدول لاگ تراکنش‌های اداری
  (admin_vehicle_logs) با جزئیات دقیق فعالیت‌ها، شناسه ادمین، زمان وقوع و آدرس
  IP جهت مقاصد ردیابی و امنیت.

۷. مستندات مهندسی بصری بر پایه PlantUML

دیاگرام ۱: معماری کلی و تبادل پیام چندلایه‌ای (Component/Architecture Diagram)

این دیاگرام تفکیک لایه‌های معماری نرم‌افزار، رابط‌های مرزی میان وب، هسته محلی
سیستم و پایگاه داده، و الگوی فراخوانی ناهمگام را تشریح می‌کند.

@startuml
!theme plain
skinparam componentStyle uml2
skinparam backgroundColor #FAFAFA
skinparam ArrowColor #0284C7
skinparam InterfaceBorderColor #0369A1

package "Client Environment (Sandboxed)" {
    [Chromium Embedded Framework (CEF)] as CEF <<UI Layer>> #E0F2FE
    interface "mta.triggerEvent()" as JS_Bridge
    [Client Lua Controller] as ClientLua <<Broker Layer>> #BAE6FD
    
    CEF -right-> JS_Bridge
    JS_Bridge -right-> ClientLua : Dispatches DOM Events
    ClientLua ..> CEF : executeBrowserJavascript()
}

cloud "MTA Networking Layer" {
    interface "triggerServerEvent" as TSE
    interface "triggerClientEvent" as TCE
}

ClientLua --> TSE : Secure Serialized Packets
TCE --> ClientLua : Push Entity Snapshot

package "Server Environment (Host Dedicated)" {
    [Event Dispatcher & ACL Sentinel] as Sentinel <<Security>> #FEE2E2
    [Vehicle Engine Controller] as CoreEngine <<Domain Logic>> #FEF08A
    [Local Memory Hash Maps] as MemCache <<RAM Layer>> #DCFCE7
    
    TSE --> Sentinel : Intercepts Remote Calls
    Sentinel --> CoreEngine : Validates client auth
    CoreEngine <-> MemCache : O(1) Cache Lookup
}

database "Persistent Storage" {
    [MySQL Database] as DB <<InnoDB Engine>> #F3E8FF
    interface "MTA Asynchronous DB API" as DB_API
}

CoreEngine --> DB_API : dbQuery / dbExec
DB_API --> DB : Non-blocking Thread Pool
DB --> DB_API : Returns Query Handler Result
DB_API --> CoreEngine : Callback with Hydrated Rows
TCE <-- CoreEngine : Broadcasts Reconciled State
@enduml

دیاگرام ۲: توالی همگام‌سازی و بارگذاری داده از دیتابیس به رابط وب (Sequence Diagram - Data Sync)

این سناریو نمایش‌دهنده توالی کامل واکشی اطلاعات از لحظه بازگشایی رابط گرافیکی تا
رندر داده‌ها روی جدول HTML5 است.

@startuml
!theme plain
autonumber
skinparam sequenceMessageAlign center
skinparam BoxPadding 10

actor "Admin (Client)" as Admin
boundary "CEF Web UI" as UI
control "Client Lua" as CL
control "Server Engine" as SE
database "MySQL Server" as DB

Admin -> CL: کلید F6 یا دستور /vehpanel
activate CL
CL -> UI: ایجاد یا نمایش پنجره وب
activate UI
UI -> CL: رویداد "onWebReady"
deactivate UI
CL -> SE: triggerServerEvent("requestSavedVehiclesList", resourceRoot)
activate SE
SE -> SE: ارزیابی سطح دسترسی (Admin Level Check)
alt مجوز نامعتبر است (admin_level < 0)
    SE --> CL: عدم پاسخ یا پیام خطای عدم دسترسی
else احراز هویت موفق
    SE -> DB: dbQuery("SELECT * FROM server_vehicles ORDER BY id DESC")
    activate DB
    DB --> SE: برگرداندن سطرهای رکوردهای ذخیره شده
    deactivate DB
    SE -> SE: پایش انطباق وسایل نقلیه موجود در RAM
    SE -> SE: سنجش خودروی فعلی ادمین (Occupied Vehicle)
    SE -> CL: triggerClientEvent("receiveSavedVehiclesList", list, currentCar)
    deactivate SE
    CL -> UI: executeBrowserJavascript("updatePanelData(...)")
    activate UI
    UI -> UI: پارس JSON و رندر ساختار DOM جدول خودروها
    UI --> Admin: نمایش داده‌های زنده و دکمه‌های عملیاتی
    deactivate UI
end
deactivate CL
@enduml

دیاگرام ۳: فلوچارت الگوریتم پیشگیری از اسپاون تکراری و تداخل فیزیک (Activity Diagram)

تشریح الگوریتم تعیین وضعیت اسپاون ایمن جهت ممانعت قطعی از انفجار دوقلوهای فیزیکی
در هسته بازی.

@startuml
!theme plain
start
:فراخوانی متد بارگذاری خودروها (loadAllVehicles);
:ارسال کوئری SELECT * FROM server_vehicles;
:دریافت نتایج در Thread اختصاصی دیتابیس;

while (آیا سطری برای پردازش باقی مانده است؟) is (بله)
    :استخراج مشخصات (id, model, x, y, z, rx, ry, rz);
    :پیمایش تمام وسایل نقلیه فعال در سرور (Loop);
    if (آیا خودرویی با همین dbid ثبت شده است؟) then (بله)
        :شناسایی به عنوان existingVeh;
    else (خیر)
        if (فاصله خودرو تا نقطه spawn < 2.0m ؟) then (بله)
            :شناسایی به عنوان existingVeh (احتمال همپوشانی فیزیکی);
        else (خیر)
            :پیمایش حلقه بعدی ادامه یابد;
        endif
    endif

    if (آیا existingVeh معتبر در بازی وجود دارد؟) then (بله)
        #LightGreen:به‌روزرسانی ElementData بدون ساخت مجدد;
        :ثبت رفرنس در هش‌مپ داخلی spawnedVehicles;
    else (خیر)
        #LightYellow:اعمال ضریب ایمنی ارتفاع (z = z + 0.15);
        :فراخوانی createVehicle();
        :تنظیم دیمنشن و اینتریور به صفر;
        :تنظیم موقعیت ری‌اسپاون قانونی (setVehicleRespawnPosition);
        :افزودن شیء ایجادشده به هش‌مپ spawnedVehicles;
    endif
endwhile (خیر)

:ثبت گزارش نهایی در DebugString سرور;
stop
@enduml

دیاگرام ۴: توالی ذخیره‌سازی و پارک خودرو در لحظه (Sequence Diagram - Vehicle Park/Update)

فرآیند ثبت مختصات فضایی جدید خودروی در حال سواری یا ایجاد رکورد دائمی جدید برای
ماشین‌های موقت سرور.

@startuml
!theme plain
autonumber
skinparam sequenceMessageAlign center

actor "Admin" as Admin
boundary "CEF Dashboard" as UI
control "Client Lua" as CL
control "Server Logic" as SL
database "Database" as DB

Admin -> UI: کلیک روی دکمه "ثبت موقعیت پارک"
UI -> CL: triggerMTA("onWebSaveCurrentCar")
CL -> SL: triggerServerEvent("onAdminSaveCurrentOccupiedVehicle")
activate SL

SL -> SL: واکشی خودرو از طریق getPedOccupiedVehicle(client)
alt مدیر پیاده است
    SL --> Admin: ارسال پیام خطای الزامی بودن حضور در خودرو
else مدیر سوار بر خودرو است
    SL -> SL: استخراج مختصات (x,y,z) و زوایا (rx,ry,rz)
    SL -> SL: بررسی متادیتای موجودیت (dbid)
    
    alt خودرو قبلاً شناسه پایگاه داده دارد (Update Mode)
        SL -> DB: dbExec("UPDATE server_vehicles SET x=?,y=?,z=? WHERE id=?", ...)
        SL -> SL: setVehicleRespawnPosition(veh, x, y, z, rx, ry, rz)
        SL --> Admin: نمایش پیام "موقعیت پارک آپدیت شد"
    else خودرو موقت است و شناسه ندارد (Insert Mode)
        SL -> DB: dbQuery("INSERT INTO server_vehicles (...) VALUES (...)")
        activate DB
        DB --> SL: تحویل insertId رکورد جدید
        deactivate DB
        SL -> SL: پیوست داده‌ها (setElementData: dbid, isPermanent)
        SL -> SL: ثبت در متغیر محلی spawnedVehicles[insertId]
        SL --> Admin: نمایش پیام "خودرو در دیتابیس ثبت شد"
    end
    
    SL -> SL: triggerEvent("requestSavedVehiclesList", client)
    SL --> CL: ارسال لیست به‌روزشده خودروها
    CL --> UI: بازسازی سطرها و به‌روزرسانی نمای پنل
end
deactivate SL
@enduml

دیاگرام ۵: مدل موجودیت-رابطه پایگاه داده (Entity-Relationship Diagram - ERD)

تعریف ساختار جداول، وابستگی‌های ارتباطی و نوع فیلدهای کلیدی پایگاه داده سیستم.

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

entity "**MTA_ACL_Groups**" as acl <<Virtual Registry>> {
  * **group_name** : "Admin"
  --
  * **object_entry** : "user." + accountName
}

acc ||..o{ acl : "اعتبارسنجی سطح دسترسی سیستم"
acc ||..o{ sv : "تغییر و مدیریت به عنوان کارشناس ارشد"
@enduml

دیاگرام ۶: ماشین وضعیت چرخه حیات شیء در حافظه و بازی (State Machine Diagram)

مدل‌سازی وضعیت‌های انتزاعی یک خودرو از زمان تعاریف اولیه تا امحا از سیستم فیزیکی
و پایگاه داده.

@startuml
!theme plain
skinparam state {
    BackgroundColor #F8FAFC
    BorderColor #64748B
    ArrowColor #0F172A
}

[*] --> Transient_Memory : اسپاون موقت توسط ادمین (onWebSpawnNew)
[*] --> Database_Row : بارگذاری اولیه از دیتابیس موجود

state Transient_Memory {
    description: "خودرو در رم وجود دارد ولی فاقد ID دیتابیس است."
}

state Permanent_Synchronized {
    description: "شناسه دیتابیس دارد، به حافظه لوکال سرور متصل است."
    
    state Parked_At_Base : خودرو در مختصات پیش‌فرض پارک قرار دارد
    state Displaced_Driven : خودرو توسط بازیکنان رانده شده و جابجا شده است
    
    Parked_At_Base --> Displaced_Driven : حرکت فیزیکی در جهان بازی
    Displaced_Driven --> Parked_At_Base : ریست مختصات (respawnVehicle)
}

Transient_Memory --> Permanent_Synchronized : اجرای دستور /park (عملیات INSERT)
Permanent_Synchronized --> Permanent_Synchronized : به‌روزرسانی مکان پارک (UPDATE)

state Marked_Tracked {
    description: "مارکر نئونی بالای سقف و علامت نقشه (Blip) فعال است."
}

Permanent_Synchronized --> Marked_Tracked : فعال‌سازی ردیاب (onWebToggleMarker)
Marked_Tracked --> Permanent_Synchronized : غیرفعال‌سازی یا ساخت مارکر جدید

Permanent_Synchronized --> [*] : حذف قطعی از دیتابیس و انهدام عنصر فیزیکی (onWebDelete)
Transient_Memory --> [*] : خاموش شدن سرور یا انهدام شیء بدون ذخیره
@enduml

دیاگرام ۷: جریان احراز هویت و پایش دسترسی ادمین (Security Flow Diagram)

جریان تأیید اعتبار درخواست‌های ریموت و ایزولاسیون کامل هسته سرور از دستکاری‌های
غیرمجاز پکت‌های شبکه کلاینت.

@startuml
!theme plain
start
:کلاینت رویدادی ارسال می‌کند (مثال: onAdminDeleteVehicle);
:موتور سرور متغیر پنهان 'client' را استخراج می‌کند;

if (آیا 'client' معتبر بوده و از نوع 'player' است؟) then (بله)
    :فراخوانی getAdminLevel(client);
    :واکشی getElementData(client, "admin_level");
    if (admin_level >= 0 ؟) then (بله)
        #LightGreen:مجوز تأیید شد: پردازشگر رویداد اجرا می‌شود;
        :اعتبارسنجی نوع آرگومان ورودی (tonumber(dbid));
        if (آیا پارامترها ساختار معتبر عددی دارند؟) then (بله)
            :اجرای تراکنش دیتابیس و حذف عنصر از سرور;
            :ارسال تأییدیه با outputChatBox به مدیر;
        else (خیر)
            #Pink:رد پکت ناهنجار و نادیده‌گرفتن دستور;
        endif
    else (خیر)
        #Tomato:تلاش غیرمجاز: رد بسته شبکه و پایان;
        stop
    endif
else (خیر)
    #Red:پکت دستکاری‌شده بدون رفرنس بازیکن: نابودی آنی پکت;
    stop
endif
stop
@enduml

۸. نتیجه‌گیری و ارزیابی فنی (Technical Conclusion)

ریسورس مهندسی‌شده admin_vehicles با بهره‌گیری از معماری لایه‌ای مدرن و تلفیق
مرورگر تعبیه‌شده کرومیوم (CEF) با پردازش رویدادمحور Lua و پایداری‌سازی در MySQL،
راهکاری جامع، فوق‌سریع و با پایداری صنعتی جهت مدیریت وسایل نقلیه دائمی ارائه
می‌کند.

به‌کارگیری تکنیک‌های مقایسه شعاع مکانی و همگام‌سازی فراداده‌های هویتی پیش از
ایجاد اشیا، خطای ذاتی برخورد موتور فیزیک بازی سنتی را ریشه‌کن کرده و ساختار
غیرمسدودکننده توابع داده‌ای، پیوستگی عملکرد تیک‌های پردازشی سرور (Stable
Tick-Rate) را حتی تحت بارهای محاسباتی سنگین کاملاً تضمین می‌نماید.
