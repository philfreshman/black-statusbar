import { requireElement } from './dom.ts'
import { ids, links } from './site.ts'

interface Repository {
    stargazers_count: number
}

/** Formats a star count the way GitHub shows it, for example 1234 as "1.2k". */
export function formatStarCount(count: number, locale = 'en'): string {
    return new Intl.NumberFormat(locale, { notation: 'compact', maximumFractionDigits: 1 })
        .format(count)
        .toLowerCase()
}

async function fetchStars(): Promise<number | undefined> {
    const response = await fetch(links.repositoryApi, {
        headers: { Accept: 'application/vnd.github+json' },
    })
    if (!response.ok) {
        return undefined
    }
    const { stargazers_count: stars } = (await response.json()) as Repository
    return stars
}

/**
 * Reads the star count live from GitHub and shows the Stars link. If GitHub can't be reached
 * (offline, or past its 60 calls an hour without a login), the link stays hidden.
 */
export async function showStarCount(): Promise<void> {
    const starsLink = requireElement(ids.stars)
    const count = requireElement(ids.starCount)

    try {
        const stars = await fetchStars()
        if (stars === undefined) {
            return
        }
        count.textContent = formatStarCount(stars)
        starsLink.hidden = false
    } catch {
        // Network error: nothing to show.
    }
}
