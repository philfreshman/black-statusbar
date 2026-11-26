import { icon } from '../icons.ts'
import { ids, links } from '../site.ts'
import { renderDesktop } from './desktop.ts'
import { renderInstallCommand } from './install-command.ts'

export function renderHero(): string {
    return /* HTML */ `
        <section class="hero" aria-labelledby="hero-title">
            <div class="hero-head">
                ${icon('mark', { className: 'hero-mark' })}
                <p class="kicker">Free · open source · every display</p>
                <h1 id="hero-title">A black menu bar<br />for <span class="accent">macOS</span></h1>
                <p class="lede">
                    White icons on solid black, on any wallpaper. The notch disappears, your
                    wallpaper stays untouched.
                </p>
                ${renderInstallCommand(ids.installCommand)}
                <div class="actions">
                    <a class="button ghost" href="#how"
                        >How it works ${icon('arrow', { size: 18 })}</a
                    >
                    <a class="button ghost" href="${links.repository}">
                        ${icon('github', { size: 16 })} Source
                    </a>
                </div>
            </div>
            <div class="storm">
                <div class="screen-slot">${renderDesktop()}</div>
            </div>
        </section>
    `
}
