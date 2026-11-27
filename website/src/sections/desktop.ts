import { icon } from '../icons.ts'
import { ids } from '../site.ts'
import { renderStatusMenuEntries } from './app-menu.ts'

const appMenus = ['File', 'Edit', 'View']
/** Hidden on narrow screens, where the menu bar runs out of room. */
const wideAppMenus = ['Go', 'Window', 'Help']

const description =
    'A Mac desktop with a dark wallpaper of violet waves. The Nightbar menu opens, Nightbar is switched on and the menu bar turns black with white icons. Then the rounded corners are switched on or off, rounding the screen below the bar, and Nightbar is switched off again.'

/** The wallpaper behind the mock menu bar. The picture comes from the CSS. */
function renderWallpaper(): string {
    return /* HTML */ `<div class="wallpaper" aria-hidden="true"></div>`
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
    const entries = renderStatusMenuEntries(false, ids.nightbarMenuItem)

    return /* HTML */ `
        <ul class="status-menu" id="${ids.statusMenu}" aria-hidden="true">
            ${entries}
        </ul>
    `
}

/**
 * Nightbar's rounded corners: black fillets that make the area below the menu bar a rounded
 * rectangle. The top two hang below the bar, the bottom two sit on the screen's bottom edge.
 */
function renderCorners(): string {
    const corners = ['top-left', 'top-right', 'bottom-left', 'bottom-right']
    return corners.map((corner) => `<i class="corner ${corner}" aria-hidden="true"></i>`).join('')
}

/** The mock Mac desktop the demo in demo.ts plays on. */
export function renderDesktop(): string {
    return /* HTML */ `
        <div
            class="screen"
            id="${ids.desktop}"
            data-nightbar="off"
            data-corners="off"
            role="img"
            aria-label="${description}"
        >
            ${renderWallpaper()} ${renderCorners()} ${renderMenubar()} ${renderStatusMenu()}
            <div class="cursor-track" id="${ids.cursorTrack}">
                ${icon('cursor', { className: 'cursor', id: ids.cursor })}
            </div>
        </div>
    `
}
