function toggleView(show) {
    if (show) {
        document.body.classList.add("show");
    } else {
        document.body.classList.remove("show");
    }
}

// تابع اسکرول با چرخ ماوس
function scrollList(offset) {
    const container = document.getElementById("scrollContainer");
    if (container) {
        container.scrollTop += offset;
    }
}

function renderData(data) {
    if (!data) return;

    // ۱. متن دقیق وضعیت شهردار با نام
    const mayorBox = document.getElementById("mayorBox");
    const mayorStatus = document.getElementById("mayorStatus");
    const name = data.mayorName || "SilentGalaxy";

    if (data.mayorOnline) {
        mayorBox.className = "mayor-strip online";
        mayorStatus.textContent = `👑 شهردار ${name} در شهر فعال است 🟢`;
    } else {
        mayorBox.className = "mayor-strip offline";
        mayorStatus.textContent = `👑 شهردار ${name} در شهر غیرفعال است 🔴`;
    }

    // ۲. به‌روزرسانی آمار ارگان‌ها
    document.getElementById("policeCount").textContent = data.police || 0;
    document.getElementById("medicCount").textContent = data.medic || 0;
    document.getElementById("mechCount").textContent = data.mech || 0;
    document.getElementById("staffCount").textContent = data.staff || 0;
    document.getElementById("botCount").textContent = data.bots || 0;
    document.getElementById("onlineCount").textContent = data.total || 0;
    document.getElementById("maxCount").textContent = data.max || 128;

    // ۳. رندر ردیف‌های جدول به سبک متنی تمیز و فوق‌سریع
    const tbody = document.getElementById("playerRows");
    const players = data.players || [];
    let html = "";

    for (let i = 0; i < players.length; i++) {
        const p = players[i];
        let pClass = "ping-fast";
        if (p.ping > 130) pClass = "ping-slow";
        else if (p.ping > 80) pClass = "ping-med";

        html += `
            <tr class="${p.isMayor ? 'mayor-row' : ''}">
                <td style="color:#64748b;">#${p.id}</td>
                <td class="pname">${p.isMayor ? '👑 ' : ''}${escapeText(p.name)}</td>
                <td style="color:#cbd5e1;">${escapeText(p.role)}</td>
                <td><span class="duty-tag ${p.isDuty ? 'duty-on' : 'duty-off'}">${p.isDuty ? 'خدمت' : 'استراحت'}</span></td>
                <td><span class="${pClass}">${p.ping}ms</span></td>
            </tr>
        `;
    }
    tbody.innerHTML = html;
}

function escapeText(str) {
    if (!str) return "";
    return str.replace(/[&<>'"]/g, 
        tag => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', "'": '&#39;', '"': '&quot;' }[tag] || tag)
    );
}