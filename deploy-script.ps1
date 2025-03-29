# Build Flutter web app with correct base-href
Write-Host "Building Flutter web app..." -ForegroundColor Cyan
flutter build web --base-href "/_flutterapp/"

# Create .nojekyll file
Write-Host "Creating .nojekyll file..." -ForegroundColor Cyan
New-Item -Path build\web\.nojekyll -ItemType File -Force

# Create a temporary directory to store the build
Write-Host "Creating temporary directory..." -ForegroundColor Cyan
$tempDir = Join-Path -Path $env:TEMP -ChildPath ("flutter_deploy_{0}" -f (Get-Random))
New-Item -Path $tempDir -ItemType Directory -Force | Out-Null

# Copy build files to temp directory
Write-Host "Copying build files to temporary directory..." -ForegroundColor Cyan
Copy-Item -Path "build\web\*" -Destination $tempDir -Recurse -Force

# Switch to gh-pages branch
Write-Host "Checking out gh-pages branch..." -ForegroundColor Cyan
git checkout gh-pages 2>$null
if ($LASTEXITCODE -ne 0) {
    Write-Host "Creating gh-pages branch..." -ForegroundColor Yellow
    git checkout --orphan gh-pages
}

# Remove all files (but keep the .git directory)
Write-Host "Cleaning gh-pages branch..." -ForegroundColor Cyan
Get-ChildItem -Exclude .git | Remove-Item -Recurse -Force

# Copy the built files from temp directory
Write-Host "Copying built files to root directory..." -ForegroundColor Cyan
Copy-Item -Path "$tempDir\*" -Destination . -Recurse -Force

# Add, commit, and push changes
Write-Host "Committing and pushing changes..." -ForegroundColor Cyan
git add .
git commit -m "Deploy to GitHub Pages"
git push origin gh-pages -f

# Return to main branch
Write-Host "Returning to main branch..." -ForegroundColor Cyan
git checkout main

# Clean up
Write-Host "Cleaning up..." -ForegroundColor Cyan
Remove-Item -Path $tempDir -Recurse -Force

Write-Host "Deployment complete!" -ForegroundColor Green
Write-Host "Your app should be available at: https://fulmedammes.github.io/_flutterapp/" -ForegroundColor Green 