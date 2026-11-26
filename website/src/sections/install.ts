import { icon } from '../icons.ts'
import { ids, links } from '../site.ts'
import { renderInstallCommand } from './install-command.ts'

interface Step {
    title: string
    /** Trusted HTML, so steps can use <strong>. */
    html: string
}

const steps: Step[] = [
    {
        title: 'Paste it',
        html: 'Copy the command into <strong>Terminal</strong> and press Return. It fetches the latest release from GitHub.',
    },
    {
        title: 'It opens by itself',
        html: 'Nightbar lands in <strong>Applications</strong> and starts. curl sets no quarantine flag, so macOS opens it without a warning.',
    },
    {
        title: 'Keep it',
        html: 'Turn on <strong>Launch at Login</strong> in its menu.',
    },
]

function renderStep({ title, html }: Step, index: number): string {
    return /* HTML */ `
        <li>
            <span class="step-number">0${index + 1}</span>
            <h3>${title}</h3>
            <p>${html}</p>
        </li>
    `
}

export function renderInstall(): string {
    return /* HTML */ `
        <section class="install" id="install" aria-labelledby="install-title">
            <div class="section-head">
                <p class="eyebrow"><span>04</span> Install</p>
                <h2 id="install-title">One line in Terminal.</h2>
            </div>
            <ol class="steps">
                ${steps.map(renderStep).join('')}
            </ol>
            <div class="install-cta">
                <p class="install-big">Lights out<span class="accent">.</span></p>
                ${renderInstallCommand(ids.installCommandClosing)}
                <a class="button ghost" href="${links.installScriptSource}">
                    Read the install script ${icon('arrow', { size: 18 })}
                </a>
            </div>
        </section>
    `
}
