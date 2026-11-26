import { requireElement } from './dom.ts'
import { ids, links } from './site.ts'

interface Repository {
    stargazers_count: number
}

interface CachedCount {
    stars: number
    savedAt: number
}

/** GitHub allows 60 calls an hour without a login, so reloads reuse the last answer. */
const CACHE_KEY = 'nightbar-star-count'
const CACHE_FOR_MS = 60 * 60 * 1000

function readCachedStars(): number | undefined {
    try {
        const cached = JSON.parse(sessionStorage.getItem(CACHE_KEY) ?? 'null') as CachedCount | null
        return cached && Date.now() - cached.savedAt < CACHE_FOR_MS ? cached.stars : undefined
    } catch {
        return undefined
    }
}

function cacheStars(stars: number): void {
    try {
        sessionStorage.setItem(CACHE_KEY, JSON.stringify({ stars, savedAt: Date.now() }))
    } catch {
        // Storage can be blocked; the count still shows, it is just fetched again next time.
    }
}

async function fetchStars(): Promise<number | undefined> {
    const response = await fetch(links.repositoryApi, {
        headers: { Accept: 'application/vnd.github+json' },
    })
    if (!response.ok) {
        return undefined
    }
    const { stargazers_count: stars } = (await response.json()) as Repository
    cacheStars(stars)
    return stars
}

/** Formats a star count the way GitHub shows it, for example 1234 as "1.2k". */
export function formatStarCount(count: number, locale = 'en'): string {
    return new Intl.NumberFormat(locale, { notation: 'compact', maximumFractionDigits: 1 })
        .format(count)
        .toLowerCase()
}

/**
 * Fills in the repository's star count. With no stars yet, or if GitHub can't be reached, the
 * badge just says "Star".
 */
export async function showStarCount(): Promise<void> {
    const count = requireElement(ids.starCount)

    try {
        const stars = readCachedStars() ?? (await fetchStars())
        // A zero reads like a warning; without a number the badge still invites a star.
        if (!stars) {
            return
        }
        count.textContent = formatStarCount(stars)
        count.hidden = false
    } catch {
        // Offline or rate limited: the badge keeps working as a plain link.
    }
}
