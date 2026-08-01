$libPath = "c:\Users\hafid\Desktop\myAPPS\projet freelance\psy\leffet_psy\lib"
$dartFiles = Get-ChildItem -Path $libPath -Recurse -Filter "*.dart"

foreach ($file in $dartFiles) {
    $content = Get-Content -Raw -Path $file.FullName
    $modified = $false

    # Fix RxStatus.value = RxStatus.loading() -> just loading patterns
    if ($content -match "status\.value = RxStatus\.") {
        $content = $content -replace "status\.value = RxStatus\.loading\(\)", "status.value = 'loading'"
        $content = $content -replace "status\.value = RxStatus\.success\(\)", "status.value = 'success'"
        $content = $content -replace "status\.value = RxStatus\.empty\(\)", "status.value = 'empty'"
        $content = $content -replace "status\.value = RxStatus\.error\([^)]*\)", "status.value = 'error'"
        $modified = $true
    }

    # Fix RxStatus declarations
    if ($content -match "RxStatus status = RxStatus\.") {
        $content = $content -replace "RxStatus status = RxStatus\.loading\(\)", "RxString status = 'loading'.obs"
        $content = $content -replace "RxStatus status = RxStatus\.success\(\)", "RxString status = 'success'.obs"
        $content = $true
    }

    # Fix controller.status.isLoading -> controller.status.value == 'loading'
    if ($content -match "controller\.status\.isLoading") {
        $content = $content -replace "controller\.status\.isLoading", "controller.status.value == 'loading'"
        $modified = $true
    }
    if ($content -match "controller\.status\.isError") {
        $content = $content -replace "controller\.status\.isError", "controller.status.value == 'error'"
        $modified = $true
    }
    if ($content -match "controller\.status\.isEmpty") {
        $content = $content -replace "controller\.status\.isEmpty", "controller.status.value == 'empty'"
        $modified = $true
    }
    if ($content -match "controller\.status\.isSuccess") {
        $content = $content -replace "controller\.status\.isSuccess", "controller.status.value == 'success'"
        $modified = $true
    }
    # errorMessage getter
    if ($content -match "controller\.status\.errorMessage") {
        $content = $content -replace "controller\.status\.errorMessage", "controller.errorMessage.value"
        $modified = $true
    }

    if ($modified) {
        Set-Content -Path $file.FullName -Value $content -NoNewline
        Write-Host "Fixed status: $($file.Name)"
    }
}

Write-Host "Done fixing RxStatus."
