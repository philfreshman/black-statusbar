import { icon } from '../icons.ts'
import { ids } from '../site.ts'
import { renderMenuEntries } from './app-menu.ts'

const appMenus = ['File', 'Edit', 'View']
/** Hidden on narrow screens, where the menu bar runs out of room. */
const wideAppMenus = ['Go', 'Window', 'Help']

const description =
    'A Mac desktop with a stormy dusk wallpaper. The Nightbar menu opens, Nightbar is switched on and the menu bar turns black with white icons, then it is switched off again.'

/** Thunderhead at dusk: a pastel sky, a storm cloud with a lightning bolt, a dark sea. */
function renderWallpaper(): string {
    return /* HTML */ `
        <div class="wallpaper" aria-hidden="true">
            <svg
                class="scene"
                viewBox="0 0 1600 1000"
                preserveAspectRatio="xMidYMid slice"
                aria-hidden="true"
            >
                <defs>
                    <linearGradient id="scene-sky" x1="0" y1="0" x2="0" y2="1">
                        <stop offset="0" stop-color="#aab6ff" />
                        <stop offset=".3" stop-color="#b9a0f2" />
                        <stop offset=".52" stop-color="#f0a0c0" />
                        <stop offset=".66" stop-color="#ffb98f" />
                        <stop offset=".7" stop-color="#ffd59c" />
                    </linearGradient>
                    <linearGradient id="scene-sea" x1="0" y1="0" x2="0" y2="1">
                        <stop offset="0" stop-color="#3a2354" />
                        <stop offset="1" stop-color="#0c0814" />
                    </linearGradient>
                    <radialGradient id="scene-sun" cx=".5" cy=".5" r=".5">
                        <stop offset="0" stop-color="#fff2c4" />
                        <stop offset=".35" stop-color="#ffcf8f" stop-opacity=".8" />
                        <stop offset="1" stop-color="#ffb98f" stop-opacity="0" />
                    </radialGradient>
                    <linearGradient
                        id="scene-cloud"
                        gradientUnits="userSpaceOnUse"
                        x1="0"
                        y1="180"
                        x2="0"
                        y2="560"
                    >
                        <stop offset="0" stop-color="#e0d2fa" />
                        <stop offset=".45" stop-color="#9580d6" />
                        <stop offset="1" stop-color="#4f3f8c" />
                    </linearGradient>
                    <filter id="scene-soft" x="-10%" y="-10%" width="120%" height="120%">
                        <feGaussianBlur stdDeviation="3" />
                    </filter>
                    <filter id="scene-glow" x="-50%" y="-50%" width="200%" height="200%">
                        <feGaussianBlur stdDeviation="9" />
                    </filter>
                </defs>
                <rect width="1600" height="700" fill="url(#scene-sky)" />
                <ellipse cx="560" cy="690" rx="420" ry="180" fill="url(#scene-sun)" />
                <path
                    class="mountains"
                    d="M0 700V560l90-40 80 30 110-90 90 70 70-30 120 100h60l90-60 70 40 60-20 60 90z"
                />
                <g class="cloud" fill="url(#scene-cloud)" filter="url(#scene-soft)">
                    <ellipse cx="1220" cy="228" rx="320" ry="34" />
                    <circle cx="1220" cy="300" r="95" />
                    <circle cx="1150" cy="360" r="110" />
                    <circle cx="1290" cy="360" r="105" />
                    <circle cx="1080" cy="440" r="95" />
                    <circle cx="1360" cy="440" r="95" />
                    <circle cx="1220" cy="430" r="130" />
                    <circle cx="1140" cy="500" r="85" />
                    <circle cx="1300" cy="505" r="85" />
                    <rect x="1030" y="480" width="380" height="70" rx="35" />
                </g>
                <circle class="cloud-light" cx="1185" cy="290" r="70" />
                <g class="bolt">
                    <path
                        class="bolt-glow"
                        d="M1200 540 1168 600h26l-40 70h22l-46 60"
                        filter="url(#scene-glow)"
                    />
                    <path d="M1200 540 1168 600h26l-40 70h22l-46 60" />
                </g>
                <rect y="700" width="1600" height="300" fill="url(#scene-sea)" />
                <g class="glints">
                    <path d="M470 722h180M420 752h280M500 790h120M380 830h340M470 880h170" />
                </g>
            </svg>
        </div>
    `
}

function renderMenubar(): string {
    const menus = [
        ...appMenus.map((name) => `<span>${name}</span>`),
        ...wideAppMenus.map((name) => `<span class="wide">${name}</span>`),
    ].join('')

    return /* HTML */ `
        <div class="menubar" aria-hidden="true">
            <div class="menubar-left">
                ${icon('apple', { className: 'apple' })}<b>Finder</b>${menus}
            </div>
            <div class="notch"></div>
            <div class="menubar-right">
                <span class="status-item" id="${ids.statusItem}"
                    >${icon('mark', { className: 'glyph' })}</span
                >
                ${icon('wifi', { className: 'glyph' })}
                ${icon('battery', { className: 'glyph battery' })}
                ${icon('controlCenter', { className: 'glyph' })}
                <span class="clock" id="${ids.clock}">Wed 21:30</span>
            </div>
        </div>
    `
}

function renderStatusMenu(): string {
    const entries = renderMenuEntries([
        { label: 'Nightbar', checked: false, id: ids.nightbarMenuItem },
        'separator',
        { label: 'Launch at Login', checked: true },
        'separator',
        { label: 'Quit', shortcut: '⌘Q' },
    ])

    return /* HTML */ `
        <ul class="status-menu" id="${ids.statusMenu}" aria-hidden="true">
            ${entries}
        </ul>
    `
}

/** The mock Mac desktop the demo in demo.ts plays on. */
export function renderDesktop(): string {
    return /* HTML */ `
        <div
            class="screen"
            id="${ids.desktop}"
            data-nightbar="off"
            role="img"
            aria-label="${description}"
        >
            ${renderWallpaper()} ${renderMenubar()} ${renderStatusMenu()}
            ${icon('cursor', { className: 'cursor', id: ids.cursor })}
        </div>
    `
}
