import { icon, type IconName } from '../icons.ts'

interface Point {
    icon: IconName
    title: string
    text: string
}

const points: Point[] = [
    {
        icon: 'contrast',
        title: 'Readable at a glance',
        text: 'White icons on solid black, whatever the wallpaper.',
    },
    {
        icon: 'notch',
        title: 'The notch blends in',
        text: 'The cut-out disappears into one clean edge.',
    },
    {
        icon: 'wallpaper',
        title: 'Your wallpaper stays yours',
        text: 'Never edited or replaced. Turn Nightbar off and it is all back.',
    },
]

function renderPoint({ icon: name, title, text }: Point, index: number): string {
    return /* HTML */ `
        <article>
            <div class="point-top">
                ${icon(name, { className: 'point-icon' })}
                <span class="label">0${index + 1}</span>
            </div>
            <h3>${title}</h3>
            <p>${text}</p>
        </article>
    `
}

export function renderPoints(): string {
    return /* HTML */ `
        <section class="points" aria-labelledby="points-title">
            <div class="section-head">
                <p class="eyebrow"><span>01</span> Why Nightbar</p>
                <h2 id="points-title">Less glare up top.</h2>
            </div>
            <div class="points-grid">${points.map(renderPoint).join('')}</div>
        </section>
    `
}
