import { Window } from 'happy-dom'
import { fileURLToPath } from 'node:url'
import { build } from 'vite-plus'
import { beforeAll, describe, expect, it } from 'vite-plus/test'

const projectRoot = fileURLToPath(new URL('..', import.meta.url))

interface BuildOutput {
    html: string
    fileNames: string[]
    /** The text of each emitted file, by file name. */
    sources: Map<string, string>
}

type BuildResult = Awaited<ReturnType<typeof build>>

/** With `write: false` a build returns its output in memory; a watcher result (never used here) has none. */
function outputFiles(result: BuildResult) {
    if (Array.isArray(result)) {
        return result.flatMap((bundle) => bundle.output)
    }
    if ('output' in result) {
        return result.output
    }
    return []
}

/** Runs the real production build in memory, so nothing is written to dist/. */
async function buildSite(): Promise<BuildOutput> {
    const result = await build({ root: projectRoot, logLevel: 'silent', build: { write: false } })
    const outputs = outputFiles(result)
    const indexHtml = outputs.find((file) => file.fileName === 'index.html')

    if (indexHtml?.type !== 'asset') {
        throw new Error('The build did not emit index.html')
    }

    return {
        html: String(indexHtml.source),
        fileNames: outputs.map((file) => file.fileName),
        sources: new Map(
            outputs.map((file) => [
                file.fileName,
                file.type === 'asset' ? String(file.source) : file.code,
            ]),
        ),
    }
}

function parseHtml(html: string): Document {
    const window = new Window()
    return new window.DOMParser().parseFromString(html, 'text/html') as unknown as Document
}

function inlineStylesheet(document: Document): string {
    return [...document.querySelectorAll('head style')].map((style) => style.textContent).join('')
}

describe('production build', () => {
    let output: BuildOutput
    let document: Document

    beforeAll(async () => {
        output = await buildSite()
        document = parseHtml(output.html)
    })

    it('prerenders the page into index.html', () => {
        expect(output.html).not.toContain('<!--page-->')
        expect(document.querySelector('body > main#top h1 .accent')?.textContent).toBe('macOS')
    })

    it('inlines the stylesheet with every section bundled in', () => {
        const css = inlineStylesheet(document)

        expect(document.querySelector('link[rel="stylesheet"]')).toBeNull()
        expect(output.fileNames.filter((fileName) => fileName.endsWith('.css'))).toEqual([])
        expect(css).not.toContain('@import')
        for (const selector of [
            '.topbar',
            '.screen',
            '.camera',
            '.menu-mock',
            '.steps',
            '.footer',
        ]) {
            expect(css).toContain(selector)
        }
    })

    it('loads the hashed script as a module', () => {
        const script = document.querySelector('script[type="module"]')?.getAttribute('src')

        expect(script).toMatch(/^\/assets\/index-[\w-]+\.js$/)
        expect(output.fileNames).toContain(script?.slice(1))
    })

    it('preloads the Latin font files the stylesheet uses', () => {
        const preloads = [...document.querySelectorAll('link[rel="preload"][as="font"]')]
        const css = inlineStylesheet(document)

        expect(preloads).toHaveLength(3)
        for (const preload of preloads) {
            const href = preload.getAttribute('href') ?? ''
            expect(href).toMatch(/^\/assets\/[\w-]+-latin-wght-normal-[\w-]+\.woff2$/)
            expect(preload.hasAttribute('crossorigin')).toBe(true)
            expect(css).toContain(`url(${href})`)
        }
    })

    it('never hides text while a font loads, and never swaps fonts after the first paint', () => {
        const css = inlineStylesheet(document)
        const fontDisplays = css.match(/(?<![\w-])font-display:\s*\w+/g) ?? []

        expect(fontDisplays.length).toBeGreaterThan(0)
        for (const fontDisplay of fontDisplays) {
            expect(fontDisplay).toMatch(/optional$/)
        }
    })

    it('ships install.sh next to the page', () => {
        expect(output.fileNames).toContain('install.sh')
    })
})
