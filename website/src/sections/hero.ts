import { icon } from '../icons.ts'
import { ids, installCommand, links } from '../site.ts'
import { renderDesktop } from './desktop.ts'

function renderInstallCommand(): string {
    return /* HTML */ `
        <div class="command">
            <code id="${ids.installCommand}">${installCommand}</code>
            <button class="copy" type="button" data-copy="${ids.installCommand}">
                ${icon('copy', { size: 16 })}
                <span class="copy-label">Copy</span>
            </button>
        </div>
    `
}

export function renderHero(): string {
    return /* HTML */ `
        <section class="hero" aria-labelledby="hero-title">
            <h1 id="hero-title">A black menu bar<br />for <span class="dusk">macOS</span></h1>
            <div class="screen-slot">${renderDesktop()}</div>
            <p class="works-with">Works with regular and live wallpapers.</p>
            ${renderInstallCommand()}
            <a class="source" href="${links.repository}">
                Source ${icon('github', { size: 16 })}
            </a>
        </section>
    `
}
