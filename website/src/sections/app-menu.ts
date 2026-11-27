/** One row of Nightbar's status menu, or a separator line. */
type MenuEntry =
    | 'separator'
    | {
          label: string
          /** Rows with a value here get a check mark slot; true shows the mark. */
          checked?: boolean
          shortcut?: string
          /** Rows that open a submenu end in a chevron. */
          hasSubmenu?: boolean
          id?: string
      }

function renderEntry(entry: MenuEntry): string {
    if (entry === 'separator') {
        return '<li class="sep"></li>'
    }

    const { label, checked, shortcut, hasSubmenu, id } = entry
    const attributes = [id && ` id="${id}"`, checked && ' class="checked"'].filter(Boolean).join('')
    const check = checked === undefined ? '' : '<span class="check">✓</span>'
    const keys = shortcut ? `<kbd>${shortcut}</kbd>` : ''
    const chevron = hasSubmenu ? '<span class="chevron">›</span>' : ''

    return `<li${attributes}>${check}${label}${keys}${chevron}</li>`
}

/** The rows of Nightbar's status menu as in the real app, with Nightbar switched on or off. */
export function renderStatusMenuEntries(isOn: boolean, nightbarItemId?: string): string {
    const entries: MenuEntry[] = [
        { label: 'Nightbar', checked: isOn, id: nightbarItemId },
        'separator',
        { label: 'Rounded Corners', hasSubmenu: true },
        'separator',
        { label: 'Launch at Login', checked: true },
        { label: 'Hide Icon' },
        'separator',
        { label: 'Quit', shortcut: '⌘Q' },
    ]

    return entries.map(renderEntry).join('')
}
