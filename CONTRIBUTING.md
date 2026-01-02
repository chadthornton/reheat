# Contributing to Reheating Instructions

Thanks for your interest in improving this plugin! Here's how you can help.

## How to Contribute

### Reporting Issues

If you find a bug or have a suggestion:

1. Check if the issue already exists in GitHub Issues
2. If not, create a new issue with:
   - Clear description of the problem or suggestion
   - Steps to reproduce (for bugs)
   - Example handoff documents (if relevant)
   - Your Claude Code version

### Improving Skills

The core functionality is in the skill prompts. To improve them:

1. Fork the repository
2. Edit the relevant skill file:
   - [skills/create.md](skills/create.md) - Comprehensive handoff creation
   - [skills/quick.md](skills/quick.md) - Quick handoff creation
   - [skills/resume.md](skills/resume.md) - Resuming from handoffs

3. Test your changes:
   - Install the plugin locally
   - Try creating and resuming from real handoffs
   - Verify the output quality

4. Submit a pull request with:
   - Description of what you changed
   - Why the change improves the skill
   - Example before/after handoff documents

### Testing Guidelines

When testing changes:

**For create/quick skills:**
- Does it capture all critical information?
- Are error messages specific enough?
- Are file paths and line numbers included?
- Would another agent understand the context?

**For resume skill:**
- Does Claude actually use the handoff content?
- Are failed approaches avoided?
- Is context properly understood?

### Skill Writing Best Practices

1. **Be Specific:** Give Claude concrete instructions, not vague guidance
2. **Show Examples:** Include good and bad examples
3. **Explain Why:** Help Claude understand the purpose behind each instruction
4. **Structure Clearly:** Use headings, lists, and formatting
5. **Test Thoroughly:** Try it with real-world scenarios

### Code of Conduct

- Be respectful and constructive
- Focus on improving the plugin
- Help others learn and contribute
- Assume good faith

## Questions?

Open an issue or discussion on GitHub. We're happy to help!

## License

By contributing, you agree that your contributions will be licensed under the MIT License.
