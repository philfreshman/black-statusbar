import { icon, type IconName } from '../icons.ts'
import { renderMenuEntries } from './app-menu.ts'

interface Fact {
    icon: IconName
    label: string
}

const facts: Fact[] = [
    { icon: 'displays', label: 'Every display' },
    { icon: 'spaces', label: 'All Spaces' },
    { icon: 'shield', label: 'No special permissions' },
]

function renderMenuMock(): string {
    const entries = renderMenuEntries([
        { label: 'Nightbar', checked: true },
        'separator',
        { label: 'Launch at Login', checked: true },
        'separator',
        { label: 'Quit', shortcut: '⌘Q' },
    ])

    return /* HTML */ `
        <div class="menu-mock" aria-hidden="true">
            <div class="menu-mock-bar">
                <span class="menu-mock-item">${icon('mark', { className: 'glyph' })}</span>
                ${icon('wifi', { className: 'glyph' })}
                ${icon('battery', { className: 'glyph battery' })}
            </div>
            <ul class="menu-mock-list">
                ${entries}
            </ul>
        </div>
    `
}

function renderFact({ icon: name, label }: Fact): string {
    return `<li>${icon(name, { className: 'fact-icon' })}${label}</li>`
}

export function renderMenuSection(): string {
    return /* HTML */ `
        <section class="menu-section" aria-labelledby="menu-title">
            <div class="menu-copy">
                <p class="eyebrow"><span>03</span> Settings</p>
                <h2 id="menu-title">That is the whole menu.</h2>
                <p>On or off, launch at login, quit. Nothing to tune.</p>
                <ul class="facts" role="list">
                    ${facts.map(renderFact).join('')}
                </ul>
            </div>
            <div class="menu-stage storm">${renderMenuMock()}</div>
        </section>
    `
}
