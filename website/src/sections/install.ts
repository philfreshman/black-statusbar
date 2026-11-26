import { icon } from '../icons.ts'
import { links } from '../site.ts'

interface Step {
    title: string
    /** Trusted HTML, so steps can use <strong>. */
    html: string
}

const steps: Step[] = [
    {
        title: 'Download',
        html: 'Unzip and move <strong>Nightbar</strong> to Applications.',
    },
    {
        title: 'Open it',
        html: 'Not notarized yet. If macOS refuses, click <strong>Open Anyway</strong> in Privacy &amp; Security.',
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
                <p class="eyebrow"><span>04</span> Install by hand</p>
                <h2 id="install-title">Rather skip Terminal?</h2>
            </div>
            <ol class="steps">
                ${steps.map(renderStep).join('')}
            </ol>
            <div class="install-cta">
                <p class="install-big">Lights out<span class="volt">.</span></p>
                <div class="actions">
                    <a class="button primary" href="${links.download}">
                        ${icon('download', { size: 18 })} Download Nightbar
                    </a>
                    <a class="button ghost" href="${links.installScriptSource}">
                        Read the install script ${icon('arrow', { size: 18 })}
                    </a>
                </div>
            </div>
        </section>
    `
}
