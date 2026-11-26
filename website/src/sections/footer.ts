import { icon } from '../icons.ts'
import { links } from '../site.ts'

interface LinkGroup {
    title: string
    links: { label: string; href: string }[]
}

const groups: LinkGroup[] = [
    {
        title: 'Project',
        links: [
            { label: 'GitHub', href: links.repository },
            { label: 'Releases', href: links.releases },
            { label: 'Install script', href: links.installScriptSource },
        ],
    },
    {
        title: 'On this page',
        links: [
            { label: 'How it works', href: '#how' },
            { label: 'Install', href: '#install' },
        ],
    },
]

function renderGroup({ title, links: groupLinks }: LinkGroup): string {
    return /* HTML */ `
        <nav class="footer-group" aria-label="${title}">
            <p class="label">${title}</p>
            ${groupLinks.map(({ label, href }) => `<a href="${href}">${label}</a>`).join('')}
        </nav>
    `
}

export function renderFooter(): string {
    return /* HTML */ `
        <footer class="footer rail">
            <div class="footer-top">
                <div class="footer-brand">
                    ${icon('mark', { className: 'brand-mark' })}
                    <p>A black menu bar for macOS.<br />Free and open source.</p>
                </div>
                ${groups.map(renderGroup).join('')}
            </div>
            <p class="footer-base label">Nightbar · for macOS 14 and later</p>
        </footer>
    `
}
