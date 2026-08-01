$libPath = "c:\Users\hafid\Desktop\myAPPS\projet freelance\psy\leffet_psy\lib"
$dartFiles = Get-ChildItem -Path $libPath -Recurse -Filter "*.dart"

foreach ($file in $dartFiles) {
    $content = Get-Content -Raw -Path $file.FullName
    $modified = $false

    # Fix RxStatus type declarations  
    if ($content -match "RxStatus") {
        # Replace declaration types
        $content = $content -replace "final RxStatus status = RxStatus\.(loading|success|error|empty)\(\)\.obs;", "final RxString status = 'loading'.obs;`r`n  final RxString errorMessage = ''.obs;"
        $content = $content -replace "final RxStatus status = RxStatus\.(loading|success|error|empty)\(\);", "final RxString status = 'loading'.obs;`r`n  final RxString errorMessage = ''.obs;"
        # Remove remaining RxStatus.xxx() calls that didn't get fixed
        $content = $content -replace "RxStatus\.loading\(\)", "'loading'"
        $content = $content -replace "RxStatus\.success\(\)", "'success'"
        $content = $content -replace "RxStatus\.empty\(\)", "'empty'"
        $content = $content -replace "RxStatus\.error\(([^)]*)\)", "'error'"
        # Remove any remaining RxStatus import references or declarations
        $content = $content -replace "RxStatus status", "RxString status"
        $modified = $true
    }

    if ($modified) {
        Set-Content -Path $file.FullName -Value $content -NoNewline
        Write-Host "Fixed RxStatus decl: $($file.Name)"
    }
}

Write-Host "Done."
