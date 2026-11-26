const repository = 'https://github.com/philfreshman/nightbar'

export const links = {
    repository,
    releases: `${repository}/releases`,
    download: `${repository}/releases/latest/download/Nightbar.zip`,
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
} as const
