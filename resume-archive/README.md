# Resume Archive

This directory stores archived versions of your RESUME.md files and .context/ directories, created automatically when you run `/reheat:save` or `/reheat:save-quick`.

## How It Works

Every time you create a new handoff, the plugin automatically:

1. **Checks** if `RESUME.md` or `.context/` already exist in the project root
2. **Creates** this `resume-archive/` directory if needed
3. **Moves** the existing `RESUME.md` to `resume-archive/RESUME-YYYYMMDD-HHMM.md`
4. **Moves** the existing `.context/` to `resume-archive/.context-YYYYMMDD-HHMM/`
5. **Creates** the new `RESUME.md` and `.context/` in the project root

This ensures you never lose previous handoff context while keeping your workspace clean.

## Archive Policy

### What Gets Archived
- Previous `RESUME.md` files are automatically archived with timestamps
- Previous `.context/` directories are archived with matching timestamps
- Format: `RESUME-20260101-1730.md` and `.context-20260101-1730/` (YYYYMMDD-HHMM)
- Each archive is a complete snapshot of your work context at that moment

### What's NOT Committed to Git
This directory is listed in `.gitignore` because:
- Handoffs contain personal work context and mental models
- Archives are user-specific and change frequently
- They're meant for local reference, not shared repository state
- Multiple developers would create conflicting handoffs

### When to Review Archives
- **Compare progress**: See how your understanding evolved
- **Recover lost context**: Review what you knew days/weeks ago
- **Track decisions**: See when and why architectural choices were made
- **Debug regressions**: Check what worked before vs. now

## Manual Management

### Keep an Archive Permanently
If an archive is particularly valuable, you can commit it to git by moving it out of this directory:

```bash
# Move to examples or docs
mv resume-archive/RESUME-20260101-1730.md docs/handoffs/milestone-v1-launch.md
git add docs/handoffs/milestone-v1-launch.md
git commit -m "docs: Archive handoff from v1 launch"
```

### Clean Up Old Archives
Archives accumulate over time. Clean them periodically:

```bash
# Keep only the last 10 archives
ls -t resume-archive/RESUME-*.md | tail -n +11 | xargs rm

# Delete archives older than 30 days
find resume-archive -name "RESUME-*.md" -mtime +30 -delete
```

### Manual Archive
To manually archive before a major change:

```bash
timestamp=$(date +%Y%m%d-%H%M)
cp RESUME.md "resume-archive/RESUME-${timestamp}-before-refactor.md"
```

## Example Timeline

```
resume-archive/
├── RESUME-20260101-0900.md  # Morning: Started feature work
├── RESUME-20260101-1500.md  # Afternoon: Hit blocker, documented approach
├── RESUME-20260102-1000.md  # Next day: Blocker resolved, new approach
└── RESUME-20260102-1700.md  # End of day: Feature complete
```

## Tips

- **Review before big changes**: Check the latest archive to remember your reasoning
- **Search across archives**: `grep -r "authentication" resume-archive/` finds all mentions
- **Compare versions**: `diff resume-archive/RESUME-20260101-0900.md resume-archive/RESUME-20260102-1700.md`
- **Export insights**: Pull valuable learnings from archives into permanent docs

---

*This directory is managed automatically by the Reheat plugin.*
