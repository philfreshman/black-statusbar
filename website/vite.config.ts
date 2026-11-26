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
    plugins: lazyPlugins(() => [prerenderPage(), serveInstallScript()]),
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
