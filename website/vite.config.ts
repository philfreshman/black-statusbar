import { createHash } from 'node:crypto'
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

/**
 * Puts the page script straight into index.html and allows it, and only it, by its hash in a
 * Content Security Policy. A static page has no server to stamp a fresh nonce on each response,
 * so a hash is what lets the policy block any injected script. The policy sits in a <meta> tag
 * because the hash changes with every build; vercel.json sends the directives that do not.
 *
 * 'strict-dynamic' trusts only the hashed script. Browsers that know it ignore 'unsafe-inline'
 * and https:, which are there only so browsers too old for hashes still run the page.
 */
function inlineScriptWithContentSecurityPolicy(): Plugin {
    return {
        name: 'nightbar-inline-script-csp',
        apply: 'build',
        transformIndexHtml: {
            order: 'post',
            handler: (html, { bundle }) => {
                const scriptHashes: string[] = []

                for (const [fileName, output] of Object.entries(bundle ?? {})) {
                    if (output.type !== 'chunk' || !output.isEntry) continue
                    if (output.code.includes('</script')) {
                        throw new Error(`${fileName} contains </script, so it cannot be inlined`)
                    }

                    const src = `/${fileName}`.replaceAll('.', '\\.')
                    const tag = new RegExp(`<script type="module"[^>]*src="${src}"[^>]*></script>`)
                    html = html.replace(tag, () => `<script type="module">${output.code}</script>`)
                    scriptHashes.push(createHash('sha256').update(output.code).digest('base64'))
                    delete bundle?.[fileName]
                }

                const policy = [
                    `script-src ${scriptHashes.map((hash) => `'sha256-${hash}'`).join(' ')} 'strict-dynamic' https: 'unsafe-inline'`,
                    "object-src 'none'",
                    "base-uri 'none'",
                    "require-trusted-types-for 'script'",
                ].join('; ')
                const meta = `<meta http-equiv="Content-Security-Policy" content="${policy}" />`
                return html.replace(
                    /<meta charset="utf-8" \/>/,
                    (charset) => `${charset}\n        ${meta}`,
                )
            },
        },
    }
}

/**
 * Gives every font face `font-display: optional` in place of Fontsource's `swap`. The fonts are
 * preloaded, so they are almost always ready for the first paint; if one is not, the page keeps
 * the fallback font instead of swapping fonts under the reader. The text never waits hidden.
 */
const fontDisplayOptional = {
    postcssPlugin: 'nightbar-font-display-optional',
    Declaration: {
        'font-display': (declaration: { value: string }) => {
            declaration.value = 'optional'
        },
    },
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
    plugins: lazyPlugins(() => [
        prerenderPage(),
        inlineStylesheet(),
        inlineScriptWithContentSecurityPolicy(),
        serveInstallScript(),
    ]),
    css: { postcss: { plugins: [fontDisplayOptional] } },
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
