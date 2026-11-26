/** One row of Nightbar's status menu, or a separator line. */
export type MenuEntry =
    | 'separator'
    | {
          label: string
          /** Rows with a value here get a check mark slot; true shows the mark. */
          checked?: boolean
          shortcut?: string
          id?: string
      }

function renderEntry(entry: MenuEntry): string {
    if (entry === 'separator') {
        return '<li class="sep"></li>'
    }

    const { label, checked, shortcut, id } = entry
    const attributes = [id && ` id="${id}"`, checked && ' class="checked"'].filter(Boolean).join('')
    const check = checked === undefined ? '' : '<span class="check">✓</span>'
    const keys = shortcut ? `<kbd>${shortcut}</kbd>` : ''

    return `<li${attributes}>${check}${label}${keys}</li>`
}

/** The rows of Nightbar's status menu, as in the real app. */
export function renderMenuEntries(entries: MenuEntry[]): string {
    return entries.map(renderEntry).join('')
}
