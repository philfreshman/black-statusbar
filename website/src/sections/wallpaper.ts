/**
 * The wallpaper: violet satin. Folds and creases fan in from a point past the right edge,
 * with a soft sheen falling down the middle. Film grain on top comes from the CSS.
 */

const width = 1600
const height = 1000

const colors = {
    /** The cloth itself, left to right: deep where it is in shadow, lighter under the sheen. */
    base: ['#5a1fe0', '#4513c4', '#7a48e6', '#6630d8', '#5524cc'],
    sheen: '#e3c8ff',
    light: '#d9b8ff',
    shadow: '#1e0660',
}

/** Where every fold meets, well past the right edge, so the folds spread out to the left. */
const vanishingPoint = { x: 3000, y: 470 }
/** How far the folds spread around the vanishing point, in radians. */
const spread = 0.64
/** How far each fold is drawn from the vanishing point: far enough to run off the left edge. */
const foldLength = 4200

/** Blur in viewBox units: wide folds are soft, crease shadows less so, crease highlights nearly sharp. */
const blur = { soft: 12, shadow: 5, crisp: 1.2 }

interface Crease {
    angle: number
    width: number
    bend: number
}

/** A small seeded random generator, so the wallpaper looks the same on every build. */
function seededRandom(seed: number): () => number {
    return () => {
        seed = (seed + 0x6d2b79f5) | 0
        let t = Math.imul(seed ^ (seed >>> 15), 1 | seed)
        t = (t + Math.imul(t ^ (t >>> 7), 61 | t)) ^ t
        return ((t ^ (t >>> 14)) >>> 0) / 4294967296
    }
}

function randomCreases(
    random: () => number,
    count: number,
    [minWidth, maxWidth]: [number, number],
): Crease[] {
    return Array.from({ length: count }, () => ({
        angle: Math.PI + (random() - 0.5) * spread,
        width: minWidth + random() * (maxWidth - minWidth),
        bend: (random() - 0.5) * 320,
    }))
}

const random = seededRandom(11)
const folds = randomCreases(random, 10, [70, 170])
const creases = randomCreases(random, 13, [7, 28])

/** A wedge from the vanishing point that widens towards the left edge, bowed like cloth. */
function foldPath({ angle, width, bend }: Crease): string {
    const dx = Math.cos(angle)
    const dy = Math.sin(angle)
    const [px, py] = [-dy, dx]
    const far = { x: vanishingPoint.x + dx * foldLength, y: vanishingPoint.y + dy * foldLength }
    const mid = {
        x: vanishingPoint.x + dx * foldLength * 0.5 + px * bend,
        y: vanishingPoint.y + dy * foldLength * 0.5 + py * bend,
    }
    const point = (x: number, y: number): string => `${Math.round(x)} ${Math.round(y)}`

    return [
        `M ${point(far.x + px * width, far.y + py * width)}`,
        `Q ${point(mid.x + px * width * 0.5, mid.y + py * width * 0.5)} ${point(vanishingPoint.x, vanishingPoint.y)}`,
        `Q ${point(mid.x - px * width * 0.5, mid.y - py * width * 0.5)} ${point(far.x - px * width, far.y - py * width)}`,
        'Z',
    ].join(' ')
}

/** The shadow sits just below its crease: turned slightly and a little wider. */
function shadowOf(crease: Crease): Crease {
    return {
        ...crease,
        angle: crease.angle - (crease.width * 1.8) / 2600,
        width: crease.width * 1.4,
    }
}

/**
 * Renders the wallpaper scene.
 * `idPrefix` keeps the gradient and filter ids unique when the scene appears more than once on the page.
 */
export function renderWallpaperScene(idPrefix: string): string {
    const id = (name: string): string => `${idPrefix}-${name}`
    const [b0, b1, b2, b3, b4] = colors.base

    const foldPaths = folds
        .map((fold, index) => {
            const tone = index % 2 ? 'light' : 'shadow'
            return `<path d="${foldPath(fold)}" fill="url(#${id(tone)})" opacity=".8" filter="url(#${id('soft')})" />`
        })
        .join('')
    const creasePaths = creases
        .map(
            (crease) =>
                `<path d="${foldPath(shadowOf(crease))}" fill="url(#${id('shadow')})" opacity=".7" filter="url(#${id('shadow-blur')})" />` +
                `<path d="${foldPath(crease)}" fill="url(#${id('light')})" filter="url(#${id('crisp')})" />`,
        )
        .join('')

    return /* HTML */ `
        <svg
            class="scene"
            viewBox="0 0 ${width} ${height}"
            preserveAspectRatio="xMidYMid slice"
            aria-hidden="true"
        >
            <defs>
                <linearGradient id="${id('base')}" x1="0" y1="0" x2="1" y2="0">
                    <stop offset="0" stop-color="${b0}" />
                    <stop offset=".3" stop-color="${b1}" />
                    <stop offset=".55" stop-color="${b2}" />
                    <stop offset=".78" stop-color="${b3}" />
                    <stop offset="1" stop-color="${b4}" />
                </linearGradient>
                <radialGradient id="${id('sheen')}" cx=".5" cy=".5" r=".5">
                    <stop offset="0" stop-color="${colors.sheen}" stop-opacity=".45" />
                    <stop offset="1" stop-color="${colors.sheen}" stop-opacity="0" />
                </radialGradient>
                ${renderFadeAcross(id('light'), colors.light, [0.05, 0.45, 0.9])}
                ${renderFadeAcross(id('shadow'), colors.shadow, [0.25, 0.4, 0.6])}
                ${renderBlur(id('soft'), blur.soft)} ${renderBlur(id('shadow-blur'), blur.shadow)}
                ${renderBlur(id('crisp'), blur.crisp)}
            </defs>
            <rect width="${width}" height="${height}" fill="url(#${id('base')})" />
            ${foldPaths}
            <ellipse
                cx="860"
                cy="500"
                rx="240"
                ry="1000"
                fill="url(#${id('sheen')})"
                transform="rotate(-6 860 500)"
            />
            ${creasePaths}
        </svg>
    `
}

/** Faint on the left, strong on the right, where the folds gather. */
function renderFadeAcross(
    id: string,
    color: string,
    [left, middle, right]: [number, number, number],
): string {
    return /* HTML */ `
        <linearGradient
            id="${id}"
            gradientUnits="userSpaceOnUse"
            x1="0"
            y1="0"
            x2="${width}"
            y2="0"
        >
            <stop offset="0" stop-color="${color}" stop-opacity="${left}" />
            <stop offset=".45" stop-color="${color}" stop-opacity="${middle}" />
            <stop offset="1" stop-color="${color}" stop-opacity="${right}" />
        </linearGradient>
    `
}

function renderBlur(id: string, amount: number): string {
    return /* HTML */ `
        <filter id="${id}" x="-20%" y="-50%" width="140%" height="200%">
            <feGaussianBlur stdDeviation="${amount}" />
        </filter>
    `
}
