const screen = document.getElementById("screen");
const toggle = document.getElementById("toggle");
const caption = document.getElementById("caption");
const chips = [...document.querySelectorAll(".chip")];

const captions = {
  on: "Nightbar on. Black bar, white icons, and the notch disappears into it.",
  off: "Nightbar off. The bar takes its colour from the wallpaper, and the icons change with it.",
};

const AUTO_CYCLE_MS = 3800;
let autoCycle;

function showWallpaper(name) {
  screen.dataset.wallpaper = name;
  chips.forEach((chip) => chip.setAttribute("aria-checked", String(chip.dataset.wp === name)));
}

function setNightbar(isOn) {
  screen.dataset.nightbar = isOn ? "on" : "off";
  caption.textContent = isOn ? captions.on : captions.off;
}

function stopAutoCycle() {
  clearInterval(autoCycle);
}

function startAutoCycle() {
  if (matchMedia("(prefers-reduced-motion: reduce)").matches) return;
  autoCycle = setInterval(() => {
    const current = chips.findIndex((chip) => chip.dataset.wp === screen.dataset.wallpaper);
    showWallpaper(chips[(current + 1) % chips.length].dataset.wp);
  }, AUTO_CYCLE_MS);
}

function updateClock() {
  const now = new Date();
  const day = now.toLocaleDateString(undefined, { weekday: "short" });
  const time = now.toLocaleTimeString(undefined, { hour: "2-digit", minute: "2-digit" });
  document.getElementById("clock").textContent = `${day} ${time}`;
}

chips.forEach((chip) =>
  chip.addEventListener("click", () => {
    stopAutoCycle();
    showWallpaper(chip.dataset.wp);
  })
);

toggle.addEventListener("change", () => {
  stopAutoCycle();
  setNightbar(toggle.checked);
});

updateClock();
setInterval(updateClock, 30_000);
startAutoCycle();
