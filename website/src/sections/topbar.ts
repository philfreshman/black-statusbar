import { icon } from '../icons.ts'
import { ids, links } from '../site.ts'

/** Links to the repository; stars.ts fills in the star count once GitHub answers. */
function renderStarBadge(): string {
    return /* HTML */ `
        <a class="button primary small stars" href="${links.repository}">
            ${icon('github', { size: 16 })}
            <span>Star</span>
            <span class="star-count" id="${ids.starCount}" hidden></span>
        </a>
    `
}

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
            </nav>
            ${renderStarBadge()}
        </header>
    `
}
