# **Contributing to ParadeDB**

Welcome! We're excited that you're interested in contributing to ParadeDB and want
to make the process as smooth as possible.

Before submitting a pull request, please review this document, which outlines what
conventions to follow when submitting changes. If you have any questions not covered
in this document, please reach out to us in the [ParadeDB Community Slack](https://join.slack.com/t/paradedbcommunity/shared_invite/zt-2lkzdsetw-OiIgbyFeiibd1DG~6wFgTQ)
or via [email](support@paradedb.com).

## Development Workflow

The majority of the development for ParadeDB happens in the [paradedb/paradedb](https://github.com/paradedb/paradedb) monorepo. Pleaser refer to this repository for general development. To develop for this repository, please follow the instructions below.

## Pull Request Worfklow

All changes to ParadeDB happen through GitHub Pull Requests. Here is the recommended
flow for making a change:

1. Before working on a change, please check to see if there is already a GitHub
   issue open for that change.
2. If there is not, please open an issue first. This gives the community visibility
   into what you're working on and allows others to make suggestions and leave comments.
3. Fork this repo and branch out from the `main` branch.
4. Install pre-commit hooks within your fork with `pre-commit install`, to ensure code quality and consistency with upstream.
5. Make your changes. If you've added new functionality, please add tests.
6. Open a pull request towards the `main` branch. Ensure that all tests and checks
   pass. Note that this repository has pull request title linting in place
   and follows the [Conventional Commits spec](https://github.com/amannn/action-semantic-pull-request).
7. Congratulations! Our team will review your pull request.

## Documentation

ParadeDB's public-facing documentation can be found at [docs.paradedb.com(https://docs.paradedb.com).

## Licensing

By contributing to ParadeDB, you agree that your contributions will be licensed
under the [GNU Affero General Public License v3.0](LICENSE).
