let currentHandling = {};
let currentColors = { c1: "#ffffff", c2: "#000000", light: "#ffffff" };
let dynamicLighting = { pattern: "none", target: "lights", speed: 1.0 };
let isGodmode = false;
let transmissionMode = "auto";

function closePanel() {
    if (window.mta) mta.triggerEvent("cef:closePanel");
}

function switchTab(e, tabId) {
    document.querySelectorAll(".tab-btn").forEach(btn => btn.classList.remove("active"));
    document.querySelectorAll(".tab-pane").forEach(pane => pane.classList.remove("active"));
    if (e && e.target) e.target.classList.add("active");
    const target = document.getElementById("tab-" + tabId);
    if (target) target.classList.add("active");
}

// مقداردهی اولیه داده‌ها با مکانیزم ضد خطا
function initVehicleData(data) {
    try {
        if (!data) return;
        currentHandling = data.handling || {};
        
        const vehInfo = document.getElementById("veh-info");
        if (vehInfo) vehInfo.innerText = "شناسه: " + (data.dbid || "نامشخص");

        // بروزرسانی تمام اسلایدرها
        document.querySelectorAll("input[type='range']").forEach(slider => {
            const key = slider.id;
            if (currentHandling[key] !== undefined && currentHandling[key] !== null) {
                slider.value = currentHandling[key];
                const badge = document.getElementById("val-" + key);
                if (badge) badge.innerText = currentHandling[key];
            }
        });

        if (data.colors) {
            if (document.getElementById("primaryColor")) document.getElementById("primaryColor").value = data.colors.c1 || "#ffffff";
            if (document.getElementById("secondaryColor")) document.getElementById("secondaryColor").value = data.colors.c2 || "#000000";
            if (document.getElementById("headlightColor")) document.getElementById("headlightColor").value = data.colors.light || "#ffffff";
            currentColors = data.colors;
        }

        if (data.dynamicLighting) {
            dynamicLighting = data.dynamicLighting;
            if (document.getElementById("animPattern")) document.getElementById("animPattern").value = dynamicLighting.pattern || "none";
            if (document.getElementById("animTarget")) document.getElementById("animTarget").value = dynamicLighting.target || "lights";
            if (document.getElementById("animSpeed")) {
                document.getElementById("animSpeed").value = dynamicLighting.speed || 1.0;
                const spBadge = document.getElementById("val-animSpeed");
                if (spBadge) spBadge.innerText = dynamicLighting.speed || 1.0;
            }
        }

        isGodmode = data.damageProof || false;
        updateGodmodeBtn();

        transmissionMode = data.transmissionMode || "auto";
        setTransmissionMode(transmissionMode, false);

        renderProfiles(data.profiles || []);
    } catch (err) {
        console.error("Init Error:", err);
    }
}

// آپدیت آنی اسلایدر هنگام کشیدن
function updateVal(slider) {
    const key = slider.id;
    const val = parseFloat(slider.value);
    const labelSpan = document.getElementById("val-" + key);
    if (labelSpan) labelSpan.innerText = val;
    currentHandling[key] = val;
}

// دکمه‌های + و - برای اسلایدرها
function stepSlider(id, step) {
    const el = document.getElementById(id);
    if (!el) return;

    let min = parseFloat(el.min);
    let max = parseFloat(el.max);
    let cur = parseFloat(el.value) || 0;
    let next = cur + step;

    // رفع مشکل گرد کردن ممیز اعشاری جاوااسکریپت
    let decimals = 2;
    let stepStr = el.step || "1";
    if (stepStr.includes(".")) {
        decimals = stepStr.split(".")[1].length;
    }
    next = parseFloat(next.toFixed(decimals));

    if (next < min) next = min;
    if (next > max) next = max;

    el.value = next;
    updateVal(el);

    if (id === "animSpeed") {
        updateDynamicLighting();
    }
}

function updateSpeedVal(slider) {
    const badge = document.getElementById("val-animSpeed");
    if (badge) badge.innerText = slider.value;
}

document.getElementById("driveType").addEventListener("change", function(e) {
    currentHandling["driveType"] = e.target.value;
});

function updateDynamicLighting() {
    dynamicLighting.pattern = document.getElementById("animPattern").value;
    dynamicLighting.target = document.getElementById("animTarget").value;
    dynamicLighting.speed = parseFloat(document.getElementById("animSpeed").value);

    if (window.mta) {
        mta.triggerEvent("cef:setDynamicLighting", JSON.stringify(dynamicLighting));
    }
}

function updateStaticColors() {
    currentColors.c1 = document.getElementById("primaryColor").value;
    currentColors.c2 = document.getElementById("secondaryColor").value;
    currentColors.light = document.getElementById("headlightColor").value;

    if (window.mta) {
        mta.triggerEvent("cef:livePreviewColors", JSON.stringify(currentColors));
    }
}

function quickFix() {
    if (window.mta) mta.triggerEvent("cef:fixVehicle");
}

function toggleGodmode() {
    isGodmode = !isGodmode;
    updateGodmodeBtn();
    if (window.mta) mta.triggerEvent("cef:toggleGodmode", isGodmode);
}

function updateGodmodeBtn() {
    const btn = document.getElementById("godmode-btn");
    if (isGodmode) {
        btn.classList.add("active");
        btn.innerText = "🛡️ ضدضربه: فعال";
    } else {
        btn.classList.remove("active");
        btn.innerText = "🛡️ حالت ضد ضربه";
    }
}

function setTransmissionMode(mode, triggerMTA = true) {
    transmissionMode = mode;
    document.getElementById("btn-auto-gear").classList.toggle("active", mode === "auto");
    document.getElementById("btn-manual-gear").classList.toggle("active", mode === "manual");
    if (triggerMTA && window.mta) {
        mta.triggerEvent("cef:setTransmissionMode", mode);
    }
}

function applyPreset(type) {
    if (type === 'drift') {
        currentHandling.steeringLock = 58;
        currentHandling.driveType = 'r';
        currentHandling.brakeDeceleration = 14;
        currentHandling.brakeBias = 0.35;
        currentHandling.tractionMultiplier = 0.75;
        currentHandling.engineAcceleration = 30;
        currentHandling.suspensionLowerLimit = -0.06;
    } else if (type === 'drag') {
        currentHandling.steeringLock = 35;
        currentHandling.driveType = '4';
        currentHandling.brakeDeceleration = 18;
        currentHandling.tractionMultiplier = 1.7;
        currentHandling.engineAcceleration = 55;
        currentHandling.maxVelocity = 350;
    } else if (type === 'offroad') {
        currentHandling.steeringLock = 42;
        currentHandling.driveType = '4';
        currentHandling.suspensionLowerLimit = 0.16;
        currentHandling.suspensionForceLevel = 2.6;
        currentHandling.tractionMultiplier = 1.35;
    } else if (type === 'armored') {
        currentHandling.collisionDamageMultiplier = 0.0;
        currentHandling.mass = 3500;
        currentHandling.engineAcceleration = 28;
    }

    initVehicleData({ handling: currentHandling, colors: currentColors, dynamicLighting: dynamicLighting, dbid: document.getElementById("veh-info").innerText.replace(/\D/g, '') });
}

function saveAllSettings() {
    if (window.mta) {
        mta.triggerEvent("cef:saveAllSettings", JSON.stringify({
            handling: currentHandling,
            colors: currentColors,
            dynamicLighting: dynamicLighting,
            damageProof: isGodmode,
            transmissionMode: transmissionMode
        }));
    }
}

function resetToStock() {
    if (window.mta) mta.triggerEvent("cef:resetHandling");
}

function saveNewProfile() {
    const name = document.getElementById("new-profile-name").value.trim();
    if (name.length < 2) return;
    if (window.mta) {
        mta.triggerEvent("cef:saveProfile", name, JSON.stringify(currentHandling));
    }
    document.getElementById("new-profile-name").value = "";
}

function renderProfiles(list) {
    const container = document.getElementById("custom-profiles-list");
    container.innerHTML = "";
    list.forEach(p => {
        const div = document.createElement("div");
        div.className = "input-card";
        div.style.marginTop = "6px";
        div.innerHTML = `
            <div style="display:flex; justify-content:space-between; align-items:center;">
                <span style="color:#fff;">${p.profile_name}</span>
                <button class="btn btn-secondary" onclick='loadCustomProfile(${p.handling_data})'>بارگذاری</button>
            </div>
        `;
        container.appendChild(div);
    });
}

function loadCustomProfile(data) {
    currentHandling = data;
    initVehicleData({ handling: currentHandling, colors: currentColors, dynamicLighting: dynamicLighting, dbid: document.getElementById("veh-info").innerText.replace(/\D/g, '') });
}