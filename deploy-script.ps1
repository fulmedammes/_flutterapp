# Get the current working directory
$workingDirectory = Get-Location

# Build Flutter web app with correct base-href
Write-Host "Building Flutter web app..." -ForegroundColor Cyan
flutter clean
flutter build web --base-href "/\_flutterapp/"

# Verify the build directory exists
if (-not (Test-Path -Path "build\web")) {
    Write-Host "Error: build\web directory not found!" -ForegroundColor Red
    Write-Host "Make sure Flutter build completed successfully." -ForegroundColor Red
    exit 1
}

# Store the full path to the build web directory
$webBuildPath = Join-Path -Path $workingDirectory -ChildPath "build\web"

# Save the current branch
$currentBranch = & git rev-parse --abbrev-ref HEAD

# Create .nojekyll file
Write-Host "Creating .nojekyll file..." -ForegroundColor Cyan
New-Item -Path build\web\.nojekyll -ItemType File -Force

# Switch to gh-pages branch
Write-Host "Checking out gh-pages branch..." -ForegroundColor Cyan
git checkout gh-pages 2>$null
if ($LASTEXITCODE -ne 0) {
    Write-Host "Creating gh-pages branch..." -ForegroundColor Yellow
    git checkout --orphan gh-pages
    git rm -rf .
    git clean -fdx
}

# Remove all files except .git
Write-Host "Cleaning gh-pages branch..." -ForegroundColor Cyan
Get-ChildItem -Path . -Exclude .git | Remove-Item -Recurse -Force

# Copy the built files directly from build/web to root
Write-Host "Copying built files to root directory..." -ForegroundColor Cyan
Write-Host "Source path: $webBuildPath"
Copy-Item -Path "$webBuildPath\*" -Destination . -Recurse -Force

# Add, commit, and push changes
Write-Host "Committing and pushing changes..." -ForegroundColor Cyan
git add --all
git commit -m "Deploy to GitHub Pages"
git push origin gh-pages -f

# Return to original branch
Write-Host "Returning to original branch..." -ForegroundColor Cyan
git checkout $currentBranch

Write-Host "Deployment complete!" -ForegroundColor Green
Write-Host "Your app should be available at: https://fulmedammes.github.io/_flutterapp/" -ForegroundColor Green
Write-Host "Note: It may take a few minutes for changes to propagate. Try a hard refresh (Ctrl+F5) if needed." -ForegroundColor Yellow 