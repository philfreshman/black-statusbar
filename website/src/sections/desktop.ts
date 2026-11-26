import { icon } from '../icons.ts'
import { ids } from '../site.ts'
import { renderMenuEntries } from './app-menu.ts'
import { renderWallpaperScene } from './wallpaper.ts'

const appMenus = ['File', 'Edit', 'View']
/** Hidden on narrow screens, where the menu bar runs out of room. */
const wideAppMenus = ['Go', 'Window', 'Help']

const description =
    'A Mac desktop with a violet satin wallpaper. The Nightbar menu opens, Nightbar is switched on and the menu bar turns black with white icons, then it is switched off again.'

/** The wallpaper behind the mock menu bar. Film grain on top comes from the CSS. */
function renderWallpaper(): string {
    return /* HTML */ `<div class="wallpaper" aria-hidden="true">
        ${renderWallpaperScene('scene')}
    </div>`
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
