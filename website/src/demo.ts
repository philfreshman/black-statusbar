import { requireElement, wait } from './dom.ts'
import { ids } from './site.ts'

interface Position {
    /** Percent of the desktop's width. */
    x: number
    /** Percent of the desktop's height. */
    y: number
}

/** Matches the cursor's left/top transition in desktop.css. */
const CURSOR_MOVE_MS = 900
const CLICK_MS = 120
const REST_POSITION: Position = { x: 62, y: 58 }

/**
 * Plays the hero animation: the cursor opens the Nightbar menu and switches Nightbar on,
 * waits, then switches it off again, forever. With reduced motion it just shows Nightbar on.
 */
export function startDemo(): void {
    const desktop = requireElement(ids.desktop)
    const cursor = requireElement<SVGSVGElement>(ids.cursor)
    const statusItem = requireElement(ids.statusItem)
    const statusMenu = requireElement(ids.statusMenu)
    const nightbarItem = requireElement(ids.nightbarMenuItem)

    function centreOf(element: Element): Position {
        const desktopBox = desktop.getBoundingClientRect()
        const box = element.getBoundingClientRect()
        return {
            x: ((box.left + box.width / 2 - desktopBox.left) / desktopBox.width) * 100,
            y: ((box.top + box.height / 2 - desktopBox.top) / desktopBox.height) * 100,
        }
    }

    function placeCursor({ x, y }: Position): void {
        cursor.style.left = `${x}%`
        cursor.style.top = `${y}%`
    }

    async function moveCursorTo(position: Position): Promise<void> {
        placeCursor(position)
        await wait(CURSOR_MOVE_MS)
    }

    async function click(): Promise<void> {
        cursor.classList.add('is-pressed')
        await wait(CLICK_MS)
        cursor.classList.remove('is-pressed')
    }

    function setMenuOpen(isOpen: boolean): void {
        statusItem.classList.toggle('is-open', isOpen)
        statusMenu.classList.toggle('is-open', isOpen)
        if (!isOpen) {
            nightbarItem.classList.remove('is-hover')
        }
    }

    function isNightbarOn(): boolean {
        return desktop.dataset.nightbar === 'on'
    }

    function setNightbar(isOn: boolean): void {
        desktop.dataset.nightbar = isOn ? 'on' : 'off'
        nightbarItem.classList.toggle('checked', isOn)
    }

    /** Opens the Nightbar menu and clicks its Nightbar item, which flips the black bar. */
    async function toggleNightbarFromMenu(): Promise<void> {
        await moveCursorTo(centreOf(statusItem))
        await click()
        setMenuOpen(true)
        await wait(500)
        await moveCursorTo(centreOf(nightbarItem))
        nightbarItem.classList.add('is-hover')
        await wait(350)
        await click()
        setMenuOpen(false)
        setNightbar(!isNightbarOn())
    }

    async function playLoop(): Promise<never> {
        placeCursor(REST_POSITION)
        for (;;) {
            await wait(1400)
            await toggleNightbarFromMenu()
            await moveCursorTo(REST_POSITION)
            await wait(2600)
            await toggleNightbarFromMenu()
            await moveCursorTo(REST_POSITION)
        }
    }

    if (matchMedia('(prefers-reduced-motion: reduce)').matches) {
        // SVG elements have no `hidden` property, so hide the cursor with CSS.
        cursor.style.display = 'none'
        setNightbar(true)
        return
    }

    void playLoop()
}
