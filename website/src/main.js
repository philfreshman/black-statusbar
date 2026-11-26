const screen = document.getElementById("screen");
const cursor = document.getElementById("cursor");
const statusItem = document.getElementById("status-item");
const statusMenu = document.getElementById("status-menu");
const nightbarItem = document.getElementById("menu-nightbar");

const CURSOR_MOVE_MS = 900;
const REST_POSITION = { x: 62, y: 58 };

const wait = (ms) => new Promise((resolve) => setTimeout(resolve, ms));

/** Where an element's centre sits inside the screen, in percent. */
function centreOf(element) {
    const screenBox = screen.getBoundingClientRect();
    const box = element.getBoundingClientRect();
    return {
        x: ((box.left + box.width / 2 - screenBox.left) / screenBox.width) * 100,
        y: ((box.top + box.height / 2 - screenBox.top) / screenBox.height) * 100,
    };
}

async function moveCursorTo({ x, y }) {
    cursor.style.left = `${x}%`;
    cursor.style.top = `${y}%`;
    await wait(CURSOR_MOVE_MS);
}

async function click() {
    cursor.classList.add("is-pressed");
    await wait(120);
    cursor.classList.remove("is-pressed");
}

function setMenuOpen(isOpen) {
    statusItem.classList.toggle("is-open", isOpen);
    statusMenu.classList.toggle("is-open", isOpen);
    if (!isOpen) nightbarItem.classList.remove("is-hover");
}

function setNightbar(isOn) {
    screen.dataset.nightbar = isOn ? "on" : "off";
    nightbarItem.classList.toggle("checked", isOn);
}

/** Opens the Nightbar menu and clicks its Nightbar item, which flips the black bar. */
async function toggleNightbarFromMenu() {
    await moveCursorTo(centreOf(statusItem));
    await click();
    setMenuOpen(true);
    await wait(500);
    await moveCursorTo(centreOf(nightbarItem));
    nightbarItem.classList.add("is-hover");
    await wait(350);
    await click();
    setMenuOpen(false);
    setNightbar(screen.dataset.nightbar !== "on");
}

async function playLoop() {
    cursor.style.left = `${REST_POSITION.x}%`;
    cursor.style.top = `${REST_POSITION.y}%`;
    for (;;) {
        await wait(1400);
        await toggleNightbarFromMenu();
        await moveCursorTo(REST_POSITION);
        await wait(2600);
        await toggleNightbarFromMenu();
        await moveCursorTo(REST_POSITION);
    }
}

function updateClock() {
    const now = new Date();
    const day = now.toLocaleDateString(undefined, { weekday: "short" });
    const time = now.toLocaleTimeString(undefined, { hour: "2-digit", minute: "2-digit" });
    document.getElementById("clock").textContent = `${day} ${time}`;
}

updateClock();
setInterval(updateClock, 30_000);

if (matchMedia("(prefers-reduced-motion: reduce)").matches) {
    cursor.hidden = true;
    setNightbar(true);
} else {
    void playLoop();
}

// Copy buttons: data-copy names the element whose text is copied.
for (const button of document.querySelectorAll("[data-copy]")) {
    const label = button.querySelector(".copy-label");
    let resetTimer;
    button.addEventListener("click", async () => {
        const text = document.getElementById(button.dataset.copy).textContent.trim();
        try {
            await navigator.clipboard.writeText(text);
            label.textContent = "Copied";
        } catch {
            label.textContent = "Press ⌘C";
            getSelection().selectAllChildren(document.getElementById(button.dataset.copy));
        }
        button.classList.add("is-copied");
        clearTimeout(resetTimer);
        resetTimer = setTimeout(() => {
            label.textContent = "Copy";
            button.classList.remove("is-copied");
        }, 1800);
    });
}
