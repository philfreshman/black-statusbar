interface IconShape {
    viewBox: string
    content: string
}

/** Wraps line-icon paths in the shared 1.5px round stroke, so the set stays consistent. */
function line(paths: string): string {
    return /* HTML */ `
        <g
            fill="none"
            stroke="currentColor"
            stroke-width="1.5"
            stroke-linecap="round"
            stroke-linejoin="round"
        >
            ${paths}
        </g>
    `
}

/** The thunder N: two stems joined by a diagonal that breaks like a lightning bolt. */
export const markPath = 'M4 4H9L18 13V16.5L23 21.5V4H28V28H23L14 19V15.5L9 10.5V28H4Z'

const shapes = {
    mark: {
        viewBox: '0 0 32 32',
        content: `<path d="${markPath}" fill="currentColor" />`,
    },
    nightbar: {
        viewBox: '0 0 20 16',
        content: /* HTML */ `
            <rect
                x="1.85"
                y="1.85"
                width="16.3"
                height="12.3"
                rx="2.6"
                fill="none"
                stroke="currentColor"
                stroke-width="1.7"
            />
            <rect x="1" y="1" width="18" height="4.6" rx="3.4" fill="currentColor" />
            <rect x="1" y="3" width="18" height="2.6" fill="currentColor" />
        `,
    },
    apple: {
        viewBox: '0 0 14 17',
        content: /* HTML */ `
            <path
                d="M11.6 9.1c0-1.9 1.6-2.8 1.6-2.9-.9-1.3-2.2-1.4-2.7-1.5-1.1-.1-2.2.7-2.8.7-.6 0-1.5-.7-2.4-.6C4 4.8 2.8 5.5 2.2 6.7c-1.3 2.2-.3 5.5.9 7.3.6.9 1.3 1.9 2.3 1.8.9 0 1.3-.6 2.4-.6s1.4.6 2.4.6c1 0 1.6-.9 2.2-1.8.7-1 1-2 1-2.1 0 0-1.8-.7-1.8-2.8zM9.8 3.4c.5-.6.8-1.4.7-2.2-.7 0-1.6.5-2.1 1.1-.5.5-.9 1.4-.8 2.2.8.1 1.6-.4 2.2-1.1z"
                fill="currentColor"
            />
        `,
    },
    wifi: {
        viewBox: '0 0 20 16',
        content: /* HTML */ `
            <path
                d="M1.8 6.8a11.6 11.6 0 0 1 16.4 0M5.2 10.2a6.8 6.8 0 0 1 9.6 0"
                fill="none"
                stroke="currentColor"
                stroke-width="2.4"
                stroke-linecap="round"
            />
            <path
                d="M10 15 7.6 12.6a3.4 3.4 0 0 1 4.8 0z"
                fill="currentColor"
                stroke="currentColor"
                stroke-width="1.2"
                stroke-linejoin="round"
            />
        `,
    },
    battery: {
        viewBox: '0 0 28 14',
        content: /* HTML */ `
            <rect
                x="1"
                y="1.5"
                width="23"
                height="11"
                rx="3.4"
                fill="none"
                stroke="currentColor"
                stroke-width="1.2"
                opacity=".6"
            />
            <rect x="2.9" y="3.4" width="17.5" height="7.2" rx="1.9" fill="currentColor" />
            <path d="M25.3 5v4a2 2 0 0 0 0-4z" fill="currentColor" opacity=".45" />
        `,
    },
    controlCenter: {
        viewBox: '0 0 20 16',
        content: /* HTML */ `
            <rect
                x="1.6"
                y="1.4"
                width="16.8"
                height="6"
                rx="3"
                fill="none"
                stroke="currentColor"
                stroke-width="1.6"
            />
            <circle cx="15.2" cy="4.4" r="1.9" fill="currentColor" />
            <rect
                x="1.6"
                y="8.6"
                width="16.8"
                height="6"
                rx="3"
                fill="none"
                stroke="currentColor"
                stroke-width="1.6"
            />
            <circle cx="4.8" cy="11.6" r="1.9" fill="currentColor" />
        `,
    },
    cursor: {
        viewBox: '0 0 24 24',
        content: /* HTML */ `
            <path
                d="M5 2.5v17.2l4.3-4.1 2.8 6.4 3-1.3-2.8-6.3h6z"
                fill="#000"
                stroke="#fff"
                stroke-width="1.4"
                stroke-linejoin="round"
            />
        `,
    },
    contrast: {
        viewBox: '0 0 24 24',
        content: line(/* HTML */ `
            <circle cx="12" cy="12" r="8.5" />
            <path d="M12 3.5a8.5 8.5 0 0 1 0 17z" fill="currentColor" />
        `),
    },
    notch: {
        viewBox: '0 0 24 24',
        content: line(/* HTML */ `
            <rect x="2.75" y="4.5" width="18.5" height="15" rx="2.5" />
            <path
                d="M2.75 8.5h18.5V7a2.5 2.5 0 0 0-2.5-2.5H5.25A2.5 2.5 0 0 0 2.75 7z"
                fill="currentColor"
            />
        `),
    },
    wallpaper: {
        viewBox: '0 0 24 24',
        content: line(/* HTML */ `
            <rect x="2.75" y="4.5" width="18.5" height="15" rx="2.5" />
            <path d="m3 16.5 5-5 4.5 4.5 2.5-2.5 6 6" />
            <circle cx="16" cy="9" r="1.5" />
        `),
    },
    displays: {
        viewBox: '0 0 24 24',
        content: line(/* HTML */ `
            <rect x="2.75" y="5" width="11.5" height="8.5" rx="1.5" />
            <rect x="12.5" y="8.5" width="8.75" height="7" rx="1.5" />
            <path d="M6.5 17.5h4M8.5 13.5v4" />
        `),
    },
    spaces: {
        viewBox: '0 0 24 24',
        content: line(/* HTML */ `
            <rect x="6" y="9" width="15.25" height="10.5" rx="1.5" />
            <path d="M3 15V7.25c0-.83.67-1.5 1.5-1.5H17" />
        `),
    },
    shield: {
        viewBox: '0 0 24 24',
        content: line(/* HTML */ `
            <path d="M12 3 4.75 5.75v5.5c0 4.4 3 8 7.25 9.75 4.25-1.75 7.25-5.35 7.25-9.75v-5.5z" />
            <path d="m9 12 2.2 2.2L15.5 10" />
        `),
    },
    download: {
        viewBox: '0 0 24 24',
        content: line(
            /* HTML */ `<path
                d="M12 3.5v11m-4.5-4.5L12 14.5l4.5-4.5M4.5 17.5v1.25c0 .97.78 1.75 1.75 1.75h11.5c.97 0 1.75-.78 1.75-1.75V17.5"
            />`,
        ),
    },
    arrow: {
        viewBox: '0 0 24 24',
        content: line(/* HTML */ `<path d="M5 12h14m-5.5-5.5L19 12l-5.5 5.5" />`),
    },
    check: {
        viewBox: '0 0 24 24',
        content: line(/* HTML */ `<path d="m5.5 12.5 4 4 9-9" />`),
    },
    copy: {
        viewBox: '0 0 24 24',
        content: line(/* HTML */ `
            <rect x="8.25" y="8.25" width="12" height="12" rx="2" />
            <path
                d="M15.75 5.5v-.25a1.5 1.5 0 0 0-1.5-1.5h-8.5a2 2 0 0 0-2 2v8.5a1.5 1.5 0 0 0 1.5 1.5h.25"
            />
        `),
    },
    github: {
        viewBox: '0 0 16 16',
        content: /* HTML */ `
            <path
                fill="currentColor"
                d="M8 0C3.58 0 0 3.58 0 8c0 3.54 2.29 6.53 5.47 7.59.4.07.55-.17.55-.38 0-.19-.01-.82-.01-1.49-2.01.37-2.53-.49-2.69-.94-.09-.23-.48-.94-.82-1.13-.28-.15-.68-.52-.01-.53.63-.01 1.08.58 1.23.82.72 1.21 1.87.87 2.33.66.07-.52.28-.87.51-1.07-1.78-.2-3.64-.89-3.64-3.95 0-.87.31-1.59.82-2.15-.08-.2-.36-1.02.08-2.12 0 0 .67-.21 2.2.82.64-.18 1.32-.27 2-.27.68 0 1.36.09 2 .27 1.53-1.04 2.2-.82 2.2-.82.44 1.1.16 1.92.08 2.12.51.56.82 1.27.82 2.15 0 3.07-1.87 3.75-3.65 3.95.29.25.54.73.54 1.48 0 1.07-.01 1.93-.01 2.2 0 .21.15.46.55.38A8.013 8.013 0 0 0 16 8c0-4.42-3.58-8-8-8z"
            />
        `,
    },
} satisfies Record<string, IconShape>

export type IconName = keyof typeof shapes

interface IconOptions {
    className?: string
    id?: string
    /** Width and height in pixels. Without it, CSS sizes the icon. */
    size?: number
}

/** A decorative inline SVG icon, hidden from screen readers. */
export function icon(name: IconName, { className, id, size }: IconOptions = {}): string {
    const { viewBox, content } = shapes[name]
    const attributes = [
        className && `class="${className}"`,
        id && `id="${id}"`,
        `viewBox="${viewBox}"`,
        size && `width="${size}" height="${size}"`,
        'aria-hidden="true"',
    ]
        .filter(Boolean)
        .join(' ')

    return `<svg ${attributes}>${content}</svg>`
}
