/** Looks up an element the page always renders, and fails loudly if it is missing. */
export function requireElement<T extends Element = HTMLElement>(id: string): T {
    const element = document.getElementById(id)
    if (!element) {
        throw new Error(`The page has no element with id "${id}"`)
    }
    return element as unknown as T
}

export function wait(ms: number): Promise<void> {
    return new Promise((resolve) => setTimeout(resolve, ms))
}
