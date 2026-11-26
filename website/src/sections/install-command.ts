import { icon } from '../icons.ts'
import { installCommand } from '../site.ts'

/** The install command in a terminal card, with a button that copies it. */
export function renderInstallCommand(id: string): string {
    return /* HTML */ `
        <div class="command">
            <p class="label">Terminal · macOS 14 or later</p>
            <div class="command-line">
                <code id="${id}">${installCommand}</code>
                <button class="copy" type="button" data-copy="${id}">
                    ${icon('copy', { size: 16 })}
                    <span class="copy-label">Copy</span>
                </button>
            </div>
        </div>
    `
}
