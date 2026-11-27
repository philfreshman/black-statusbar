const repositoryPath = 'philfreshman/nightbar'
const repository = `https://github.com/${repositoryPath}`

export const links = {
    repository,
    releases: `${repository}/releases`,
    installScriptSource: `${repository}/blob/main/install.sh`,
} as const

export const installCommand = 'curl -fsSL https://nightbar.app/install.sh | bash'

/**
 * The custom Invoker Command a copy button sends: `command="--copy"` together with
 * `commandfor`, the id of the element whose text it copies. copy-button.ts handles it.
 */
export const copyCommand = '--copy'

/** Ids the page renders and the scripts in main.ts look up. */
export const ids = {
    desktop: 'desktop',
    cursor: 'cursor',
    statusItem: 'status-item',
    statusMenu: 'status-menu',
    nightbarMenuItem: 'menu-nightbar',
    demoToggle: 'demo-toggle',
    clock: 'clock',
    installCommand: 'install-command',
    installCommandClosing: 'install-command-closing',
} as const
