import { startClock } from './clock.ts'
import { setUpCopyButtons } from './copy-button.ts'
import { startDemo } from './demo.ts'
import { revealPageWhenFontsReady } from './fonts.ts'

startClock()
setUpCopyButtons()
// The demo measures where the menu items sit, so it starts once the fonts have set their size.
await revealPageWhenFontsReady()
startDemo()
