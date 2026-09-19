# SMRITI-NER Project Rules

## Project Context
This is an elderly-friendly cognitive and memory-support Flutter application.

## Coding Rules
- Preserve existing architecture unless a change is necessary.
- Do not remove working functionality.
- Do not replace existing implementations without inspecting them first.
- Prefer minimal, targeted changes.
- Maintain offline-first behavior.
- Preserve SQLite persistence.
- Preserve Supabase synchronization.
- Preserve accessibility and elderly-friendly UX.

## UI Rules
- Use large touch targets.
- Maintain high contrast.
- Keep navigation simple.
- Avoid unnecessarily dense interfaces.
- Preserve existing visual language unless explicitly asked to redesign it.
- Maintain readable typography.

## Testing Rules
After meaningful code changes:
- Run flutter analyze.
- Run relevant Flutter tests.
- Fix regressions before continuing.

## Safety Rules
- Never hard-code secrets or credentials.
- Do not expose Supabase service-role keys.
- Do not commit passwords or private API keys.
- Check the existing .gitignore before adding generated files.

## Change Management
Before modifying code:
1. Inspect the relevant files.
2. Understand existing behavior.
3. Explain the intended change internally through the implementation plan.
4. Make the smallest suitable change.
5. Run validation.

## Documentation
Update docs/ANTIGRAVITY_HANDOFF.md when major project state changes.
