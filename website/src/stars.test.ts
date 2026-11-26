import { describe, expect, it } from 'vite-plus/test'
import { formatStarCount } from './stars.ts'

describe('formatStarCount', () => {
    it('shows small counts as they are', () => {
        expect(formatStarCount(7)).toBe('7')
        expect(formatStarCount(999)).toBe('999')
    })

    it('shortens thousands like GitHub', () => {
        expect(formatStarCount(1234)).toBe('1.2k')
        expect(formatStarCount(15_300)).toBe('15.3k')
    })
})
