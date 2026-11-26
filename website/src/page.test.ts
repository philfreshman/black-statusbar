// @vitest-environment happy-dom
import { beforeAll, describe, expect, it } from 'vite-plus/test'
import { renderPage } from './page.ts'
import { ids, installCommand } from './site.ts'

function parsePage(): Document {
    return new DOMParser().parseFromString(renderPage(), 'text/html')
}

describe('renderPage', () => {
    let page: Document

    beforeAll(() => {
        page = parsePage()
    })

    it('renders one top bar, main landmark and footer', () => {
        expect(page.querySelectorAll('body > header.topbar')).toHaveLength(1)
        expect(page.querySelectorAll('body > main#top')).toHaveLength(1)
        expect(page.querySelectorAll('body > footer.footer')).toHaveLength(1)
    })

    it('has a single top-level heading', () => {
        const headings = page.querySelectorAll('h1')

        expect(headings).toHaveLength(1)
        expect(headings[0].textContent).toContain('A black menu bar')
        expect(headings[0].querySelector('.accent')?.textContent).toBe('macOS')
    })

    it('renders every section in order', () => {
        const sections = [...page.querySelectorAll('main > section')].map(
            (section) => section.className,
        )

        expect(sections).toEqual(['hero', 'points', 'how', 'menu-section', 'install'])
    })

    it('renders every element the browser scripts look up', () => {
        for (const id of Object.values(ids)) {
            expect(page.querySelectorAll(`#${id}`), `#${id}`).toHaveLength(1)
        }
    })

    it('gives every in-page link a target', () => {
        for (const link of page.querySelectorAll('a[href^="#"]')) {
            const id = link.getAttribute('href')?.slice(1)
            expect(page.getElementById(id ?? ''), `#${id}`).not.toBeNull()
        }
    })

    it('shows the install command next to every copy button', () => {
        const buttons = [...page.querySelectorAll<HTMLButtonElement>('button[data-copy]')]

        expect(buttons.length).toBeGreaterThan(0)
        for (const button of buttons) {
            const target = page.getElementById(button.dataset.copy ?? '')
            expect(target?.textContent).toBe(installCommand)
        }
    })

    it('installs through the command, not a direct download', () => {
        expect(page.querySelector('a[href$="Nightbar.zip"]')).toBeNull()
    })

    it('starts the demo with Nightbar off and Launch at Login on', () => {
        const desktop = page.getElementById(ids.desktop)
        const menuItems = [...page.querySelectorAll('.status-menu li:not(.sep)')]

        expect(desktop?.dataset.nightbar).toBe('off')
        expect(menuItems.map((item) => item.classList.contains('checked'))).toEqual([
            false,
            true,
            false,
        ])
    })

    it('hides decorative icons from screen readers', () => {
        const icons = [...page.querySelectorAll('svg')]

        expect(icons.length).toBeGreaterThan(0)
        for (const icon of icons) {
            expect(icon.getAttribute('aria-hidden')).toBe('true')
        }
    })
})
