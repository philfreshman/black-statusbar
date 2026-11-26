interface Point {
    title: string
    text: string
}

const points: Point[] = [
    {
        title: 'Readable at a glance',
        text: 'White icons on solid black, whatever the wallpaper.',
    },
    {
        title: 'The notch blends in',
        text: 'The cut-out disappears into one clean edge.',
    },
    {
        title: 'Your wallpaper stays yours',
        text: 'Never edited or replaced. Turn Nightbar off and it is all back.',
    },
]

function renderPoint({ title, text }: Point): string {
    return /* HTML */ `
        <article>
            <h2>${title}</h2>
            <p>${text}</p>
        </article>
    `
}

export function renderPoints(): string {
    return /* HTML */ `
        <section class="points" aria-label="Why Nightbar">
            ${points.map(renderPoint).join('')}
        </section>
    `
}
