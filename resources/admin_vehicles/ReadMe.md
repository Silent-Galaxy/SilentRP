مستند فنی و جامع سیستم مدیریت وسایل نقلیه (Admin Vehicles System)

پروژه: SilentRP — MTA:SA
ماژول: resources/admin_vehicles
سطح سند: کارشناسی مهندسی کامپیوتر / نرم‌افزار
سازگار با: PlantUML استاندارد جهت رندر مستقیم در editor.plantuml.com

۱. بیانیه هدف و خلاصه اجرایی (Executive Summary)

خواست سازنده و چرایی توسعه این ماژول

در سرورهای Roleplay پلتفرم Multi Theft Auto (MTA:SA)، مدیریت وسایل نقلیه
سازمانی، عمومی و ایستا (Static Spawns) مانند خودروهای پلیس، آمبولانس، تاکسی‌ها و
مشاغل شهری نیازمند راه‌حلی پایدار (Persistent) است. در حالت عادی ادمین‌ها
ناچارند با کامندهای متنی طولانی (نظیر ساخت، ست کردن مختصات دستی در فایل‌های
کانفیگ، ری‌استارت مداوم سرور یا اسکریپت) کار کنند.

خواست سازنده:

1.  ساخت رابط کاربری مدرن (CEF / HTML-CSS-JS) به جای GUIهای قدیمی MTA.
2.  ثبت در لحظه مکان خودرو در دیتابیس بدون نیاز به کدنویسی یا ثبت دستی مختصات
    X, Y, Z.
3.  حل قطعی باگ تکرار ماشین (Vehicle Stacking / Duplication) و ترکیدن ماشین‌ها
    در هنگام ری‌استارت یا کرش اسکریپت.
4.  فراهم‌سازی قابلیت ردگیری (Tracking/Blip)، تلپورت فوری و ریست مکان فیزیکی
    وسایل نقلیه برای ادمین‌ها.

۲. مشخصات ساختاری فایل‌ها و ماتریس عملکرد

| نام فایل        | لایه معماری                      | وظیفه اصلی                                                                                                                                             |
| :-------------- | :------------------------------- | :----------------------------------------------------------------------------------------------------------------------------------------------------- |
| `meta.xml`      | متا دیتا و مانیفست               | تعریف ماژول برای Core سرور، مشخص‌سازی اسکریپت‌های کلاینت/سرور و نشانی فایل وب (`ui/index.html`)                                                        |
| `server.lua`    | لایه داده و منطق سرور (Back-end) | برقراری ارتباط با MySQL، اعتبارسنجی سطح دسترسی ادمین (ACL/DB)، جلوگیری از اسپاون تکراری، انجام کوئری‌های CRUD و دستکاری عناصر در دنیا (World Entities) |
| `client.lua`    | لایه ارتباطی کلاینت (Bridge)     | کنترل پنجره مرورگر CEF، مدیریت کلید میانبر `F6` و کامند، هدایت داده‌ها بین JS و Lua کلاینت، ارسال ایونت‌های امن به سرور                                |
| `ui/index.html` | لایه نمایش (Front-end/CEF)       | رابط کاربری مدرن نئونی Glassmorphism، نگاشت شناسه مدل‌ها به اسامی فارسی، رندر جدول داده‌ها، تب اسپاون سریع و تعامل متقابل از طریق `mta.triggerEvent`   |

۳. هفت دیاگرام مهندسی سیستم (قابل رندر مستقیم در PlantUML)

دیاگرام ۱: دیاگرام توالی باز کردن پنل و بارگذاری داده‌ها (Sequence Diagram)

زاویه دید: جریان کنترل و تبدیل انواع داده‌ها بین چهار لایه سیستم.

@startuml
autonumber
actor Admin as "مدیر (Admin)"
participant ClientLua as "Client (client.lua)"
participant CEF as "CEF Browser (index.html)"
participant ServerLua as "Server (server.lua)"
database MySQL as "پایگاه داده MySQL"

Admin -> ClientLua: فشردن کلید F6 / تایپ vehpanel/
ClientLua -> ClientLua: بررسی شرط دسترسی ادمین (admin_level >= 0)
ClientLua -> CEF: guiCreateBrowser & بارگذاری ui/index.html
CEF -> ClientLua: رویداد onWebReady (DOMContentLoaded)
ClientLua -> ServerLua: triggerServerEvent("requestSavedVehiclesList")
ServerLua -> ServerLua: اعتبارسنجی سطح ادمین فرستنده (client)
ServerLua -> MySQL: SELECT * FROM server_vehicles ORDER BY id DESC
MySQL --> ServerLua: بازگردانی آرایه رکوردها
ServerLua -> ServerLua: ساخت لایه Vehicle Objects و بررسی وجود خودرو در مموری
ServerLua -> ClientLua: triggerClientEvent("receiveSavedVehiclesList", list, currentCar)
ClientLua -> CEF: executeBrowserJavascript("updatePanelData(...)")
CEF --> Admin: رندر جدول شناسه، نام، زمان‌ها و دکمه‌های کنترلی
@enduml

دیاگرام ۲: مدل موجودیت-ارتباط پایگاه داده (Entity Relationship Diagram - Crow's Foot)

زاویه دید: معماری داده‌ها، محدودیت‌ها و شمای جدول‌ها در دیتابیس موتور رابطه‌ای.

@startuml
skinparam linetype ortho

entity "accounts" as accounts {
  * id : INT <<PK, AUTO_INCREMENT>>
  --
  * username : VARCHAR(64) <<UNIQUE>>
  admin_level : INT <<DEFAULT -1>>
}

entity "server_vehicles" as sv {
  * id : INT <<PK, AUTO_INCREMENT>>
  --
  * model : INT
  * x : FLOAT
  * y : FLOAT
  * z : FLOAT
  * rx : FLOAT
  * ry : FLOAT
  * rz : FLOAT
  plate : VARCHAR(32) <<DEFAULT 'IRAN'>>
  created_at : TIMESTAMP <<DEFAULT CURRENT_TIMESTAMP>>
  updated_at : TIMESTAMP <<ON UPDATE CURRENT_TIMESTAMP>>
}

accounts ||..o{ sv : "مدیریت و ثبت فیزیکی"
@enduml

دیاگرام ۳: نمودار ماشین وضعیت چرخه حیات خودرو (State Machine Diagram)

زاویه دید: تبدیل وضعیت یک وسیله نقلیه از حالت موقت، ثبت دیتابیس تا ریسپان یا
تخریب نهایی.

@startuml
[*] --> SpawnedTemp : ادمین کلیک می‌کند روی اسپاون (تب ۲)

state SpawnedTemp {
  [*] --> InWorldNonPersistent
  InWorldNonPersistent : dbid = nil
  InWorldNonPersistent : خودرو موقت در حافظه RAM
}

SpawnedTemp --> StoredInDB : سوار شدن + کلیک دکمه ثبت پارک
state StoredInDB {
  [*] --> IdleParked
  IdleParked --> MovedByPlayer : سوار شدن بازیکن و رانندگی
  MovedByPlayer --> ParkUpdated : اجرای کامند park/ یا دکمه بروزرسانی
  ParkUpdated --> IdleParked : ثبت مختصات جدید در MySQL
  MovedByPlayer --> IdleParked : ریست پوزیشن یا ریسپان (respawnVehicle)
}

StoredInDB --> Destroyed : کلیک دکمه حذف (Delete)
Destroyed --> [*] : dbExec DELETE + destroyElement
@enduml

دیاگرام ۴: دیاگرام مؤلفه و معماری سیستم (Component Diagram)

زاویه دید: معماری تفکیک لایه‌ای و کانال‌های بین‌پروسسی (IPC/RPC).

@startuml
package "Client Machine (MTA Client Engine)" {
  [Input Subsystem] --> [client.lua] : Key F6 / Command
  package "CEF Subsystem" {
    [Chromium Engine] - [index.html / CSS / JS]
  }
  [client.lua] <..> [Chromium Engine] : executeBrowserJavascript / mta.triggerEvent
}

package "Server Machine (MTA Server Host)" {
  [client.lua] <--> [server.lua] : Latent Events / RPC Protocol
  
  package "Core Logic Modules" {
    [Anti-Explosion Sync Engine] - [server.lua]
    [Entity Tracker (Markers/Blips)] - [server.lua]
    [Access Control Layer (ACL)] - [server.lua]
  }

  database "MySQL Database 8.x" {
    [server_vehicles table]
    [accounts table]
  }
  [server.lua] --> [MySQL Database 8.x] : dbConnect / dbQuery (Pool non-blocking)
}
@enduml

دیاگرام ۵: دیاگرام جریان منطقی پیشگیری از اسپاون تکراری (Activity Diagram - Anti-Stacking Engine)

زاویه دید: الگوریتم ابداعی فایل server.lua برای جلوگیری از روی‌هم افتادن و
انفجار خودروها.

@startuml
start
:فراخوانی تابع loadAllVehicles();
:ارسال کوئری SELECT * FROM server_vehicles;
:دریافت لیست رکوردهای ذخیره شده;

while (آیا رکورد بررسی نشده وجود دارد؟) is (بله)
  :خواندن مختصات (X, Y, Z) و شناسه dbid رکورد;
  :جستجو در تمامی Vehicle های فعال مموری;
  if (خودرویی با همان dbid یا فاصله < 2 متر وجود دارد؟) then (بله، خودرو موجود است)
    :اتصال شناسه dbid به آبجکت فعال موجود;
    :همگام‌سازی ElementData بدون ساخت شی جدید;
    note right: جلوگیری کامل از Stacking و برخورد فیزیکی (انفجار)
  else (خیر، شی مفقود است)
    :اجرای تابع createVehicle در مختصات Z + 0.15;
    :تنظیم پارامترهای پایدار (Dimension 0, Respawn Coords);
    :ذخیره آبجکت در جدول spawnedVehicles;
  endif
endwhile (خیر)

:ثبت گزارش نهایی در DebugString سرور;
stop
@enduml

دیاگرام ۶: دیاگرام موارد کاربرد (Use Case Diagram)

زاویه دید: تعامل مدیر و سیستم با وظایف تفکیک‌شده.

@startuml
left to right direction
actor "ادمین سرور (Admin)" as admin
actor "موتور دیتابیس (MySQL Engine)" as db

rectangle "سیستم مدیریت وسایل نقلیه (admin_vehicles)" {
  usecase "احراز هویت و بررسی رنک ادمین" as UC_Auth
  usecase "مشاهده کاتالوگ و ثبت ماشین پایدار جدید" as UC_Create
  usecase "ثبت مجدد مختصات پارک با نشستن در ماشین" as UC_Park
  usecase "رهگیری فیزیکی (مارکر نئونی + Blip در نقشه)" as UC_Track
  usecase "تلپورت مستقیم به بالای سر خودرو" as UC_Teleport
  usecase "بازگردانی سریع موقعیت (Respawn to Origin)" as UC_Reset
  usecase "حذف خودرو از جهان فیزیکی و پایگاه داده" as UC_Delete
}

admin --> UC_Auth
admin --> UC_Create
admin --> UC_Park
admin --> UC_Track
admin --> UC_Teleport
admin --> UC_Reset
admin --> UC_Delete

UC_Park ..> db : UPDATE Coords
UC_Create ..> db : INSERT Row
UC_Delete ..> db : DELETE Row
UC_Auth ..> db : SELECT admin_level
@enduml

دیاگرام ۷: دیاگرام استقرار سخت‌افزاری و نرم‌افزاری (Deployment Diagram)

زاویه دید: توزیع فایل‌ها، پورت‌ها و جریان داده‌ها در محیط عملیاتی شبکه.

@startuml
node "Client Node (Player PC)" {
  artifact "DirectX 9 / MTA Rendering Pipeline" as RenderPipe
  node "Chromium Embedded Framework (CEF)" {
    file "index.html (HTML5, CSS3, ES6)" as UIAsset
  }
  file "client.lua" as ClientScript
  UIAsset -down-> ClientScript : CEF Binding
  ClientScript -> RenderPipe : Draw Call
}

node "Dedicated Server (Linux / Windows)" {
  node "MTA Server Executable" {
    file "server.lua" as ServerScript
    file "meta.xml" as MetaAsset
    component "Virtual World Engine (MTA Elements)" as WorldEngine
  }
  
  database "MySQL RDBMS Host" {
    portin "Port 3306" as P3306
    database "mta_db" as MTADatabase
  }
}

ClientScript <..> ServerScript : Net-Traffic (UDP Port 22003 / RakNet)
ServerScript --> WorldEngine : Entity Instantiation
ServerScript --> P3306 : TCP MySQL Driver
P3306 --> MTADatabase : CRUD Operations
@enduml

۴. پاسخ تفصیلی به سوالات استانداردسازی‌شده مهندسی

۱. ارتباط با دیتابیس به چه شکل مهندسی شده است؟

ارتباط از طریق درایور رسمی داخلی dbConnect به شکل غیرهمگام (Asynchronous) به
موتور MariaDB/MySQL متصل است:

  - برای کوئری‌های واکشی (SELECT) از تابع dbQuery و ارسال کالبک (Callback
    function) با dbPoll(qh, -1) استفاده شده تا ترد اصلی گیم سرور بلاک نشود
    (Non-blocking I/O).
  - برای عملیات دستکاری داده‌ها نظیر تغییر مختصات یا حذف، از dbExec مجهز به
    Prepared Statements (?) استفاده شده تا به طور کامل از نفوذ از طریق SQL
    Injection جلوگیری شود.

۲. اطلاعات ذخیره‌شده در دیتابیس شامل چه مواردی است؟

جدول server_vehicles مقادیر زیر را نگهداری می‌کند:

  - id: شناسه یکتا خودرو در دیتابیس (Primary Key).
  - model: شناسه مدلی خودرو (۴۰۰ تا ۶۱۱ در موتور GTA:SA).
  - x, y, z و rx, ry, rz: مختصات کامل ۳ بعدی فضایی و زوایای چرخش (Rotation)
    خودرو در جهان بازی.
  - plate: متن پلاک فیزیکی (به طور پیش‌فرض IRAN).
  - created_at و updated_at: ثبت خودکار زمان سیستم به تفکیک ثانیه با نوع زمانی
    TIMESTAMP.

۳. این ایده برای چه محیط و زمانی مناسب است؟

  - زمان بهره‌برداری: فاز پیکربندی و راه‌اندازی سرورهای Roleplay/RPG و استقرار
    پایگاه‌های فکشن‌های مختلف (پلیس، مدیک، مکانیک، تاکسی‌رانی، ارتش).
  - مکان: مناسب سرورهایی که با تراکم بالای وسایل نقلیه سازمانی مواجهند و
    می‌خواهند بدون ری‌استارت سرور یا ثبت تک‌تک مختصات از طریق فایل متنی XML،
    مکان پارکینگ‌ها را به صورت بصری و زنده تغییر دهند.

۴. تجربیات کسب‌شده در توسعه این ماژول

  - پیاده‌سازی تکنیک Dual-Verification Anti-Explosion: پیشگیری از تخریب و انفجار
    شیفت‌های هم‌پوشان وسایل نقلیه از طریق اعمال z + 0.15 در هنگام اسپاون اولیه و
    چک کردن فاصله اقلیدسی ۲ متری قبل از ایجاد شیء تکراری.
  - معماری تعامل CEF بدون ایجاد Memory Leak، با استفاده صحیح از فرمت استاندارد
    تبادل JSON میان Lua و موتور Chromium Javascript.

۵. ارزیابی امنیتی و فنی

  - احراز هویت دومرحله‌ای ادمین: سطح دسترسی با خواندن مقدار admin_level هم در
    کلاینت (پیش از رندر UI) و هم مجدداً در سرور (پیش از اجرای هر رویداد حساس)
    بررسی می‌شود تا دستکاری در کلاینت (Memory Injection / Executor) نتواند
    فرامین ساختگی به سرور تزریق کند.
  - استفاده از پارامترسازی کوئری‌ها: هیچ رشته خامی با دستور الحاق (..) مستقیماً
    درون رشته SQL قرار نگرفته است.

۶. وابستگی‌ها به سایر ریسورس‌های پروژه

  - وابستگی اصلی به سیستم مدیریت حساب‌های کاربری (accounts) سرور از طریق جدول
    پایگاه داده، جهت خواندن و تایید فیلد admin_level.
  - در صورت نیاز به هماهنگی با گاراژهای شخصی سرور، این ماژول با تزریق مقدار
    isPermanent = true در ElementData به دیگر اسکریپت‌ها تفهیم می‌کند که این
    وسیله نقلیه یک خودروی اداری/سازمانی است و نباید توسط سیستم‌های حذف خودکار
    (Vehicle Cleaner / Auto Respawn) از بین برود.

۵. راهنمای نصب و راه‌اندازی سریع

1.  پیکربندی پایگاه داده: اطلاعات سرور دیتابیس شامل نام کاربری، رمز عبور و نام
    دیتابیس را در خط اول فایل server.lua تنظیم کنید:
    local db = dbConnect("mysql", "dbname=mta_db;host=127.0.0.1;port=3306;charset=utf8mb4", "root", "PASSWORD")
2.  پوشه‌بندی: ریسورس را داخل مسیر resources/[admin]/admin_vehicles قرار دهید.
3.  فراخوانی در کنسول سرور:
    refresh
    start admin_vehicles
4.  کلید میانبر در بازی: با اکانت ادمین وارد شده و دکمه F6 را بفشارید یا کامند
    /vehpanel را در چت تایپ کنید.
