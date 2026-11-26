import { afterEach, beforeEach, describe, expect, it, vi } from 'vite-plus/test'
import { PausableClock } from './pausable-clock.ts'

describe('PausableClock', () => {
    beforeEach(() => {
        vi.useFakeTimers({ toFake: ['setTimeout', 'clearTimeout', 'performance'] })
    })

    afterEach(() => {
        vi.useRealTimers()
    })

    function track(promise: Promise<void>): { isDone: () => boolean } {
        let done = false
        void promise.then(() => {
            done = true
        })
        return { isDone: () => done }
    }

    it('waits the given time while running', async () => {
        const waiting = track(new PausableClock().wait(1000))

        await vi.advanceTimersByTimeAsync(999)
        expect(waiting.isDone()).toBe(false)

        await vi.advanceTimersByTimeAsync(1)
        expect(waiting.isDone()).toBe(true)
    })

    it('stops counting while paused and carries on where it left off', async () => {
        const clock = new PausableClock()
        const waiting = track(clock.wait(1000))

        await vi.advanceTimersByTimeAsync(400)
        clock.pause('visitor')
        await vi.advanceTimersByTimeAsync(5000)
        expect(waiting.isDone()).toBe(false)

        clock.resume('visitor')
        await vi.advanceTimersByTimeAsync(599)
        expect(waiting.isDone()).toBe(false)

        await vi.advanceTimersByTimeAsync(1)
        expect(waiting.isDone()).toBe(true)
    })

    it('runs again only once every reason to pause is gone', async () => {
        const clock = new PausableClock()
        clock.pause('visitor')
        clock.pause('offscreen')

        clock.resume('offscreen')
        expect(clock.isPaused).toBe(true)

        clock.resume('visitor')
        expect(clock.isPaused).toBe(false)
    })
})
