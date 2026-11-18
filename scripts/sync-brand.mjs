import fs from 'node:fs'
import path from 'node:path'
import { fileURLToPath } from 'node:url'

const rootDir = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..')
const brandDir = path.join(rootDir, 'brand')
const publicDir = path.join(rootDir, 'src', 'public')
const publicBrandDir = path.join(publicDir, 'brand')

if (!fs.existsSync(path.join(brandDir, 'svg', 'favicon.svg'))) {
  throw new Error(
    `Nikrun brand submodule not initialized at '${brandDir}'. Run: git submodule update --init --depth 1`
  )
}

fs.mkdirSync(publicBrandDir, { recursive: true })

const rootMappings = [
  ['svg/favicon.svg', 'favicon.svg'],
  ['ico/nikrun.ico', 'favicon.ico'],
  ['png/apple-touch-icon-180.png', 'apple-touch-icon.png'],
  ['png/og-image-1200x630.png', 'og-image.png']
]

for (const [srcRel, dstRel] of rootMappings) {
  fs.copyFileSync(path.join(brandDir, srcRel), path.join(publicDir, dstRel))
}

const brandSvgs = [
  'nikrun-favicon.svg',
  'nikrun-icon-light.svg',
  'nikrun-icon-dark-mono.svg',
  'nikrun-lockup-light.svg',
  'nikrun-lockup-dark-mono.svg'
]

for (const svgName of brandSvgs) {
  fs.copyFileSync(path.join(brandDir, 'svg', svgName), path.join(publicBrandDir, svgName))
}

for (const pngName of ['nikrun-lockup-light.png', 'nikrun-lockup-dark-mono.png']) {
  fs.copyFileSync(path.join(brandDir, 'png', pngName), path.join(publicBrandDir, pngName))
}
