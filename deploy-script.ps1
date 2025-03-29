# Flutter Web Deployment Script using git worktree

# Step 1: Build the Flutter web app
Write-Host "Building Flutter web app..." -ForegroundColor Cyan
flutter build web --base-href "/_flutterapp/"

# Step 2: Create .nojekyll file to disable Jekyll processing
Write-Host "Creating .nojekyll file..." -ForegroundColor Cyan
New-Item -Path "build\web\.nojekyll" -ItemType File -Force | Out-Null

# Step 3: Setup Git worktree for gh-pages (much more reliable)
Write-Host "Setting up Git worktree for gh-pages branch..." -ForegroundColor Cyan

# Check if gh-pages branch exists, create if not
git show-ref --verify --quiet refs/heads/gh-pages
if (-not $?) {
    Write-Host "Creating gh-pages branch..." -ForegroundColor Yellow
    git checkout --orphan gh-pages
    git reset --hard
    git commit --allow-empty -m "Initial gh-pages commit"
    git push origin gh-pages
    git checkout main
}

# Remove existing gh-pages worktree if it exists
if (Test-Path -Path "gh-pages") {
    Write-Host "Removing existing gh-pages worktree..." -ForegroundColor Yellow
    git worktree remove -f gh-pages
}

# Create fresh worktree for gh-pages branch
Write-Host "Creating fresh worktree for gh-pages branch..." -ForegroundColor Cyan
git worktree add -f gh-pages gh-pages

# Step 4: Copy build files to gh-pages directory
Write-Host "Copying build files to gh-pages directory..." -ForegroundColor Cyan
Push-Location gh-pages
# Remove all files except .git
Get-ChildItem -Force | Where-Object { $_.Name -ne ".git" } | Remove-Item -Recurse -Force
# Copy build files
Copy-Item -Path "..\build\web\*" -Destination . -Recurse

# Step 5: Commit and push changes
Write-Host "Committing and pushing changes..." -ForegroundColor Cyan
git add -A
git commit -m "Deploy to GitHub Pages"
git push origin gh-pages

# Return to main directory
Pop-Location

# Step 6: Clean up
Write-Host "Cleaning up..." -ForegroundColor Cyan
git worktree remove -f gh-pages

Write-Host "Deployment complete!" -ForegroundColor Green
Write-Host "Your app should be available at: https://fulmedammes.github.io/_flutterapp/" -ForegroundColor Green
Write-Host "Note: It may take a few minutes for changes to propagate." -ForegroundColor Yellow
Write-Host "If you don't see updates, try a hard refresh (Ctrl+F5) in your browser." -ForegroundColor Yellow 