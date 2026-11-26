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

describe('production build', () => {
    let output: BuildOutput
    let document: Document

    beforeAll(async () => {
        output = await buildSite()
        document = parseHtml(output.html)
    })

    it('prerenders the page into index.html', () => {
        expect(output.html).not.toContain('<!--page-->')
        expect(document.querySelector('body > main#top h1 .volt')?.textContent).toBe('macOS')
    })

    it('links the hashed stylesheet with every section bundled in', () => {
        const stylesheet = document.querySelector('link[rel="stylesheet"]')?.getAttribute('href')

        expect(stylesheet).toMatch(/^\/assets\/index-[\w-]+\.css$/)
        const css = output.sources.get(stylesheet?.slice(1) ?? '')
        expect(css).toBeDefined()
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

    it('ships install.sh next to the page', () => {
        expect(output.fileNames).toContain('install.sh')
    })
})
