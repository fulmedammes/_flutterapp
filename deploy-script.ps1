# Simple Deployment Script for Flutter Web App to GitHub Pages

Write-Host "Starting deployment process..." -ForegroundColor Cyan

# Step 1: Build the Flutter web app
Write-Host "Building Flutter web app..." -ForegroundColor Cyan
flutter build web --base-href "/\_flutterapp/"

# Step 2: Create .nojekyll file
Write-Host "Creating .nojekyll file..." -ForegroundColor Cyan
New-Item -Path "build\web\.nojekyll" -ItemType File -Force | Out-Null

# Step 3: Save current branch name
$currentBranch = git rev-parse --abbrev-ref HEAD
Write-Host "Current branch: $currentBranch" -ForegroundColor Cyan

# Step 4: Checkout gh-pages branch (create if doesn't exist)
Write-Host "Checking out gh-pages branch..." -ForegroundColor Cyan
$ghPagesBranchExists = git show-ref --verify --quiet refs/heads/gh-pages
if (-not $?) {
    Write-Host "Creating gh-pages branch..." -ForegroundColor Yellow
    git checkout --orphan gh-pages
    git rm -rf . | Out-Null
} else {
    git checkout gh-pages
    # Clean the branch
    Get-ChildItem -Path . -Exclude .git | Remove-Item -Recurse -Force
}

# Step 5: Get the build files path and copy them
$buildPath = Join-Path -Path (Get-Location).Path -ChildPath "..\build\web\*"
Write-Host "Copying build files from: $buildPath" -ForegroundColor Cyan

# Use robocopy for more reliable file copying
$destinationPath = (Get-Location).Path
robocopy "..\build\web" $destinationPath /E

# Step 6: Commit and push changes
Write-Host "Committing changes to gh-pages branch..." -ForegroundColor Cyan
git add --all
git commit -m "Deploy to GitHub Pages"
git push origin gh-pages -f

# Step 7: Return to original branch
Write-Host "Returning to $currentBranch branch..." -ForegroundColor Cyan
git checkout $currentBranch

Write-Host "Deployment complete!" -ForegroundColor Green
Write-Host "Your app should be available at: https://fulmedammes.github.io/_flutterapp/" -ForegroundColor Green
Write-Host "Note: It may take a few minutes for changes to propagate." -ForegroundColor Yellow
Write-Host "If you don't see updates, try a hard refresh (Ctrl+F5) in your browser." -ForegroundColor Yellow 