import { requireElement } from './dom.ts'
import { PausableClock } from './pausable-clock.ts'
import { ids } from './site.ts'

interface Position {
    /** Percent of the desktop's width. */
    x: number
    /** Percent of the desktop's height. */
    y: number
}

/** Matches the cursor track's translate transition in desktop.css. */
const CURSOR_MOVE_MS = 780
const CLICK_MS = 105
const REST_POSITION: Position = { x: 62, y: 58 }

/** Why the demo is paused. It plays only while none of these apply. */
const pauseReasons = {
    visitor: 'visitor',
    offscreen: 'offscreen',
    hiddenTab: 'hidden-tab',
} as const

const toggleLabels = { pause: 'Pause demo', play: 'Play demo' } as const

/** The two Rounded Corners radii the demo switches between. */
type CornerRadius = 'off' | 'high'

/** Looks up a row of the status menu by its data-item name. */
function requireMenuItem(menu: Element, item: string): HTMLElement {
    const row = menu.querySelector<HTMLElement>(`[data-item="${item}"]`)
    if (!row) {
        throw new Error(`The status menu has no "${item}" row`)
    }
    return row
}

/**
 * Lets the visitor pause the demo, and pauses it on their behalf while nobody can see it:
 * scrolled out of view or in a background tab, where it would only use battery.
 */
function controlPlayback(clock: PausableClock, desktop: HTMLElement): void {
    const toggle = requireElement<HTMLButtonElement>(ids.demoToggle)
    const label = toggle.querySelector('.demo-toggle-label')

    toggle.hidden = false
    toggle.addEventListener('click', () => {
        const isPausing = toggle.dataset.paused !== 'true'
        if (isPausing) {
            clock.pause(pauseReasons.visitor)
        } else {
            clock.resume(pauseReasons.visitor)
        }
        // The label says what the button does next, so it needs no aria-pressed.
        toggle.dataset.paused = String(isPausing)
        if (label) {
            label.textContent = isPausing ? toggleLabels.play : toggleLabels.pause
        }
    })

    new IntersectionObserver(([entry]) => {
        if (entry.isIntersecting) {
            clock.resume(pauseReasons.offscreen)
        } else {
            clock.pause(pauseReasons.offscreen)
        }
    }).observe(desktop)

    document.addEventListener('visibilitychange', () => {
        if (document.hidden) {
            clock.pause(pauseReasons.hiddenTab)
        } else {
            clock.resume(pauseReasons.hiddenTab)
        }
    })
}

/**
 * Plays the hero animation: the cursor opens the Nightbar menu and switches Nightbar on, then
 * switches the rounded corners on or off, then switches Nightbar off again, until paused.
 * With reduced motion it just shows Nightbar on.
 */
export function startDemo(): void {
    const desktop = requireElement(ids.desktop)
    const cursor = requireElement<SVGSVGElement>(ids.cursor)
    const cursorTrack = requireElement(ids.cursorTrack)
    const statusItem = requireElement(ids.statusItem)
    const statusMenu = requireElement(ids.statusMenu)
    const nightbarItem = requireElement(ids.nightbarMenuItem)
    const roundedCornersItem = requireMenuItem(statusMenu, 'rounded-corners')
    const cornerItems: Record<CornerRadius, HTMLElement> = {
        off: requireMenuItem(statusMenu, 'corners-off'),
        high: requireMenuItem(statusMenu, 'corners-high'),
    }
    const clock = new PausableClock()

    /** In percent of the screen inside its bezel, where the cursor track sits. */
    function centreOf(element: Element): Position {
        const desktopBox = desktop.getBoundingClientRect()
        const left = desktopBox.left + desktop.clientLeft
        const top = desktopBox.top + desktop.clientTop
        const box = element.getBoundingClientRect()
        return {
            x: ((box.left + box.width / 2 - left) / desktop.clientWidth) * 100,
            y: ((box.top + box.height / 2 - top) / desktop.clientHeight) * 100,
        }
    }

    function placeCursor({ x, y }: Position): void {
        cursorTrack.style.translate = `${x}% ${y}%`
    }

    async function moveCursorTo(position: Position): Promise<void> {
        placeCursor(position)
        await clock.wait(CURSOR_MOVE_MS)
    }

    async function click(): Promise<void> {
        cursor.classList.add('is-pressed')
        await clock.wait(CLICK_MS)
        cursor.classList.remove('is-pressed')
    }

    async function rest(ms: number): Promise<void> {
        await moveCursorTo(REST_POSITION)
        await clock.wait(ms)
    }

    function setMenuOpen(isOpen: boolean): void {
        statusItem.classList.toggle('is-open', isOpen)
        statusMenu.classList.toggle('is-open', isOpen)
        if (!isOpen) {
            for (const row of statusMenu.querySelectorAll('.is-hover, .is-open')) {
                row.classList.remove('is-hover', 'is-open')
            }
        }
    }

    /** Highlights a row, and only that row in its menu or submenu. */
    function hover(row: Element): void {
        for (const sibling of row.parentElement?.children ?? []) {
            sibling.classList.toggle('is-hover', sibling === row)
        }
    }

    async function openMenu(): Promise<void> {
        await moveCursorTo(centreOf(statusItem))
        await click()
        setMenuOpen(true)
        await clock.wait(435)
    }

    async function chooseItem(row: Element): Promise<void> {
        await moveCursorTo(centreOf(row))
        hover(row)
        await clock.wait(305)
        await click()
        setMenuOpen(false)
    }

    function isNightbarOn(): boolean {
        return desktop.dataset.nightbar === 'on'
    }

    function setNightbar(isOn: boolean): void {
        desktop.dataset.nightbar = isOn ? 'on' : 'off'
        nightbarItem.classList.toggle('checked', isOn)
    }

    function setCorners(radius: CornerRadius): void {
        desktop.dataset.corners = radius
        for (const [name, row] of Object.entries(cornerItems)) {
            row.classList.toggle('checked', name === radius)
        }
    }

    /** Opens the Nightbar menu and clicks its Nightbar item, which flips the black bar. */
    async function toggleNightbarFromMenu(): Promise<void> {
        await openMenu()
        await chooseItem(nightbarItem)
        setNightbar(!isNightbarOn())
    }

    /** Opens the Rounded Corners submenu and switches the corners between Off and High. */
    async function toggleCornersFromMenu(): Promise<void> {
        await openMenu()
        await moveCursorTo(centreOf(roundedCornersItem))
        hover(roundedCornersItem)
        roundedCornersItem.classList.add('is-open')
        await clock.wait(350)
        const radius: CornerRadius = desktop.dataset.corners === 'high' ? 'off' : 'high'
        await chooseItem(cornerItems[radius])
        setCorners(radius)
    }

    async function playLoop(): Promise<never> {
        placeCursor(REST_POSITION)
        await clock.wait(1220)
        for (;;) {
            await toggleNightbarFromMenu()
            await rest(1565)
            await toggleCornersFromMenu()
            await rest(2260)
            await toggleNightbarFromMenu()
            await rest(1220)
        }
    }

    if (matchMedia('(prefers-reduced-motion: reduce)').matches) {
        cursorTrack.hidden = true
        setNightbar(true)
        return
    }

    controlPlayback(clock, desktop)
    void playLoop()
}
