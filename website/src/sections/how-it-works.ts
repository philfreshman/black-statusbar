import { icon } from '../icons.ts'

interface Step {
    tag: string
    title: string
    text: string
}

/** From the bottom up, the way macOS composes the top of the screen. */
const steps: Step[] = [
    {
        tag: 'L1',
        title: 'Your wallpaper',
        text: 'Stays exactly as it is. Nightbar never edits or replaces it.',
    },
    {
        tag: 'L2',
        title: "Nightbar's black strip",
        text: 'A borderless window as tall as the menu bar, slipped in just above the wallpaper and below your windows.',
    },
    {
        tag: 'L3',
        title: 'The menu bar',
        text: 'macOS samples what is behind it, sees black, and draws a black bar with white icons.',
    },
]

function renderStep({ tag, title, text }: Step): string {
    return /* HTML */ `
        <li>
            <span class="label">${tag}</span>
            <div>
                <h3>${title}</h3>
                <p>${text}</p>
            </div>
        </li>
    `
}

function renderMiniMenubar(): string {
    return /* HTML */ `
        <div class="mini-bar">
            <div class="mini-left">
                ${icon('apple', { className: 'mini-apple' })}<b>Finder</b><span>File</span
                ><span>Edit</span><span>View</span>
            </div>
            <div class="mini-right">
                ${icon('mark', { className: 'mini-glyph' })}
                ${icon('wifi', { className: 'mini-glyph' })}
                ${icon('battery', { className: 'mini-glyph mini-battery' })}
                <span>21:30</span>
            </div>
        </div>
    `
}

/** The three planes, stacked bottom to top. The camera has no perspective: an orthographic view. */
function renderStage(): string {
    return /* HTML */ `
        <div class="stage" aria-hidden="true">
            <div class="stage-hud">
                <span class="label">Orthographic camera</span>
                <span class="label">No perspective · 3 layers</span>
            </div>
            <div class="camera">
                <div class="layer layer-wallpaper">
                    <div class="plane">
                        <div class="mini-wallpaper"><div class="mini-cloud"></div></div>
                    </div>
                    <i class="post"></i><i class="post"></i><i class="post"></i><i class="post"></i>
                    <span class="tag label">L1 · Wallpaper</span>
                </div>
                <div class="layer layer-strip">
                    <div class="plane"><div class="strip"></div></div>
                    <span class="tag label">L2 · Nightbar strip</span>
                </div>
                <div class="layer layer-menubar">
                    <div class="plane">${renderMiniMenubar()}</div>
                    <span class="tag label">L3 · Menu bar</span>
                </div>
            </div>
            <p class="stage-result label">= A black bar with white icons</p>
            <div class="stage-progress"></div>
        </div>
    `
}

export function renderHowItWorks(): string {
    return /* HTML */ `
        <section class="how" id="how" aria-labelledby="how-title">
            <div class="how-sticky">
                <div class="how-copy">
                    <p class="eyebrow"><span>02</span> How it works</p>
                    <h2 id="how-title">Three layers. One of them is ours.</h2>
                    <ol class="how-steps">
                        ${steps.map(renderStep).join('')}
                    </ol>
                </div>
                ${renderStage()}
            </div>
        </section>
    `
}
