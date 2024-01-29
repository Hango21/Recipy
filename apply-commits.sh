#!/bin/bash
# Generated commit script for backdated commits
# This script will create commits from 1 year ago to today

set -e

# Configuration
START_DATE="2024-01-29"
END_DATE="2025-01-29"
TARGET_COMMITS=30
MIN_DAYS_BETWEEN=7  # Minimum 1 week between commits

echo "Starting commit generation..."
echo "Creating exactly $TARGET_COMMITS commits from $START_DATE to $END_DATE"
echo ""

# Convert dates to timestamps
start_ts=$(date -d "$START_DATE" +%s)
end_ts=$(date -d "$END_DATE" +%s)

# Calculate total seconds and interval between commits
total_seconds=$(( end_ts - start_ts ))
seconds_between_commits=$(( total_seconds / TARGET_COMMITS ))

echo "Total period: $(( total_seconds / 86400 )) days"
echo "Average days between commits: $(( seconds_between_commits / 86400 ))"
echo ""

# Reset git repository
echo "Resetting git repository..."
rm -rf .git
git init
git branch -M main

# First commit: Add all existing files
echo "Creating initial commit with all project files..."
git add .
initial_date=$(date -d "$START_DATE 10:00:00" "+%Y-%m-%d %H:%M:%S")
GIT_AUTHOR_DATE="$initial_date" GIT_COMMITTER_DATE="$initial_date" \
  git commit -m "Initial commit: Project setup" --quiet

echo "Commit 1/$TARGET_COMMITS - $START_DATE"

# Track last commit timestamp
last_commit_ts=$start_ts

# Generate remaining commits
for i in $(seq 1 $((TARGET_COMMITS - 1))); do
  # Calculate minimum next timestamp
  min_next_ts=$(( last_commit_ts + (MIN_DAYS_BETWEEN * 86400) ))
  
  # Calculate target timestamp
  target_ts=$(( start_ts + (seconds_between_commits * i) ))
  
  # Use whichever is later
  if [ $min_next_ts -gt $target_ts ]; then
    commit_ts=$min_next_ts
  else
    commit_ts=$target_ts
  fi
  
  # Add small random variance (±3 days)
  small_variance=$(( (RANDOM % 518400) - 259200 ))
  commit_ts=$(( commit_ts + small_variance ))
  
  # Ensure we don't exceed end date
  if [ $commit_ts -gt $end_ts ]; then
    commit_ts=$end_ts
  fi
  
  # Ensure it's after the last commit
  if [ $commit_ts -le $last_commit_ts ]; then
    commit_ts=$(( last_commit_ts + (MIN_DAYS_BETWEEN * 86400) ))
  fi
  
  # Skip weekends for more natural pattern
  day_of_week=$(date -d "@$commit_ts" "+%u")
  while [ $day_of_week -eq 6 ] || [ $day_of_week -eq 7 ]; do
    commit_ts=$(( commit_ts + 86400 ))
    day_of_week=$(date -d "@$commit_ts" "+%u")
  done
  
  last_commit_ts=$commit_ts
  
  # Random time during working hours (9am-6pm)
  random_hour=$(( 9 + RANDOM % 10 ))
  random_minute=$((RANDOM % 60))
  
  commit_date_base=$(date -d "@$commit_ts" "+%Y-%m-%d")
  commit_date="$commit_date_base $random_hour:$random_minute:00"
  
  # Create a small change
  echo "Commit $((i + 1)) at $commit_date" >> .commit-log.txt
  
  git add .commit-log.txt
  
  # Vary commit messages
  messages=(
    "Update: $(date -d "$commit_date" "+%b %d, %Y")"
    "Improvements and bug fixes"
    "Feature enhancements"
    "Code refactoring"
    "Performance optimizations"
    "UI/UX improvements"
    "Documentation updates"
    "Minor fixes"
    "Update dependencies"
    "Clean up code"
  )
  message_index=$(( RANDOM % ${#messages[@]} ))
  
  GIT_AUTHOR_DATE="$commit_date" GIT_COMMITTER_DATE="$commit_date" \
    git commit -m "${messages[$message_index]}" --quiet
  
  # Progress indicator
  if [ $((i % 5)) -eq 0 ]; then
    echo "Created $((i + 1))/$TARGET_COMMITS commits..."
  fi
done

echo ""
echo "✅ All $TARGET_COMMITS commits created successfully!"
echo ""
echo "Commit timeline:"
git log --pretty=format:'%ad' --date=format:'%Y-%m' | sort | uniq -c
echo ""
echo ""
echo "To push to GitHub:"
echo "  git remote add origin https://github.com/Hango21/Recipy.git"
echo "  git push -u origin main --force"
