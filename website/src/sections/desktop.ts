import { icon } from '../icons.ts'
import { ids } from '../site.ts'
import { renderMenuEntries } from './app-menu.ts'

const appMenus = ['File', 'Edit', 'View']
/** Hidden on narrow screens, where the menu bar runs out of room. */
const wideAppMenus = ['Go', 'Window', 'Help']

const description =
    'A Mac desktop with a glowing violet storm wallpaper. The Nightbar menu opens, Nightbar is switched on and the menu bar turns black with white icons, then it is switched off again.'

/** A soft-glow storm: violet and blue light pooled on a dark sky, crossed by streaks of light. */
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
                        <stop offset="0" stop-color="#b9adff" />
                        <stop offset=".34" stop-color="#7a5cf0" />
                        <stop offset=".66" stop-color="#2e1873" />
                        <stop offset="1" stop-color="#0a0714" />
                    </linearGradient>
                    ${renderGlow('scene-blue', '#5f9dff')} ${renderGlow('scene-pink', '#ff6fcf')}
                    ${renderGlow('scene-violet', '#9a6bff')} ${renderGlow('scene-ember', '#ff7a45')}
                    ${renderGlow('scene-flash', '#f4efff')}
                    ${renderStreak('scene-streak-a', '#efe8ff', 0.55, [0, 0, 1600, 520])}
                    ${renderStreak('scene-streak-b', '#c9b6ff', 0.4, [0, 200, 1600, 0])}
                </defs>
                <rect width="1600" height="1000" fill="url(#scene-sky)" />
                <ellipse cx="260" cy="170" rx="620" ry="340" fill="url(#scene-blue)" />
                <ellipse
                    cx="1320"
                    cy="560"
                    rx="560"
                    ry="360"
                    fill="url(#scene-pink)"
                    opacity=".75"
                />
                <ellipse cx="720" cy="860" rx="820" ry="300" fill="url(#scene-violet)" />
                <ellipse
                    cx="1060"
                    cy="800"
                    rx="260"
                    ry="130"
                    fill="url(#scene-ember)"
                    opacity=".55"
                />
                <rect width="1600" height="1000" fill="url(#scene-streak-a)" />
                <rect width="1600" height="1000" fill="url(#scene-streak-b)" />
                <ellipse
                    class="flash"
                    cx="1180"
                    cy="300"
                    rx="420"
                    ry="300"
                    fill="url(#scene-flash)"
                />
            </svg>
        </div>
    `
}

/** A round pool of light: full colour in the middle, fading out to nothing at the edge. */
function renderGlow(id: string, color: string): string {
    return /* HTML */ `
        <radialGradient id="${id}" cx=".5" cy=".5" r=".5">
            <stop offset="0" stop-color="${color}" />
            <stop offset=".45" stop-color="${color}" stop-opacity=".55" />
            <stop offset="1" stop-color="${color}" stop-opacity="0" />
        </radialGradient>
    `
}

/** A diagonal band of light across the whole scene, like the streaks in the storm panels. */
function renderStreak(
    id: string,
    color: string,
    opacity: number,
    [x1, y1, x2, y2]: [number, number, number, number],
): string {
    return /* HTML */ `
        <linearGradient
            id="${id}"
            gradientUnits="userSpaceOnUse"
            x1="${x1}"
            y1="${y1}"
            x2="${x2}"
            y2="${y2}"
        >
            <stop offset=".42" stop-color="${color}" stop-opacity="0" />
            <stop offset=".5" stop-color="${color}" stop-opacity="${opacity}" />
            <stop offset=".6" stop-color="${color}" stop-opacity="0" />
        </linearGradient>
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
