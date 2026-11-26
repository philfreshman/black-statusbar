import { icon } from '../icons.ts'
import { renderMenuEntries } from './app-menu.ts'

const facts = ['Every display', 'All Spaces', 'No special permissions']

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
            <div class="menu-mock-bar">${icon('nightbar', { className: 'glyph' })}</div>
            <ul class="menu-mock-list">
                ${entries}
            </ul>
        </div>
    `
}

export function renderMenuSection(): string {
    return /* HTML */ `
        <section class="menu-section" aria-labelledby="menu-title">
            ${renderMenuMock()}
            <div class="menu-copy">
                <p class="eyebrow">Settings</p>
                <h2 id="menu-title">That is the whole menu.</h2>
                <p>On or off, launch at login, quit. Nothing to tune.</p>
                <ul class="facts">
                    ${facts.map((fact) => `<li>${fact}</li>`).join('')}
                </ul>
            </div>
        </section>
    `
}
