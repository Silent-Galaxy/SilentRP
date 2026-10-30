const doorNames = {
    0: "کاپوت جلو",
    1: "صندوق عقب",
    2: "درب جلو چپ (راننده)",
    3: "درب جلو راست (شاگرد)",
    4: "درب عقب چپ",
    5: "درب عقب راست"
};

function updateHUD(speed, engine, lights, handbrake, indicator, seatbelt, anyDoorOpen, gear, flash, doorsJson, isDriver) {
    const hud = document.getElementById('hud-container');
    if (!isDriver && speed === 0 && !engine) {
        hud.classList.add('hidden');
        return;
    }
    hud.classList.remove('hidden');

    document.getElementById('speed-val').innerText = speed;
    document.getElementById('gear-indicator').innerText = gear;

    const progressCircle = document.getElementById('gauge-progress');
    const maxOffset = 440;
    const minOffset = 110;
    const progress = Math.min(speed / 240, 1);
    const offset = maxOffset - (progress * (maxOffset - minOffset));
    progressCircle.style.strokeDashoffset = offset;

    document.getElementById('badge-engine').className = 'stat-badge ' + (engine ? 'active-green' : '');
    document.getElementById('badge-lights').className = 'stat-badge ' + (lights ? 'active-green' : '');
    document.getElementById('badge-handbrake').className = 'stat-badge ' + (handbrake ? 'active-red' : '');

    const sb = document.getElementById('badge-seatbelt');
    if (seatbelt) {
        sb.className = 'stat-badge active-green';
    } else {
        sb.className = 'stat-badge ' + (flash ? 'warning-flash' : '');
    }

    const db = document.getElementById('badge-doors');
    if (anyDoorOpen) {
        db.className = 'stat-badge ' + (flash ? 'warning-flash' : '');
    } else {
        db.className = 'stat-badge';
    }

    const indLeft = document.getElementById('ind-left');
    const indRight = document.getElementById('ind-right');
    const indHaz = document.getElementById('ind-hazard');

    indLeft.classList.toggle('indicator-blink', (indicator === 'left' || indicator === 'hazard') && flash);
    indRight.classList.toggle('indicator-blink', (indicator === 'right' || indicator === 'hazard') && flash);
    indHaz.classList.toggle('indicator-blink', indicator === 'hazard' && flash);

    try {
        const doors = JSON.parse(doorsJson);
        for (let idx in doors) {
            const btn = document.getElementById('door-' + idx);
            if (btn) {
                const isOpen = doors[idx];
                btn.classList.toggle('door-open-state', isOpen);
                btn.innerText = (doorNames[idx] || 'درب') + (isOpen ? ' [باز]' : ' [بسته]');
            }
        }
    } catch(e) {}
}

function togglePanel(show) {
    const panel = document.getElementById('control-panel');
    if (show) {
        panel.classList.remove('panel-hidden');
    } else {
        panel.classList.add('panel-hidden');
    }
}

function closePanel() {
    togglePanel(false);
    mta.triggerEvent('cef:closePanel');
}

function toggleDoor(index) {
    mta.triggerEvent('cef:doorAction', index);
}

function toggleAllDoors() {
    mta.triggerEvent('cef:toggleAllDoors');
}

function quickAction(action) {
    mta.triggerEvent('cef:quickAction', action);
}
