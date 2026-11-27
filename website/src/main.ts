import { inject as injectAnalytics } from '@vercel/analytics'
import { startClock } from './clock.ts'
import { setUpCopyButtons } from './copy-button.ts'
import { startDemo } from './demo.ts'
import { waitForPageFonts } from './fonts.ts'

// Vercel Web Analytics: counts page views on the deployed site.
injectAnalytics()
startClock()
setUpCopyButtons()
// The demo measures where the menu items sit, so it starts once the fonts have set their size.
await waitForPageFonts()
startDemo()
