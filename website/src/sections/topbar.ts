import { icon } from '../icons.ts'
import { links } from '../site.ts'

export function renderTopbar(): string {
    return /* HTML */ `
        <header class="topbar rail">
            <a class="skip-link" href="#top">Skip to content</a>
            <a class="brand" href="#top" aria-label="Nightbar home">
                ${icon('mark', { className: 'brand-mark' })}
                <span>Nightbar</span>
            </a>
            <nav class="topbar-links" aria-label="Site">
                <a class="section-link" href="#how">How it works</a>
                <a class="section-link" href="#install">Install</a>
                <a href="${links.repository}">GitHub</a>
            </nav>
        </header>
    `
}
