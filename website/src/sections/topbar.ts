import { icon } from '../icons.ts'
import { links } from '../site.ts'

export function renderTopbar(): string {
    return /* HTML */ `
        <header class="topbar rail">
            <a class="brand" href="#top" aria-label="Nightbar home">
                ${icon('mark', { className: 'brand-mark' })}
                <span>Nightbar</span>
            </a>
            <nav class="topbar-links" aria-label="Sections">
                <a href="#how">How it works</a>
                <a href="#install">Install</a>
                <a href="${links.repository}">GitHub</a>
            </nav>
            <a class="button primary small" href="${links.download}">
                ${icon('download', { size: 16 })} Download
            </a>
        </header>
    `
}
