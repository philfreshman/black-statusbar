const repositoryPath = 'philfreshman/nightbar'
const repository = `https://github.com/${repositoryPath}`

export const links = {
    repository,
    releases: `${repository}/releases`,
    installScriptSource: `${repository}/blob/main/install.sh`,
} as const

export const installCommand = 'curl -fsSL https://nightbar.app/install.sh | bash'

/**
 * The class on <html> that keeps the page hidden while its fonts load.
 * The inline script in index.html adds it; fonts.ts removes it.
 */
export const loadingClass = 'is-loading'

/** Ids the page renders and the scripts in main.ts look up. */
export const ids = {
    desktop: 'desktop',
    cursor: 'cursor',
    statusItem: 'status-item',
    statusMenu: 'status-menu',
    nightbarMenuItem: 'menu-nightbar',
    clock: 'clock',
    installCommand: 'install-command',
    installCommandClosing: 'install-command-closing',
} as const
