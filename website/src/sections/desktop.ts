import { icon } from '../icons.ts'
import { ids } from '../site.ts'
import { renderMenuEntries } from './app-menu.ts'

const appMenus = ['File', 'Edit', 'View']
/** Hidden on narrow screens, where the menu bar runs out of room. */
const wideAppMenus = ['Go', 'Window', 'Help']

const description =
    'A Mac desktop at dusk. The Nightbar menu opens, Nightbar is switched on and the menu bar turns black with white icons, then it is switched off again.'

/** Desert dusk: sky, hills, a road and a few power poles. */
function renderWallpaper(): string {
    return /* HTML */ `
        <div class="wallpaper" aria-hidden="true">
            <div class="sky"></div>
            <svg class="land" viewBox="0 0 1600 1000" preserveAspectRatio="none">
                <path
                    class="hills"
                    d="M0 470 L120 455 L210 462 L300 440 L380 452 L470 430 L560 446 L640 418 L720 428 L790 400 L860 412 L940 395 L1010 420 L1100 410 L1180 432 L1260 418 L1350 440 L1440 428 L1530 446 L1600 438 V1000 H0 Z"
                />
                <path class="ground" d="M0 490 Q800 470 1600 488 V1000 H0 Z" />
                <path class="road" d="M700 482 L760 482 L1100 1000 L-200 1000 Z" />
                <path class="road-line" d="M735 484 L739 484 L668 1000 L646 1000 Z" />
                <g class="poles">
                    <path d="M1180 486 V330 M1150 345 H1210 M1155 360 H1205" />
                    <path d="M1320 492 V300 M1284 318 H1356 M1290 336 H1350" />
                    <path d="M1080 482 V385 M1062 394 H1098" />
                    <path d="M1010 480 V420 M1000 425 H1020" />
                </g>
                <path
                    class="wire"
                    d="M1010 425 Q1045 440 1080 394 Q1130 410 1180 345 Q1250 370 1320 318 Q1460 380 1600 300"
                />
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
                    >${icon('nightbar', { className: 'glyph' })}</span
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
