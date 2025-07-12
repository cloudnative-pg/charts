# Pull Request Template for Helm Repository

Thank you for your contribution, but following this best practices, you help
reviewers to get the code to main and release faster:

1. Open PR in draft mode
2. Progressively fill in verification sections
3. Mark as ready for review only when all requirements are met

## Associated Issue Information
- Issue Reference: #XXXX
- Detailed Description:
  * Implementation objectives:
  * Main modifications:
  * Impact on existing functionality:

## Technical Requirements Verification
### 1. Structure and Conventions
- [ ] YAML code properly indented
- [ ] Naming conventions respected
- [ ] Templates follow Helm best practices

### 2. Tests and Validation
- [ ] New values tested in `test` directory
- [ ] Cluster asserts added or updated `test` directory

### 3. Code Quality
- [ ] YAML code linted (`yamllint`)
- [ ] No conflicts with existing key names including opened PRs

### 4. Code Management
- [ ] Branch rebased with main
- [ ] Commits are atomic and well-described
- [ ] Code documented and description added to `values.schema.json`

## Notes for Reviewers
- Particular points to check:
  * [description]

## PR State
- [ ] Ready for review
