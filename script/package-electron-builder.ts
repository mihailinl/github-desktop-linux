/* eslint-disable no-sync */

import * as path from 'path'
import { promisify } from 'util'
import { build, CliOptions } from 'electron-builder'

import glob = require('glob')
const globPromise = promisify(glob)

import { getDistPath, getDistRoot } from './dist-info'

function getArchitecture(): CliOptions {
  const arch = process.env.npm_config_arch || process.arch
  switch (arch) {
    case 'arm64':
      return { arm64: true }
    case 'arm':
      return { armv7l: true }
    default:
      return { x64: true }
  }
}

export async function packageElectronBuilder(): Promise<Array<string>> {
  const distPath = getDistPath()
  const distRoot = getDistRoot()

  const configPath = path.resolve(__dirname, 'electron-builder-linux.yml')

  // The API rather than the electron-builder CLI: with yarn classic's install
  // layout, the CLI's yargs loads the ESM-only string-width 5 and crashes.
  await build({
    prepackaged: distPath,
    config: configPath,
    ...getArchitecture(),
  })

  const appImageInstaller = `${distRoot}/GitHubDesktop-linux-*.AppImage`

  const files = await globPromise(appImageInstaller)
  if (files.length !== 1) {
    return Promise.reject(
      `Expected one AppImage installer but instead found '${files.join(
        ', '
      )}' - exiting...`
    )
  }

  const appImageInstallerPath = files[0]

  return Promise.resolve([appImageInstallerPath])
}
