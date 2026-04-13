param(
    [Parameter(Mandatory=$true)]
    [string]$Version,
    [string]$Message = ""
)

if ($Message -eq "") {
    $Message = "release"
}

$pubspec = Get-Content "pubspec.yaml" -Raw
$pubspec = $pubspec -replace "version: .*", "version: $Version+1"
Set-Content "pubspec.yaml" $pubspec -NoNewline

Write-Host "Version updated to $Version"

git add .
git commit -m "v$Version $Message"
git push
git tag "v$Version"
git push --tags

Write-Host "Done! Check https://github.com/ShadowOfTime1/tortio/actions"