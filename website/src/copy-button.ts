import { requireElement } from './dom.ts'

const RESET_AFTER_MS = 1800

const labels = {
    idle: 'Copy',
    copied: 'Copied',
    /** Shown when the clipboard is blocked: the text is selected for the visitor instead. */
    failed: 'Press ⌘C',
} as const

function setUpCopyButton(button: HTMLButtonElement): void {
    const targetId = button.dataset.copy
    const label = button.querySelector('.copy-label')
    if (!targetId || !label) {
        return
    }

    const target = requireElement(targetId)
    let resetTimer: ReturnType<typeof setTimeout> | undefined

    button.addEventListener('click', async () => {
        try {
            await navigator.clipboard.writeText(target.textContent?.trim() ?? '')
            label.textContent = labels.copied
        } catch {
            label.textContent = labels.failed
            getSelection()?.selectAllChildren(target)
        }

        button.classList.add('is-copied')
        clearTimeout(resetTimer)
        resetTimer = setTimeout(() => {
            label.textContent = labels.idle
            button.classList.remove('is-copied')
        }, RESET_AFTER_MS)
    })
}

/** Wires up every button with a data-copy attribute, which names the element to copy. */
export function setUpCopyButtons(): void {
    document.querySelectorAll<HTMLButtonElement>('button[data-copy]').forEach(setUpCopyButton)
}
