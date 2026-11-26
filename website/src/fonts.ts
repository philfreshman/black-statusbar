import { loadingClass } from './site.ts'

/**
 * The font faces the page uses, as CSS font shorthands. Loading a face by name fetches only the
 * subset that covers Latin text, the same files index.html preloads.
 */
const pageFonts = [
    '1em "Geist Variable"',
    '1em "Geist Mono Variable"',
    '1em "Space Grotesk Variable"',
]

/**
 * Waits for the page fonts, then shows the page that index.html hid while they loaded.
 * A font that fails to load does not keep the page hidden: the fallback font shows instead.
 */
export async function revealPageWhenFontsReady(): Promise<void> {
    await Promise.allSettled(pageFonts.map((font) => document.fonts.load(font)))
    await document.fonts.ready
    document.documentElement.classList.remove(loadingClass)
}
