import { links } from '../site.ts'

export function renderTopbar(): string {
    return /* HTML */ `
        <header class="topbar">
            <a class="brand" href="#top" aria-label="Nightbar home">
                <img src="/icon.png" alt="" width="28" height="28" />
                <span>Nightbar</span>
            </a>
            <nav class="topbar-links" aria-label="Sections">
                <a href="#how">How it works</a>
                <a href="#install">Install</a>
                <a href="${links.repository}">GitHub</a>
            </nav>
        </header>
    `
}
