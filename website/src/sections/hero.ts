import { icon } from '../icons.ts'
import { ids, installCommand, links } from '../site.ts'
import { renderDesktop } from './desktop.ts'

function renderInstallCommand(): string {
    return /* HTML */ `
        <div class="command">
            <p class="label">macOS 14 or later · Terminal</p>
            <div class="command-line">
                <code id="${ids.installCommand}">${installCommand}</code>
                <button class="copy" type="button" data-copy="${ids.installCommand}">
                    ${icon('copy', { size: 16 })}
                    <span class="copy-label">Copy</span>
                </button>
            </div>
        </div>
    `
}

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
                <div class="actions">
                    <a class="button primary" href="${links.download}">
                        ${icon('download', { size: 18 })} Download
                    </a>
                    <a class="button" href="#how">How it works ${icon('arrow', { size: 18 })}</a>
                    <a class="button ghost" href="${links.repository}">
                        ${icon('github', { size: 16 })} Source
                    </a>
                </div>
            </div>
            <div class="storm">
                <div class="screen-slot">${renderDesktop()}</div>
            </div>
            <div class="hero-install">
                <div class="cell">
                    <p class="eyebrow"><span>00</span> Quick install</p>
                    <h2>One line, then it just runs.</h2>
                    <p>
                        Works with regular and live wallpapers. Turn on Launch at Login and forget
                        about it.
                    </p>
                </div>
                <div class="cell">${renderInstallCommand()}</div>
            </div>
        </section>
    `
}
