import { requireElement } from './dom.ts'

const RESET_AFTER_MS = 1800

const labels = {
    idle: 'Copy',
    copied: 'Copied',
    /** Shown when the clipboard is blocked: the text is selected for the visitor instead. */
    failed: 'Press ⌘C',
} as const

/** What screen readers hear, through the status region next to the button. */
const announcements = {
    copied: 'Install command copied',
    failed: 'Copy failed. The command is selected: press Command C to copy it.',
} as const

function setUpCopyButton(button: HTMLButtonElement): void {
    const targetId = button.dataset.copy
    const label = button.querySelector('.copy-label')
    const status = button.parentElement?.querySelector('.copy-status')
    if (!targetId || !label || !status) {
        return
    }

    const target = requireElement(targetId)
    let resetTimer: ReturnType<typeof setTimeout> | undefined

    const show = (outcome: 'copied' | 'failed'): void => {
        label.textContent = labels[outcome]
        status.textContent = announcements[outcome]
        button.classList.add('is-copied')
    }

    /** Clears the status too, so screen reader browse mode finds no stale message. */
    const reset = (): void => {
        label.textContent = labels.idle
        status.textContent = ''
        button.classList.remove('is-copied')
    }

    button.addEventListener('click', async () => {
        try {
            await navigator.clipboard.writeText(target.textContent?.trim() ?? '')
            show('copied')
        } catch {
            getSelection()?.selectAllChildren(target)
            show('failed')
        }

        clearTimeout(resetTimer)
        resetTimer = setTimeout(reset, RESET_AFTER_MS)
    })
}

/** Wires up every button with a data-copy attribute, which names the element to copy. */
export function setUpCopyButtons(): void {
    document.querySelectorAll<HTMLButtonElement>('button[data-copy]').forEach(setUpCopyButton)
}
