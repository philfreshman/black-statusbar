import { wait } from './dom.ts'

/**
 * Timers that stop counting while paused, so a paused animation picks up where it left off.
 * Several reasons can pause it at once, for example the visitor pressing pause and the
 * animation scrolling out of view; it runs again only once every reason is gone.
 */
export class PausableClock {
    private readonly pauseReasons = new Set<string>()
    private announceStateChange = (): void => {}
    /** Settles the next time the clock pauses or runs again. */
    private stateChanged = this.nextStateChange()

    get isPaused(): boolean {
        return this.pauseReasons.size > 0
    }

    pause(reason: string): void {
        this.update(() => this.pauseReasons.add(reason))
    }

    resume(reason: string): void {
        this.update(() => this.pauseReasons.delete(reason))
    }

    /** Waits until `ms` milliseconds have passed while running, however often it pauses meanwhile. */
    async wait(ms: number): Promise<void> {
        let remaining = ms
        while (remaining > 0) {
            if (this.isPaused) {
                await this.stateChanged
                continue
            }
            const startedAt = performance.now()
            await Promise.race([wait(remaining), this.stateChanged])
            remaining -= performance.now() - startedAt
        }
    }

    private update(change: () => void): void {
        const wasPaused = this.isPaused
        change()
        if (this.isPaused !== wasPaused) {
            this.announceStateChange()
            this.stateChanged = this.nextStateChange()
        }
    }

    private nextStateChange(): Promise<void> {
        return new Promise((resolve) => {
            this.announceStateChange = resolve
        })
    }
}
