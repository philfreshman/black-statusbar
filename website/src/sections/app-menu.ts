/** One row of Nightbar's status menu, or a separator line. */
type MenuEntry =
    | 'separator'
    | {
          label: string
          /** Rows with a value here get a check mark slot; true shows the mark. */
          checked?: boolean
          shortcut?: string
          /** Rows with a submenu end in a chevron and carry the submenu, hidden until opened. */
          submenu?: MenuEntry[]
          id?: string
          /** Names the row for the demo script, as data-item. */
          item?: string
      }

/** The radii of the Rounded Corners submenu, as in the app. */
const cornerRadii = ['Off', 'Low', 'Mid', 'High']

function renderEntries(entries: MenuEntry[]): string {
    return entries.map(renderEntry).join('')
}

function renderEntry(entry: MenuEntry): string {
    if (entry === 'separator') {
        return '<li class="sep"></li>'
    }

    const { label, checked, shortcut, submenu, id, item } = entry
    const attributes = [
        id && ` id="${id}"`,
        item && ` data-item="${item}"`,
        checked && ' class="checked"',
    ]
        .filter(Boolean)
        .join('')
    const check = checked === undefined ? '' : '<span class="check">✓</span>'
    const keys = shortcut ? `<kbd>${shortcut}</kbd>` : ''
    const chevron = submenu
        ? `<span class="chevron">›</span><ul class="submenu">${renderEntries(submenu)}</ul>`
        : ''

    return `<li${attributes}>${check}${label}${keys}${chevron}</li>`
}

/** The rows of Nightbar's status menu as in the real app, with Nightbar switched on or off. */
export function renderStatusMenuEntries(isOn: boolean, nightbarItemId?: string): string {
    const cornerEntries: MenuEntry[] = cornerRadii.map((radius) => ({
        label: radius,
        checked: radius === 'Off',
        item: `corners-${radius.toLowerCase()}`,
    }))

    return renderEntries([
        { label: 'Nightbar', checked: isOn, id: nightbarItemId },
        'separator',
        { label: 'Rounded Corners', submenu: cornerEntries, item: 'rounded-corners' },
        'separator',
        { label: 'Launch at Login', checked: true },
        { label: 'Hide Icon' },
        'separator',
        { label: 'Quit', shortcut: '⌘Q' },
    ])
}
