const repositoryPath = 'philfreshman/nightbar'
const repository = `https://github.com/${repositoryPath}`

export const links = {
    repository,
    /** GitHub's public API for the repository, for the star count. */
    repositoryApi: `https://api.github.com/repos/${repositoryPath}`,
    releases: `${repository}/releases`,
    installScriptSource: `${repository}/blob/main/install.sh`,
} as const

export const installCommand = 'curl -fsSL https://nightbar.app/install.sh | bash'

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
    starCount: 'star-count',
} as const
