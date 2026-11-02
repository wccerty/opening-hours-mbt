$ErrorActionPreference = 'Stop'
$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
Push-Location $repoRoot
try {
  & moon build web/bridge --target wasm --release
  if ($LASTEXITCODE -ne 0) { throw 'MoonBit WebAssembly build failed.' }

  & moon build web/bridge --target js --release
  if ($LASTEXITCODE -ne 0) { throw 'MoonBit JavaScript build failed.' }

  $assetDirectory = Join-Path $repoRoot 'web/demo/assets'
  New-Item -ItemType Directory -Force -Path $assetDirectory | Out-Null
  Copy-Item -LiteralPath '_build/js/release/build/web/bridge/bridge.js' -Destination (Join-Path $assetDirectory 'bridge.js') -Force
  Copy-Item -LiteralPath 'data/china-2026-holidays.json' -Destination 'web/demo/china-2026-holidays.json' -Force
} finally {
  Pop-Location
}
