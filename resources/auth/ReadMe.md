# 🛡️ Aurora Auth & Citizen Dossier System

### ورود

![ورود](image.png)

### ثبت نام

![ثبت نام](image-1.png)

### فراموشی رمز

![فراموشی رمز](image-2.png)

### بخش درون بازی پنل کاربر
![بخش اول](image-3.png)
![بخش دوم](image-4.png)
![بخش سوم](image-5.png)
![بخش چهارم](image-6.png)

### بخش درون بازی پنل مدیریت
![بخش اول](image-7.png)
![بخش دوم](image-8.png)
![بخش سوم](image-9.png)

> سامانه نسل جدید احراز هویت، امنیت داده، کنترل پنل شهروندی (F2) و مدیریت یکپارچه سرور بر بستر **MTA: San Andreas (CEF + MySQL)**

---

## 📌 فهرست مطالب
- [💡 درباره پروژه و ایده شکل‌گیری](#-درباره-پروژه-و-ایده-شکل‌گیری)
- [🎯 هدف توسعه‌دهنده](#-هدف-توسعه‌دهنده)
- [🎮 تجربه کاربری گام‌به‌گام (User Flow)](#-تجربه-کاربری-گام‌به‌گام-user-flow)
- [⚙️ پشت صحنه کد (Under The Hood)](#️-پشت-صحنه-کد-under-the-hood)
- [🌟 امکانات شاخص](#-امکانات-شاخص)
- [⚖️ مزایا و معایب سیستم](#️-مزایا-و-معایب-سیستم)
- [📂 ساختار پوشه‌ها و فایل‌ها](#-ساختار-پوشه‌ها-و-فایل‌ها)
- [🚀 راهنمای نصب و راه‌اندازی](#-راهنمای-نصب-و-راه‌اندازی)
- [⌨️ کلیدها و میان‌برها](#️-کلیدها-و-میان‌برها)

---

## 💡 درباره پروژه و ایده شکل‌گیری
بسیاری از سیستم‌های ثبت‌نام در MTA از واسط‌های کاربری قدیمی (GUI دکمه‌ای) استفاده کرده و از استانداردهای نوین امنیت وب و تجربه کاربری (UX) محروم هستند.  
**Aurora Auth** با هدف پر کردن این خلاء طراحی شده است؛ این سیستم یک پلتفرم دوگانه است:
1. **دروازه ورود و عضویت (Gateway UI):** پیاده‌سازی‌شده با CEF و وب مدرن (HTML5/CSS3/JS)، بررسی بلادرنگ سختی رمز، احراز هویت با سریال سخت‌افزاری و ورود خودکار امن.
2. **داشبورد شهروندی و ادمین (F2 Control Panel):** یک پنل چندمنظوره که شناسنامه، امنیت نشست‌ها، تاریخچه لاگین‌ها، سامانه زیرمجموعه‌گیری و ابزارهای مانیتورینگ آنلاین مدیریت را بدون افت فریم (FPS) در اختیار می‌گذارد.

---

## 🎯 هدف توسعه‌دهنده
- **حذف حملات Brute-Force و اسپم:** قفل هوشمند لاگین با تکیه بر نرخ درخواست (Rate Limit) و سریال اختصاصی هر بازیکن.
- **جلوگیری از ساخت چند اکانت (Multi-Account):** انحصار هر حساب به سریال سخت‌افزاری معتبر کاربر.
- **پیوند قوانین و ورود:** اجبار بازیکن به مطالعه و تایید نسخه جدید قوانین قبل از اجازه ورود به گیم‌پلی.
- **شفافیت نشست‌ها برای بازیکن:** امکان مشاهده آی‌پی‌ها و زمان‌های لاگین قبلی برای کشف سوءاستفاده‌های احتمالی از اکانت.
- **مدیریت بدون دستورات متنی خسته‌کننده:** اعمال بن، میوت و تنظیم دسترسی‌ها به صورت گرافیکی و لحظه‌ای توسط تیم سرپرستی.

---

## 🎮 تجربه کاربری گام‌به‌گام (User Flow)

```mermaid
graph TD
    A[ورود به سرور] --> B{توکن ورود خودکار معتبر است؟}
    B -- بله --> C{نسخه قوانین به‌روز است؟}
    B -- خیر --> D[نمایش صفحه لاگین / ثبت‌نام مدرن]
    D --> E[ورود مشخصات + ارزیابی رمز عبور]
    E --> C
    C -- نسخه قدیمی است --> F[نمایش پنجره قوانین و دریافت تاییدیه]
    C -- تایید شده --> G[اسپاون بازیکن + بارگذاری موقعیت و پول]
    F --> G
    G --> H[فشردن کلید F2: باز شدن داشبورد شهروندی]
```

### ۱. ورود بازیکن به سرور
- دوربین بازی روی نمایی دلنشین از شهر قفل شده و کرسر ماوس آزاد می‌شود.
- اگر بازیکن گزینه **«مرا به خاطر بسپار»** را فعال کرده باشد، توکن رمزنگاری‌شده از حافظه محلی مرورگر (`localStorage`) خوانده شده و لاگین خودکار ظرف چند میلی‌ثانیه بدون تایپ مجدد انجام می‌شود.

### ۲. ثبت‌نام یا بازیابی رمز
- هنگام تایپ رمز عبور، **آنالیزور بلادرنگ** فعال می‌شود: بررسی طول (حداقل ۸ کاراکتر)، ترکیب حروف بزرگ و کوچک، ارقام و علائم خاص (`@#$%`).
- فیلد اختیاری کد معرف (Referral) پاداش شروع ($۱۵۰۰ برای کاربر جدید و $۵۰۰۰ برای معرف) را محاسبه و اعمال می‌کند.

### ۳. تایید نسخه‌بندی قوانین سرور
- در صورتی که مدیر سرور نسخه جدیدی از قوانین را منتشر کرده باشد، فرآیند ورود متوقف شده و پنجره قوانین نمایش داده می‌شود؛ کاربر پس از مطالعه و زدن دکمه تایید، وارد بازی می‌شود.

### ۴. بازی و استفاده از پنل F2
- بازیکن با زدن کلید **F2** داشبورد شیشه‌ای تاریک را باز می‌کند:
  - **شناسنامه:** مشاهده دارایی، تاریخ ثبت‌نام، وضعیت تایید ایمیل/موبایل و رتبه شهروندی.
  - **امنیت دوره‌ای:** تعیین بازه زمانی برای بی‌اعتبار شدن نشست (مثلاً الزام به وارد کردن مجدد رمز هر ۱، ۳، ۷، ۱۵ یا ۳۰ روز یک‌بار).
  - **نشست‌ها:** جدول کامل آخرین لاگین‌ها به همراه IP، سریال سیستم، ساعت و وضعیت تلاش ناموفق/موفق.
  - **زیرمجموعه‌ها:** آمار افرادی که با کد معرف او وارد شده‌اند و سود حاصله.
  - **خروج اضطراری همگانی (Global Purge):** در شرایط بحرانی، کادر مدیریت اخطار ۵ دقیقه‌ای تایمردار بالای صفحه به کل بازیکنان نمایش می‌دهد و در پایان زمان، دیتای همه امن ذخیره شده و به صفحه لاگین بازمی‌گردند.

---

## ⚙️ پشت صحنه کد (Under The Hood)

### ساختار ماژولار و تفکیک وظایف
پروژه بر اساس استاندارد معماری پاک (Clean Architecture) در MTA بازنویسی شده است:
- **`core/db.lua`:** آغازگر دیتابیس MySQL. جدول `accounts` و `account_login_logs` را با تمامی ایندکس‌ها به‌صورت اتوماتیک و در صورت عدم وجود ایجاد می‌نماید.
- **`core/security.lua`:** 
  - بررسی وقفه لاگین (`cooldownMs = 500ms`).
  - ردیابی تلاش‌های ناموفق تا ۵ بار؛ در صورت عبور، سریال به مدت ۲۵ ثانیه بلاک می‌شود.
  - ساخت توکن هش ۶۴ کاراکتری ترکیب‌شده با زمان سرور و اعداد تصادفی:
    $$\text{Token} = \text{SHA256}(\text{Username} + \text{Serial} + \text{TickCount} + \text{Random})$$
- **`modules/account/`:** مدیریت ثبت داده، وریفای لاگین، همگام‌سازی موقعیت (`X, Y, Z, Rotation, Skin, Money`) و بررسی وضعیت مسدودیت اکانت (`is_banned`).
- **`modules/panel/`:** لایه سرور کوئری‌های پیچیده تو در تو برای استخراج لاگ‌ها، لیست زیرمجموعه‌ها، دریافت لیست ادمینی بدون فشار به CPU و اعمال دستورات مدیریتی (`Kick`, `Ban`, `Mute`, `Save Perms`).

---

## 🌟 امکانات شاخص

| بخش | ویژگی | توضیح فنی |
| :--- | :--- | :--- |
| **امنیت** | Brute-force Shield | ردیابی تعداد تلاش‌ها در حافظه موقت سرور بر اساس سریال بازیکن |
| **امنیت** | Session Expiry Cycle | امکان انتخاب انقضای خودکار نشست (۱ الی ۳۰ روز) در دیتابیس |
| **رابط کاربری** | Dynamic Password Meter | سنجش Regex زنده در فرانت‌اند با انیمیشن تغییر رنگ نوار وضعیت |
| **مدیریت** | Global Purge Alert | سیستم اخطار ۳۰۰ ثانیه‌ای با نوار گرافیکی DX Render و خروج خودکار امن |
| **اقتصاد** | Referral Tree | اعطای پاداش دوطرفه با جلوگیری از سوءاستفاده از کد معرف خود کاربر |
| **یکپارچگی** | Rule Enforcement Hook | جلوگیری از ورود کاربرانی که آخرین نسخه قوانین را نپذیرفته‌اند |

---

## ⚖️ مزایا و معایب سیستم

### ✅ مزایا
1. **تجربه کاربری بی‌نقص (Modern UX):** فونت‌های استاندارد، دکمه‌های ریسپانسیو و تم دارک متناسب با بازی‌های روز.
2. **امنیت چندلایه:** ترکیب اعتبارسنجی سریال سخت‌افزاری، آی‌پی و رمزنگاری SHA256.
3. **بهینه‌سازی منابع (Zero Lag):** بستن مرورگر CEF پس از ورود به بازی و پاک‌سازی کامل حافظه رم کلاینت تا زمان فشردن مجدد F2.
4. **قابلیت شخصی‌سازی:** تمام مقادیر اسپاون اولیه، پاداش رفرال و متغیرهای امنیتی داخل فایل اختصاصی `config.lua` متمرکز شده‌اند.

### ❌ معایب و نیازمندی‌ها
1. **نیاز به وب‌سرور داخلی MTA:** به دلیل استفاده از کدهای جاوااسکریپت، نیازمند فعال بودن ماژول CEF در کلاینت کاربران است (سیستم‌های بسیار ضعیف ممکن است ۱ ثانیه تاخیر اولیه بارگذاری داشته باشند).
2. **وابستگی به سرویس MySQL:** جهت استفاده از سیستم باید دیتابیس MySQL آنلاین و متصل باشد و از SQLite محلی پشتیبانی نمی‌کند.

---

## 📂 ساختار پوشه‌ها و فایل‌ها

```text
resources/auth/
├── meta.xml                          # مانیفست ریسورس و معرفی اسکریپت‌ها
├── config.lua                        # تنظیمات دیتابیس، مختصات اسپاون و امنیت
├── core/
│   ├── db.lua                        # مدیریت کانکشن MySQL و ساخت خودکار جداول
│   └── security.lua                  # آنتی بروت‌فورس، توکن‌ها و بررسی سطح دسترسی
├── modules/
│   ├── account/
│   │   ├── client_auth.lua           # مدیریت CEF لاگین و رویدادهای کلاینت
│   │   └── server_auth.lua           # لاجیک ثبت‌نام، لاگین و پاداش رفرال
│   └── panel/
│       ├── client_panel.lua          # مدیریت کلید F2 و رندر تایمر اخطار امنیتی
│       └── server_panel.lua          # دریافت آمار دشبورد، ادمین اکشن‌ها و خروج همگانی
└── ui/
    ├── index.html                    # فرانت‌اند فرم لاگین / ثبت‌نام / فراموشی رمز
    └── panel.html                    # فرانت‌اند کنترل پنل شهروندی و ادمینی F2
```

---

## 🚀 راهنمای نصب و راه‌اندازی

### ۱. پیش‌نیازها
- نصب سرور **MTA:SA 1.5.9** یا بالاتر.
- سرور دیتابیس **MySQL 5.7+** یا **MariaDB**.

### ۲. پیکربندی دیتابیس
فایل `config.lua` را باز کرده و اطلاعات پایگاه‌داده خود را وارد کنید:
```lua
Config = {
    db = {
        type = "mysql",
        host = "127.0.0.1",
        port = 3306,
        name = "mta_db",
        user = "root",
        pass = "YOUR_PASSWORD",
        charset = "utf8"
    },
    -- سایر تنظیمات اسپاون و رفرال
}
```

### ۳. نصب ریسورس
1. پوشه `auth` را در مسیر `server/mods/deathmatch/resources/` کپی کنید.
2. به کنسول سرور مراجعه کرده و دستورات زیر را وارد نمایید:
```bash
refresh
start auth
```
*(تمامی جداول به صورت خودکار با شروع ریسورس در دیتابیس ایجاد خواهند شد).*

---

## ⌨️ کلیدها و میان‌برها

| کلید / دستور | عملکرد | دسترسی |
| :---: | :--- | :---: |
| <kbd>F2</kbd> | باز و بسته کردن داشبورد جامع شهروندی و امنیت | همگانی |
| <kbd>Shift</kbd> + <kbd>F2</kbd> | محافظت در برابر تداخل باز شدن پنل هنگام بررسی قوانین ادمین | هوشمند |
| **Tab Login/Register** | سوییچ آنی بین فرم ورود، عضویت و فراموشی رمز | صفحه اول |

---






---

## 📊 تحلیل دیاگرامی پروژه (PlantUML Diagrams)

> کدهای زیر با استاندارد [PlantUML](https://editor.plantuml.com/) نگارش شده‌اند. می‌توانید هر قطعه‌کد را در ادیتور آنلاین PlantUML کپی کنید تا نمای گرافیکی آن تولید شود.

---

### ۱. دیاگرام توالی احراز هویت و ورود خودکار (Sequence Diagram)
![اول](image-10.png)
این دیاگرام چرخه کامل تعامل میان کلاینت وب (CEF)، اسکریپت‌های کلاینت/سرور، مکانیزم Rate-Limit، ارزیابی توکن و تایید قوانین فعال را نشان می‌دهد.

```plantuml
@startuml
autonumber
skinparam style strictuml
skinparam SequenceMessageAlignment center

actor "بازیکن" as User
participant "CEF Browser\n(index.html)" as UI
participant "Client Lua\n(client_auth.lua)" as C_Auth
participant "Server Lua\n(server_auth.lua)" as S_Auth
participant "Security Core\n(security.lua)" as Sec
database "MySQL DB\n(accounts & rules)" as DB

User -> UI: ورود به سرور / فشردن دکمه ورود
alt توکن خودکار در LocalStorage موجود است
    UI -> C_Auth: emitMTA("auth:clientAutoLogin", user, token)
    C_Auth -> S_Auth: triggerServerEvent("auth:requestAutoLogin")
else لاگین دستی
    UI -> C_Auth: emitMTA("auth:clientSubmit", user, pass, rememberMe)
    C_Auth -> S_Auth: triggerServerEvent("auth:requestLogin")
end

S_Auth -> Sec: isRateLimited(serial)
alt تلاش بیش از حد مجاز (> 5 بار)
    Sec --> S_Auth: خطا: قفل ۲۵ ثانیه‌ای
    S_Auth -> C_Auth: triggerClientEvent("auth:response", false, پیام خطا)
    C_Auth -> UI: showResponse(false, error)
else نرخ مجاز است
    S_Auth -> DB: استعلام مشخصات کاربر (Username / Password Hash)
    DB --> S_Auth: بازگشت رکورد حساب
    alt حساب مسدود است (is_banned = 1)
        S_Auth -> C_Auth: اعلام مسدودی و دلیل بن
        C_Auth -> UI: نمایش هشدار بن
    else بررسی تطابق نسخه قوانین
        S_Auth -> DB: SELECT MAX(version) FROM server_rules
        DB --> S_Auth: آخرین نسخه قوانین
        alt قوانین جدید تایید نشده
            S_Auth -> C_Auth: باز کردن مودال پذیرش قوانین
            User -> UI: مطالعه و تایید قوانین
            UI -> S_Auth: triggerServerEvent("auth:serverAcceptRules")
        end
        S_Auth -> DB: بروزرسانی last_login, serial و ساخت توکن جدید
        S_Auth -> C_Auth: triggerClientEvent("auth:loginSuccess")
        C_Auth -> UI: انهدام Browser و فعال‌سازی کنترل‌ها
        S_Auth -> User: اسپاون کاراکتر و بارگذاری دارایی
    end
end
@enduml
```

---

### ۲. دیاگرام فعالیت ثبت‌نام و توزیع پاداش معرف (Activity Diagram)
![دوم](image-11.png)
این دیاگرام مسیر تصمیم‌گیری در زمان ساخت حساب جدید شامل فیلتر سریال تکراری، سیستم ضد تقلب رفرال و تزریق پاداش مالی به معرف و کاربر تازه وارد را تشریح می‌کند.

```plantuml
@startuml
start
:ورود اطلاعات کاربری (User, Pass, Email, Phone, Referral);
:اعتبارسنجی فرانت‌اند (Regex ایمیل و آنالیز قدرت رمز عبور);

if (اطلاعات در کلاینت معتبر است؟) then (بله)
  :ارسال به سرور با Serial و IP سخت‌افزاری;
  :بررسی محدودیت زمانی و حملات اسپم (Rate-Limiter);
  
  if (آیا با این سریال قبلاً اکانت ساخته شده؟) then (بله)
    :رد درخواست: "شما قبلاً با این سیستم حساب ساخته‌اید!";
    stop
  else (خیر)
    if (نام کاربری قبلاً ثبت شده؟) then (بله)
      :رد درخواست: "این نام کاربری رزرو است!";
      stop
    else (خیر)
      :محاسبه پاداش اولیه پایه ($1000);
      if (کد معرف وارد شده و معتبر است؟) then (بله)
        :افزایش موجودی کاربر جدید با بونوس رفرال (+$1500);
        :واریز کمیسیون به حساب صاحب کد معرف (+$5000);
      else (خیر)
        :ادامه با موجودی پایه;
      endif
      :تولید هش SHA256 رمز عبور;
      :ثبت اکانت در جدول accounts با نسخه قوانین فعال;
      :ثبت لاگ موفق در جدول account_login_logs;
      :اسپاون بازیکن در مختصات تعریف‌شده در Config;
      stop
    endif
  endif
else (خیر)
  :نمایش خطای محلی روی فرم ورودی;
  stop
endif
@enduml
```

---

### ۳. دیاگرام ساختار کامپوننت‌ها و جریان داده (Component Diagram)
![سوم](image-12.png)
نمایش دهنده تفکیک لایه‌های کاربری، لایه ارتباطی رخدادهای ام‌تی‌ای (Event-Driven)، ماژول‌های منطقی و لایه ذخیره‌سازی داده.

```plantuml
@startuml
skinparam componentStyle uml2

package "لایه مرورگر داخلی (CEF Front-End)" {
    [Login UI (index.html)] as IndexUI
    [Dashboard UI (panel.html)] as PanelUI
    [Password Analyzer Engine] as PassMeter
    IndexUI ..> PassMeter : استفاده
}

package "کلاینت بازی (MTA Client-Side Lua)" {
    [client_auth.lua] as C_AuthMod
    [client_panel.lua] as C_PanelMod
    [DX Render Countdown Engine] as DXEngine
    C_PanelMod ..> DXEngine : کنترل رندر
}

package "هسته و ماژول‌های سرور (Server-Side Lua)" {
    [server_auth.lua] as S_AuthMod
    [server_panel.lua] as S_PanelMod
    [security.lua] as SecurityCore
    [db.lua] as DBCore
    [config.lua] as AppConfig
    
    S_AuthMod ..> SecurityCore : احراز صلاحیت
    S_PanelMod ..> SecurityCore : بررسی سطح ادمین
    S_AuthMod ..> AppConfig : دریافت مقادیر اولیه
    S_PanelMod ..> AppConfig : دریافت پارامترها
    S_AuthMod ..> DBCore : تراکنش اطلاعات
    S_PanelMod ..> DBCore : استعلام و ویرایش
}

database "MySQL Database" {
    folder "جداول داده" {
        [accounts]
        [account_login_logs]
        [server_rules]
        [user_rule_acceptances]
    }
}

IndexUI <--> C_AuthMod : CEF ExecuteJS / triggerEvent
PanelUI <--> C_PanelMod : CEF ExecuteJS / triggerEvent
C_AuthMod <--> S_AuthMod : triggerServerEvent / triggerClientEvent
C_PanelMod <--> S_PanelMod : triggerServerEvent / triggerClientEvent
DBCore <--> [accounts] : dbExec / dbQuery
DBCore <--> [account_login_logs] : dbExec
DBCore <--> [server_rules] : dbQuery
@enduml
```

---

### ۴. دیاگرام مدل داده و پایگاه‌داده (Entity Relationship Diagram)
![چهارم](image-13.png)
ساختار جداول پایگاه داده رابطه‌ای، فیلدهای کلیدی، تایپ‌ها و نحوه پیوند سوابق لاگ، رفرال‌ها و اعتبارسنجی قوانین.

```plantuml
@startuml
skinparam linetype ortho

entity "accounts" as acc {
    * id : INT <<PK, AUTO_INCREMENT>>
    --
    * username : VARCHAR(64) <<UNIQUE>>
    * password : VARCHAR(64) [SHA256]
    * email : VARCHAR(128)
    phone_number : VARCHAR(32)
    * serial : VARCHAR(64)
    last_serial : VARCHAR(64)
    referred_by : VARCHAR(64)
    money : INT
    skin : INT
    x : FLOAT
    y : FLOAT
    z : FLOAT
    rotation : FLOAT
    remember_token : VARCHAR(128)
    registered_date : TIMESTAMP
    last_login : TIMESTAMP
    admin_level : INT
    session_expire_days : INT
    accepted_rules_version : INT
    is_banned : TINYINT(1)
    ban_reason : VARCHAR(255)
    banned_by : VARCHAR(64)
    is_muted : TINYINT(1)
    mute_reason : VARCHAR(255)
    admin_perms : TEXT
    email_verified : TINYINT(1)
    phone_verified : TINYINT(1)
}

entity "account_login_logs" as logs {
    * id : INT <<PK, AUTO_INCREMENT>>
    --
    * account_id : INT <<FK>>
    * ip : VARCHAR(64)
    * serial : VARCHAR(64)
    * status : VARCHAR(32)
    login_time : TIMESTAMP
}

entity "server_rules" as rules {
    * id : INT <<PK, AUTO_INCREMENT>>
    --
    * version : INT
    * title : VARCHAR(255)
    * content : TEXT
    created_by : VARCHAR(64)
    created_at : TIMESTAMP
    is_active : TINYINT(1)
}

entity "user_rule_acceptances" as rule_acc {
    * id : INT <<PK, AUTO_INCREMENT>>
    --
    * account_id : INT <<FK>>
    * rule_version : INT
    accepted_at : TIMESTAMP
}

acc ||--o{ logs : "ثبت نشست‌ها"
acc ||--o{ rule_acc : "سوابق تایید قوانین"
rules ||--o{ rule_acc : "نسخه ارجاعی"
acc ||--o{ acc : "معرفی زیرمجموعه (referred_by)"
@enduml
```

---

### ۵. دیاگرام ماشین حالت چرخه حیات بازیکن (State Machine Diagram)
![پنجم](image-14.png)
این دیاگرام کلیه حالات بازیکن از نخستین لحظه اتصال به سرور، مسدودیت، پذیرش قوانین، حضور در بازی، ورود به پنل F2 تا سناریوی تخلیه اضطراری را تحلیل می‌کند.

```plantuml
@startuml
[*] --> Disconnected

state "متصل به سرور (بدون هویت)" as Connecting {
    [*] --> InitGatewayUI
    InitGatewayUI: مسدودسازی Binds و قفل دوربین
    InitGatewayUI: نمایش واسط لاگین/ثبت‌نام CEF
}

Connecting --> Authenticating : ارسال درخواست لاگین/اتو لاگین

state Authenticating <<choice>>
Authenticating --> Banned : is_banned == 1
Authenticating --> RulesCheck : اطلاعات کاربری معتبر است
Authenticating --> Connecting : اطلاعات اشتباه / مسدودی با Brute-force

state "صفحه مسدودیت دائم" as Banned {
    Banned: نمایش دلیل مسدودیت و نام مدیر
}

state "بررسی نسخه قوانین" as RulesCheck <<choice>>
RulesCheck --> PendingRulesModal : accepted_rules_version < active_rule_version
RulesCheck --> InGame : قوانین از قبل تایید شده است

state "پنجره اجباری تایید قوانین" as PendingRulesModal {
    PendingRulesModal: قفل فرآیند اسپاون
    PendingRulesModal: انتظار برای کلیک دکمه پذیرش قوانین
}
PendingRulesModal --> InGame : تایید نسخه جدید قوانین

state "درون بازی (In-Game Gameplay)" as InGame {
    [*] --> CitizenFreeroam
    CitizenFreeroam: بازگردانی دوربین به کاراکتر
    CitizenFreeroam: فعال‌سازی Bindها و کنترل پلیر
    
    CitizenFreeroam --> ControlPanelOpen : فشردن کلید F2
    ControlPanelOpen --> CitizenFreeroam : بستن کلید F2
}

state "داشبورد شهروندی و امنیت (F2 Panel)" as ControlPanelOpen {
    ControlPanelOpen: مرور شناسنامه، مدیریت نشست و لاگ‌ها
    ControlPanelOpen: ویرایش رمز، ایمیل و روزهای انقضای نشست
}

InGame --> UnderPurgeAlert : فعال‌سازی خروج همگانی توسط ادمین
state "هشدار تخلیه همگانی (Purge Active)" as UnderPurgeAlert {
    UnderPurgeAlert: نمایش بنر شمارش معکوس ۳۰۰ ثانیه‌ای با DX
    UnderPurgeAlert: ذخیره‌سازی داده‌های حیاتی (Position, Cash)
}

UnderPurgeAlert --> Connecting : انقضای زمان ۳۰۰ ثانیه / انتقال به دایمنشن ۹۹۹
InGame --> Disconnected : خروج از بازی (ذخیره مشخصات در دیتابیس)
ControlPanelOpen --> Connecting : کلیک روی "خروج از حساب (Logout)"
@enduml
```

---

### ۶. دیاگرام موارد کاربرد (Use Case Diagram)
![ششم](image-15.png)
تفکیک دقیق سطوح دسترسی میان کاربران مهمان (ثبت‌نام‌نشده)، شهروندان عادی و اعضای کادر مدیریت سرور.

```plantuml
@startuml
left to right direction
skinparam packageStyle rectangle

actor "کاربر مهمان (Guest)" as Guest
actor "شهروند (Citizen)" as User
actor "مدیر سرور (Staff / Admin)" as Admin

User -up-|> Guest
Admin -up-|> User

rectangle "سامانه احراز هویت و امنیت (Gateway)" {
    usecase "ورود با نام و رمز عبور" as UC_Login
    usecase "ورود خودکار امن (Auto-Login Token)" as UC_AutoLogin
    usecase "ثبت‌نام با ارزیابی سختی رمز" as UC_Register
    usecase "معرفی کد رفرال و دریافت بونوس" as UC_Referral
    usecase "بازیابی رمز عبور با ایمیل" as UC_Forgot
    usecase "مطالعه و پذیرش قوانین نسخه‌بندی‌شده" as UC_Rules
}

rectangle "کنترل پنل کاربری و مدیریت (F2 Panel)" {
    usecase "مشاهده شناسنامه و وضعیت استعلام" as UC_Dossier
    usecase "تنظیم چرخه انقضای نشست (۱ تا ۳۰ روز)" as UC_ExpireConfig
    usecase "بازبینی لاگ‌های ورود و آی‌پی‌ها" as UC_AuditLogs
    usecase "مشاهده آمار زیرمجموعه‌ها" as UC_RefStats
    usecase "خروج امن از اکانت (Logout)" as UC_Logout
    usecase "مدیریت کاربران (Ban / Mute / Perms)" as UC_AdminManage
    usecase "آغاز خروج اضطراری سرور (Global Purge)" as UC_GlobalPurge
}

Guest --> UC_Login
Guest --> UC_AutoLogin
Guest --> UC_Register
Guest --> UC_Referral
Guest --> UC_Forgot
Guest --> UC_Rules

User --> UC_Dossier
User --> UC_ExpireConfig
User --> UC_AuditLogs
User --> UC_RefStats
User --> UC_Logout

Admin --> UC_AdminManage
Admin --> UC_GlobalPurge
@enduml
```

---

### ۷. دیاگرام سناریوی خروج اضطراری و پاک‌سازی سراسری (Timing & Sequence Diagram)
![هفتم](image-16.png)
تحلیل جزئیات امنیتی و ترتیب وقایع در زمان اجرای پروتکل خروج اضطراری (Global Purge) توسط رده‌های بالای مدیریتی سرور.

```plantuml
@startuml
autonumber
skinparam style strictuml

actor "مدیر ارشد (Admin)" as Admin
participant "Panel UI (F2)" as Panel
participant "Server Panel Engine" as S_Panel
participant "Client Render Loop" as C_Render
database "MySQL Database" as DB
collections "کلیه بازیکنان آنلاین" as Players

Admin -> Panel: کلیک روی دکمه "🚨 خروج همگانی"
Panel -> Panel: نمایش مودال تایید نهایی
Admin -> Panel: تایید اجرای پروتکل
Panel -> S_Panel: triggerServerEvent("panel:serverStartGlobalPurge")

S_Panel -> S_Panel: بررسی دسترسی ادمین (admin_level >= 0)
S_Panel -> S_Panel: ایجاد تایمر ۵ دقیقه‌ای (300,000 میلی‌ثانیه)
S_Panel -> Players: triggerClientEvent("auth:startPurgeCountdown", 300)

loop هر ۱ ثانیه به مدت ۳۰۰ ثانیه
    Players -> C_Render: dxDrawRectangle (نوار قرمز وضعیت هشدار)
    Players -> C_Render: dxDrawText ("خروج اضطراری کلیه بازیکنان ظرف MM:SS")
end

note over S_Panel, Players
  بازیکنان ۵ دقیقه فرصت دارند در منطقه‌ای امن متوقف شوند.
  در این بازه، دیتای موقعیت مکانی مداوم آماده همگام‌سازی است.
end note

... سپری شدن ۳۰۰ ثانیه (پایان تایمر سرور) ...

S_Panel -> DB: UPDATE accounts SET remember_token = NULL\n(باطل‌سازی کلیه توکن‌های نشست برای امنیت کامل)
loop به ازای تک تک بازیکنان سرور
    S_Panel -> DB: ذخیره‌سازی X, Y, Z, Rotation, Money, Skin
    S_Panel -> Players: پاک‌سازی ElementData کاربری (account:username, id)
    S_Panel -> Players: انتقال به دایمنشن ایزوله (Dimension 999)
    S_Panel -> Players: فریز کردن کاراکتر (setElementFrozen)
    S_Panel -> Players: triggerClientEvent("auth:showLogin")
end

Players -> Players: محو شدن بازی و نمایش مجدد صفحه لاگین مدرن
@enduml
```









<div align="center">
  <sub>طراحی و مهندسی‌شده با دقت بالا برای ارتقای استانداردهای سرورهای رول‌پلی MTA:SA 🚀</sub>
</div>