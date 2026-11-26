import { requireElement } from './dom.ts'
import { ids } from './site.ts'

const UPDATE_EVERY_MS = 30_000

/** Formats a time like the macOS menu bar clock, for example "Wed 21:30". */
export function formatMenubarTime(date: Date, locale?: string): string {
    const day = date.toLocaleDateString(locale, { weekday: 'short' })
    const time = date.toLocaleTimeString(locale, { hour: '2-digit', minute: '2-digit' })
    return `${day} ${time}`
}

/** Keeps the mock menu bar clock on the visitor's own time. */
export function startClock(): void {
    const clock = requireElement(ids.clock)
    const update = () => {
        clock.textContent = formatMenubarTime(new Date())
    }

    update()
    setInterval(update, UPDATE_EVERY_MS)
}
