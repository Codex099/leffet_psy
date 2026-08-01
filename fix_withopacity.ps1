$libPath = "c:\Users\hafid\Desktop\myAPPS\projet freelance\psy\leffet_psy\lib"
$dartFiles = Get-ChildItem -Path $libPath -Recurse -Filter "*.dart"

foreach ($file in $dartFiles) {
    $content = Get-Content -Raw -Path $file.FullName
    $modified = $false

    # Replace .withOpacity(x) with .withValues(alpha: x)
    if ($content -match "\.withOpacity\(") {
        $content = $content -replace "\.withOpacity\(([^)]+)\)", ".withValues(alpha: `$1)"
        $modified = $true
    }

    if ($modified) {
        Set-Content -Path $file.FullName -Value $content -NoNewline
        Write-Host "Fixed withOpacity: $($file.Name)"
    }
}

Write-Host "Done."
