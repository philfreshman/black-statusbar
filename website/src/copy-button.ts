import { copyCommand } from './site.ts'

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

type Outcome = 'copied' | 'failed'

const resetTimers = new WeakMap<HTMLButtonElement, ReturnType<typeof setTimeout>>()
let lastAnnouncement = ''

/**
 * VoiceOver skips a message identical to the one before it, even after the region was emptied.
 * A repeated message gets a no-break space, which is not read aloud but makes it differ.
 */
function announce(status: Element, message: string): void {
    const text = message === lastAnnouncement ? `${message} ` : message
    lastAnnouncement = text
    status.textContent = text
}

function show(button: HTMLButtonElement, outcome: Outcome): void {
    const label = button.querySelector('.copy-label')
    const status = button.parentElement?.querySelector('.copy-status')
    if (!label || !status) {
        return
    }

    label.textContent = labels[outcome]
    announce(status, announcements[outcome])
    button.classList.add('is-copied')

    // Clears the status too, so screen reader browse mode finds no stale message.
    clearTimeout(resetTimers.get(button))
    const reset = (): void => {
        label.textContent = labels.idle
        status.textContent = ''
        button.classList.remove('is-copied')
    }
    resetTimers.set(button, setTimeout(reset, RESET_AFTER_MS))
}

async function copy(button: HTMLButtonElement, target: HTMLElement): Promise<void> {
    try {
        await navigator.clipboard.writeText(target.innerText.trim())
        show(button, 'copied')
    } catch {
        getSelection()?.selectAllChildren(target)
        show(button, 'failed')
    }
}

/** Copies for every button with `command="--copy"`, from the element its `commandfor` names. */
function handleCopyCommands(): void {
    // Command events do not bubble, so listen in the capture phase.
    document.addEventListener(
        'command',
        (event) => {
            const { command, source, target } = event as CommandEvent
            if (
                command === copyCommand &&
                source instanceof HTMLButtonElement &&
                target instanceof HTMLElement
            ) {
                void copy(source, target)
            }
        },
        { capture: true },
    )
}

/** For browsers without Invoker Commands: resolves `commandfor` on click, as the browser would. */
function handleCopyClicks(): void {
    document.addEventListener('click', (event) => {
        if (event.defaultPrevented || !(event.target instanceof Element)) {
            return
        }
        const button = event.target.closest<HTMLButtonElement>(`button[command="${copyCommand}"]`)
        const target = document.getElementById(button?.getAttribute('commandfor') ?? '')
        if (button && target) {
            void copy(button, target)
        }
    })
}

/** Wires up the copy buttons, through Invoker Commands where the browser has them. */
export function setUpCopyButtons(): void {
    if ('CommandEvent' in window) {
        handleCopyCommands()
    } else {
        handleCopyClicks()
    }
}
