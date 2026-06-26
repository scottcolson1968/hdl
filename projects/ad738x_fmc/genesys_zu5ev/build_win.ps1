# Builds the ad738x_fmc_genesys_zu5ev project with Windows Vivado.
# Replicates what the repo's make flow does on Linux: batch-build each
# required library IP, then run system_project.tcl.
#
# Usage (PowerShell):
#   cd D:\hdl\projects\ad738x_fmc\genesys_zu5ev
#   .\build_win.ps1                      # NUM_OF_SDI=4, ALERT_SPI_N=0 defaults
#   $env:NUM_OF_SDI = "2"; .\build_win.ps1
param(
  [string]$Vivado = "D:\Xilinx\Vivado\2025.1\bin\vivado.bat",
  [switch]$RebuildLibs
)

$ErrorActionPreference = "Stop"
$hdl = (Resolve-Path "$PSScriptRoot\..\..\..").Path

$libs = @(
  "axi_clkgen",
  "axi_dmac",
  "axi_pwm_gen",
  "axi_sysid",
  "sysid_rom",
  "spi_engine\axi_spi_engine",
  "spi_engine\spi_engine_execution",
  "spi_engine\spi_engine_interconnect",
  "spi_engine\spi_engine_offload"
)

foreach ($l in $libs) {
  $dir = Join-Path "$hdl\library" $l
  $name = Split-Path $l -Leaf
  if (-not $RebuildLibs -and (Test-Path "$dir\component.xml")) {
    Write-Host "[skip] $l (component.xml exists)"
    continue
  }
  Write-Host "[lib ] building $l ..."
  Push-Location $dir
  & $Vivado -mode batch -source "${name}_ip.tcl" -log "${name}_ip.log" -journal "${name}_ip.jou"
  $code = $LASTEXITCODE
  Pop-Location
  if ($code -ne 0) { throw "library build failed: $l (see $dir\${name}_ip.log)" }
}

Write-Host "[proj] building ad738x_fmc_genesys_zu5ev ..."
Push-Location $PSScriptRoot
& $Vivado -mode batch -source system_project.tcl -log ad738x_fmc_genesys_zu5ev_vivado.log -journal ad738x_fmc_genesys_zu5ev_vivado.jou
$code = $LASTEXITCODE
Pop-Location
if ($code -ne 0) { throw "project build failed (see ad738x_fmc_genesys_zu5ev_vivado.log)" }

Write-Host "Done. Open ad738x_fmc_genesys_zu5ev.xpr in Vivado to view the project."
