import { describe, expect, it } from 'vite-plus/test'
import { formatMenubarTime } from './clock.ts'

describe('formatMenubarTime', () => {
    it('shows the short weekday and the time', () => {
        const wednesdayEvening = new Date(2026, 10, 25, 21, 30)

        expect(formatMenubarTime(wednesdayEvening, 'en-GB')).toBe('Wed 21:30')
    })

    it('follows the locale', () => {
        const wednesdayEvening = new Date(2026, 10, 25, 21, 30)

        // Newer ICU versions put a narrow no-break space before PM, so match any space.
        expect(formatMenubarTime(wednesdayEvening, 'en-US')).toMatch(/^Wed 09:30\sPM$/)
    })
})
