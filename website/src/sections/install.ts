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

function renderStep({ title, html }: Step): string {
    return /* HTML */ `
        <li>
            <h3>${title}</h3>
            <p>${html}</p>
        </li>
    `
}

export function renderInstall(): string {
    return /* HTML */ `
        <section class="install" id="install" aria-labelledby="install-title">
            <p class="eyebrow">Install by hand</p>
            <h2 id="install-title">Rather skip Terminal?</h2>
            <ol class="steps">
                ${steps.map(renderStep).join('')}
            </ol>
            <a class="button primary" href="${links.download}">Download Nightbar</a>
            <p class="install-alt">
                <a href="${links.installScriptSource}">Read the install script</a>
            </p>
        </section>
    `
}
