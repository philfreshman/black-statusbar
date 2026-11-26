import { readFileSync } from 'node:fs'
import { defineConfig, lazyPlugins, type Plugin } from 'vite-plus'
import { renderPage } from './src/page.ts'

const PAGE_PLACEHOLDER = '<!--page-->'

// install.sh lives at the repo root so people find it on GitHub; serve it at /install.sh too.
const installScript = new URL('../install.sh', import.meta.url)

/**
 * Renders the page into index.html at build time, so the content is in the initial HTML
 * instead of being injected by JavaScript after load.
 * Runs before Vite's own HTML processing, so the asset paths in the markup still get hashed.
 */
function prerenderPage(): Plugin {
    return {
        name: 'nightbar-prerender-page',
        transformIndexHtml: {
            order: 'pre',
            handler: (html) => html.replace(PAGE_PLACEHOLDER, renderPage()),
        },
    }
}

/**
 * Puts the built stylesheet straight into index.html, so the first paint does not wait for a
 * second request. The page is a single page, so nothing else would reuse the file from cache.
 */
function inlineStylesheet(): Plugin {
    return {
        name: 'nightbar-inline-stylesheet',
        apply: 'build',
        transformIndexHtml: {
            order: 'post',
            handler: (html, { bundle }) => {
                for (const [fileName, output] of Object.entries(bundle ?? {})) {
                    if (output.type !== 'asset' || !fileName.endsWith('.css')) continue

                    // Hashed asset names hold only letters, digits, '-', '_', '/' and dots.
                    const href = `/${fileName}`.replaceAll('.', '\\.')
                    const link = new RegExp(`<link rel="stylesheet"[^>]*href="${href}"[^>]*>`)
                    const css = String(output.source)
                    html = html.replace(link, () => `<style>${css}</style>`)
                    delete bundle?.[fileName]
                }
                return html
            },
        },
    }
}

function serveInstallScript(): Plugin {
    return {
        name: 'nightbar-install-script',
        configureServer(server) {
            server.middlewares.use('/install.sh', (_request, response) => {
                response.setHeader('Content-Type', 'text/plain; charset=utf-8')
                response.end(readFileSync(installScript))
            })
        },
        generateBundle() {
            this.emitFile({
                type: 'asset',
                fileName: 'install.sh',
                source: readFileSync(installScript),
            })
        },
    }
}

export default defineConfig({
    plugins: lazyPlugins(() => [prerenderPage(), inlineStylesheet(), serveInstallScript()]),
    fmt: {
        singleQuote: true,
        semi: false,
        tabWidth: 4,
        ignorePatterns: ['dist/**'],
    },
    lint: {
        jsPlugins: [{ name: 'vite-plus', specifier: 'vite-plus/oxlint-plugin' }],
        rules: { 'vite-plus/prefer-vite-plus-imports': 'error' },
        options: { typeAware: true, typeCheck: true },
    },
    server: { port: 8040 },
    preview: { port: 8040 },
})
