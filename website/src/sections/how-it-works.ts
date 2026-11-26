interface Layer {
    className: string
    label: string
}

/** From top to bottom, as macOS stacks them. */
const layers: Layer[] = [
    { className: 'layer-windows', label: 'Windows and desktop icons' },
    { className: 'layer-strip', label: "Nightbar's black strip" },
    { className: 'layer-wallpaper', label: 'Your wallpaper, untouched' },
]

function renderLayer({ className, label }: Layer): string {
    return /* HTML */ `
        <div class="layer ${className}">
            <div class="plane"></div>
            <span>${label}</span>
        </div>
    `
}

export function renderHowItWorks(): string {
    return /* HTML */ `
        <section class="how" id="how" aria-labelledby="how-title">
            <div class="how-copy">
                <p class="eyebrow">How it works</p>
                <h2 id="how-title">One thin black strip, slipped in under everything.</h2>
                <p>
                    A black strip sits behind the menu bar, above the wallpaper and below your
                    windows. macOS sees black, so it draws a black bar with white icons.
                </p>
            </div>
            <div class="stack" aria-hidden="true">${layers.map(renderLayer).join('')}</div>
        </section>
    `
}
