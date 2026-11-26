import { renderFooter } from './sections/footer.ts'
import { renderHero } from './sections/hero.ts'
import { renderHowItWorks } from './sections/how-it-works.ts'
import { renderInstall } from './sections/install.ts'
import { renderMenuSection } from './sections/menu.ts'
import { renderPoints } from './sections/points.ts'
import { renderTopbar } from './sections/topbar.ts'

/** The whole page body. vite.config.ts renders it into index.html at build time. */
export function renderPage(): string {
    return /* HTML */ `
        ${renderTopbar()}
        <main id="top">
            ${renderHero()} ${renderPoints()} ${renderHowItWorks()} ${renderMenuSection()}
            ${renderInstall()}
        </main>
        ${renderFooter()}
    `
}
