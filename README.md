# Cogito

Cogito is a lightweight and intuitive Ruby CLI tool that provides an interactive interface for crafting commit messages following the **Conventional Commits** standard in Rails projects (and any Ruby-based project).

## Features 

- 🚀 Interactive step-by-step interface to choose commit type (`feat`, `fix`, `chore`, `docs`, `style`, `refactor`, `test`, etc.).
- 🏷️ Optional **scope** support for more precise commit descriptions.
- 📝 Automatic commit message formatting according to the Conventional Commits standard.
- 🔧 Option to directly commit via Git after generating the message.
- 📦 Minimal dependencies — fully written in Ruby.
- 🎯 Perfect for Rails developers who want to standardize commit history.
- ⚙️ Easy integration with CI/CD pipelines and Git hooks.

## Why Cogito?

- ❌ No need for Node.js, Rust, or other external tools — 100% Ruby.
- 🖥️ Simple to use — run `cogito` and follow the interactive generator.
- 🔄 Flexible and extensible — easily adapted to your team’s workflow.
- 📚 Keeps your commit history clean and consistent for better collaboration and release management.

## Installation

```bash
gem install cogito
```

Or add it to your project’s Gemfile:

```bash
gem "cogito"
```

## Usage

```bash
cogito
```

You’ll be guided through a series of prompts to build your commit message, with the option to confirm and commit directly.

## Usage

Apache-2.0
