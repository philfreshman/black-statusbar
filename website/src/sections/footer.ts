import { links } from '../site.ts'

export function renderFooter(): string {
    return /* HTML */ `
        <footer class="footer">
            <img src="/icon.png" alt="" width="20" height="20" />
            <span>Nightbar</span>
            <a href="${links.repository}">GitHub</a>
            <a href="${links.releases}">Releases</a>
        </footer>
    `
}
