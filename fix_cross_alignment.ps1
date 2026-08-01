$libPath = "c:\Users\hafid\Desktop\myAPPS\projet freelance\psy\leffet_psy\lib"
$dartFiles = Get-ChildItem -Path $libPath -Recurse -Filter "*.dart"

foreach ($file in $dartFiles) {
    $content = Get-Content -Raw -Path $file.FullName
    if ($content -match "CrossAlignment\.start") {
        $newContent = $content -replace "CrossAlignment\.start", "CrossAxisAlignment.start"
        Set-Content -Path $file.FullName -Value $newContent -NoNewline
        Write-Host "Fixed: $($file.Name)"
    }
}

Write-Host "Done fixing CrossAlignment."
