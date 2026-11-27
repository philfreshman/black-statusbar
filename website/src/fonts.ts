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
 * Waits until the page fonts have loaded or failed, so text has its final size.
 * A font that fails to load does not block: the fallback font stays instead.
 */
export async function waitForPageFonts(): Promise<void> {
    await Promise.allSettled(pageFonts.map((font) => document.fonts.load(font)))
    await document.fonts.ready
}
