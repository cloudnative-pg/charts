# Pull Request Template for Helm Repository

Thank you for your contribution, but following this best practices, you help
reviewers to get the code to main and release faster:

1. Open PR in draft mode
2. Progressively fill in verification sections
3. Mark as ready for review only when all requirements are met

## Pull Request

- [ ] [DCO](https://github.com/prometheus-community/helm-charts/blob/main/CONTRIBUTING.md#sign-off-your-work) signed
- [ ] Title of the PR starts with chart name (ex. [Cluster], [CNPG], etc.)

## Associated Issue Information
- Issue Reference: #XXXX

- Detailed Description:
  * Implementation objectives:
  * Main modifications:
  * Impact on existing functionality:

## Technical Requirements Verification
### 1. Structure and Conventions
- [ ] Naming conventions respected, for more information please refere to [cnpg doc Reference](https://cloudnative-pg.io/documentation/current/cloudnative-pg.v1/)
- [ ] Templates follow Helm best practices

### 3. Code Quality
- [ ] YAML code linted (`yamllint`)
- [ ] No conflicts with existing key names including opened PRs
- [ ] Branch rebased with main

## Nice to have

In order to help maintainer review this PR, please consider to:

### 2. Tests and Validation

- [ ] New values entries tested in `test` directory with `chainsaw`

### 4. Code Management
- [ ] Commits are atomic and well-described
- [ ] Contribution documented and genereted with `make docs`
- [ ] description added to `values.schema.json` with `make schema`

For more details, please refer to `CONTRIBUTING.md` guide


## Notes for Reviewers
- Particular points to check:
  * [description]
