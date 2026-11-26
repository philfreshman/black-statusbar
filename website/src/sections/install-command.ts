import { icon } from '../icons.ts'
import { copyCommand, installCommand } from '../site.ts'

/** The install command in a terminal card, with a button that copies it. */
export function renderInstallCommand(id: string): string {
    return /* HTML */ `
        <div class="command">
            <p class="label">Terminal · macOS 14 or later</p>
            <div class="command-line">
                <code id="${id}">${installCommand}</code>
                <button class="chip copy" type="button" command="${copyCommand}" commandfor="${id}">
                    ${icon('copy', { size: 16 })}
                    <span class="copy-label">Copy</span
                    ><span class="visually-hidden"> install command</span>
                </button>
                <!-- Announces the result. Outside the button, where screen readers reliably read it. -->
                <span class="copy-status visually-hidden" role="status"></span>
            </div>
        </div>
    `
}
