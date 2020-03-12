# Go + Semantic-Release + GitHub Actions

[![build](https://github.com/JasonTheDeveloper/Go-Semantic-Release-GitHub-Actions/workflows/build/badge.svg?branch=master)](https://github.com/JasonTheDeveloper/Go-Semantic-Release-GitHub-Actions/actions?query=workflow%3Abuild) [![semantic-release](https://img.shields.io/badge/%20%20%F0%9F%93%A6%F0%9F%9A%80-semantic--release-e10079.svg)](https://github.com/semantic-release/semantic-release)

This project is purely meant to serve as an example of how you could use [DevContainers](https://code.visualstudio.com/docs/remote/containers) for development, [semantic-release](https://github.com/semantic-release/semantic-release) to manage releases, and [GitHub Actions](https://github.com/features/actions) for testing/building go targeting different architectures.

## Table of contents

- [Overview](#overview)
  - [DevContainers](#devcontainers)
  - [Semantic-Release](#semantic-release)
    - [Why Semantic-Release](#why-semantic-release)
      - [GoReleaser vs. Semantic-Release](#goreleaser-vs.-semantic-release)
      - [GitHub Release](#gitHub-release)
  - [Go](#go)
  - [GitHub Actions](#gitHub-actions)
- [How it Flows Together](#how-it-flows-together)
  - [Go Project](#go-project)
    - [Build + ldflags](#build-+-ldflags)
  - [Semantic-Release - Constructing Commit Message](#semantic-release---constructing-commit-message)
  - [GitHub Action Workflow - Release](#github-action-workflow---release)
    - [Semantic-Release - Creating a GitHub Release](#semantic-release---creating-a-github-release)
- [Gotchas](#gotchas)

## Overview

The following is a brief overview of what's in this repository and how they're configured.

### DevContainers

[DevContainers](https://code.visualstudio.com/docs/remote/containers) are terrific for getting other contributors up and running with little hassle. DevContainers takes the headache away from having to setup your development environment and ensures everyone on your team, contributing to the project all have the same setup regardless of their operating system and what dependencies they're missing.

Not only that but because DevContainers are containerised (as the name implies), if anything happens and you need to destroy and recreate your environment, you can with a click of a button!

There are a couple things you need in order to run the DevContainer and they are:

- [Visual Studio Code](https://code.visualstudio.com/)
- [Remote Development](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.vscode-remote-extensionpack)
- [Docker](https://docs.docker.com/install/)

A full DevContainer setup guide can be found [here](https://code.visualstudio.com/docs/remote/containers#_getting-started).

The DevContainer in this repository is configured specifically for `Go` and installs additional packages and Visual Studio Code extensions to make developing `Go` a bit nicer.

Sample DevContainers for other languages can be found [here](https://github.com/microsoft/vscode-dev-containers/tree/master/containers).

### Semantic-Release

[Semantic-release](https://github.com/semantic-release/semantic-release) is highly configurable and offers handy plugins to fit your project needs!

Found in [package.json](package.json) you'll find our semantic-release's configuration. Below is an example of what we have:

```json
{
    "devDependencies": {
        "@semantic-release/changelog": "^5.0.0",
        "@semantic-release/exec": "^5.0.0",
        "@semantic-release/git": "^9.0.0",
        "@semantic-release/github": "^7.0.4",
        "semantic-release": "^17.0.4"
    },
    "release": {
        "plugins": [
            "@semantic-release/commit-analyzer",
            "@semantic-release/release-notes-generator",
            [
                "@semantic-release/changelog",
                {
                    "changelogFile": "docs/CHANGELOG.md"
                }
            ],
            [
                "@semantic-release/git",
                {
                    "assets": [
                        "docs/CHANGELOG.md"
                    ]
                }
            ],
            [
                "@semantic-release/exec",
                {
                    "publishCmd": "export RELEASE=${nextRelease.version} && make release GOOS=linux && make release GOOS=darwin && make release GOOS=windows"
                }
            ],
            [
                "@semantic-release/github",
                {
                    "assets": [
                        {
                            "path": "./example_linux_amd64.tar.gz"
                        },
                        {
                            "path": "./example_darwin_amd64.tar.gz"
                        },
                        {
                            "path": "./example_windows_amd64.zip"
                        },
                        {
                            "path": "./checksums.sha256"
                        }
                    ]
                }
            ]
        ]
    }
}
```

Underneath `devDependencies` we specify which packages to install and their versions.

Under `release` is where we configure the plugins semantic-release needs.

Lets have a quick look at which plugins we're using:

| Plugin | Link | Description |
| - | - | - |
| `@semantic-release/commit-analyzer` | [Link](https://github.com/semantic-release/commit-analyzer) | Used to analyse git commit message |
| `@semantic-release/release-notes-generator` | [Link](https://github.com/semantic-release/release-notes-generator) | Responsible for generating the changelog content. |
| `@semantic-release/changelog` | [Link](https://github.com/semantic-release/changelog) | Utilised by `@semantic-release/release-notes-generator`, responsible for creating and updating a changelog file.
| `@semantic-release/git` | [Link](https://github.com/semantic-release/git) | Allows us to commit back to the repository. |
| `@semantic-release/exec` | [Link](https://github.com/semantic-release/exec) | Gives us the ability to run shell commands. In our case we use it to export the next release semantic version and to build the project binaries. |
| `@semantic-release/github` | [Link](https://github.com/semantic-release/github) | Creates GitHub releases and provides the capability to comment on pull requests and issues. |

**Note:** in your project if you were to incorporate semantic-release, the two plugins you'll need to configure at the very least are `@semantic-release/exec` and `@semantic-release/github`. Everything else as is should work for your project needs.

#### Why Semantic-Release

Semantic-release is a great, standalone tool that sits in your CI pipeline, used to manage versioning and release of your project. Semantic-release is responsible for generating changelog, increasing the semantic version, and creating new releases in GitHub.

##### GoReleaser vs. Semantic-Release

[GoReleaser](https://github.com/goreleaser/goreleaser) is another tool that could have been used over semantic-release. It generates `Go` binaries for several platforms, it creates a new GitHub release but on top of that, GoReleaser also pushes a HomeBrew formula to a tap repository!

So why not GoReleaser? A couple reasons.

1. The release notes are not formatted as they are with semantic-release.
2. GoReleaser does not commit a `CHANGELOG.md` back to the repo.
3. It appears GoReleaser only works with `Go` projects, while semantic-release can work regardless of the underlining language as it's git commit based.

Putting aside the fact this repository uses `Go` as an example project, with some minor tweaks, the configurations used for semantic-release in this repository can be transferred and applied to any project regardless of programming language.

##### GitHub Release

Semantic-release was chosen for creating new GitHub releases over other actions like [Create Release](https://github.com/marketplace/actions/create-release) because semantic-release is smart enough to only include changes that happened between releases automatically.

Sure, with [Create Release](https://github.com/marketplace/actions/create-release) you can point to the `CHANGELOG.md` generated by semantic-release and use that for the body, but the way semantic-release generates the `CHANGELOG.md`, your body will have the complete changelog history in the release which is not very ideal.

### Go

In this repository there's an extremely basic `Go` project to demonstrate how semantic-release can be used as apart of your CI pipeline.

Lets have a look at what the `Go` project is actually doing.

```go
package main

import "fmt"

var (
	version = "dev"
	commit  = "none"
	date    = "unknown"
)

func main() {
	fmt.Printf("version %v, commit %v, built at %v", version, commit, date)
}
```

Above `func main()` you'll notice we're declaring 3 variables. `version`, `commit` and `date`. Right now they have default values set.

Inside `func main()` all we're doing is printing to console the `version`, `commit` and `build` variables.

Running `go run main.go` from your terminal should return:

```cli
version dev, commit none, built at unknown
```

Later we'll update these variables using values generated by semantic-release.

### GitHub Actions

In this repository there's one GitHub Action [workflow](.github/workflows/example_build.yaml) setup to lint, test, build and release the example project.

Looking at the [workflow](.github/workflows/example_build.yaml), linting, testing/building and release are separated into their own jobs.

Firstly, `lint` and `test` run in parallel. `test` runs on `ubuntu-latest`, `macos-latest`, and `windows-latest`, and builds/tests `Go` with version `1.12.x` and `1.13.x`. If all jobs complete successfully, the `release` job is triggered.

The reason `lint` isn't apart of the `test` job is because we don't need to worry about whether the project is formatted correctly on different operating systems as linting is more to do with coding styles which is not affected by the system you're running.

Another thing you may notice is the workflow is [triggered](.github/workflows/example_build.yaml#L3-L11) when a pull request is submitted to master and whenever a push to master is performed.

We could have split the workflow into two, one for building and testing for pull request, while the other is used for when pull requests are completed and merge with master to release the binaries. This could save on build times when PRs are performed. Instead, an `if` [condition](.github/workflows/example_build.yaml#L75) is used to only run the `release` job when triggered from a push to the master branch.

More information about using GitHub Actions can be found [here](https://help.github.com/en/actions).

## How it Flows Together

### Go Project

As previously [mentioned](#go), our example project as three variables, a `version`, `commit` and `date`, with default vaules. We could manually change these vaules inside [main.go](main.go) every time a pull request is made but that's tedious and why do that when semantic-release can do that for us!

#### Build + ldflags

In `Go`, when we build the binaries we can actually override values in the project using the `-ldflags` flag.

Having a look in [Makefile](Makefile#L72-75) we see the following:

```makefile
GIT_VERSION = $(shell git rev-list -1 HEAD)

ifdef RELEASE
	EXAMPLE_VERSION := $(RELEASE)
else
	EXAMPLE_VERSION := dev
endif

BUILD_DATE = $(shell date -u)

...

LDFLAGS:=-X main.commit=$(GIT_VERSION) -X main.version=$(EXAMPLE_VERSION) -X "main.date=$(BUILD_DATE)"

build::
	GOOS=$(GOOS) GOARCH=amd64 go build -ldflags='$(LDFLAGS)' -o example$(BINARY_EXT) main.go
```

What we're doing is grabbing the current git commit hash and setting it to `GIT_VERSION`. 

Next we're checking if `$RELEASE` is set or not. If it's not, `EXAMPLE_VERSION` is set to `dev`, otherwise we set `EXAMPLE_VERSION` to `RELEASE`. `RELEASE` will eventually come from semantic-release.

Using `date -u`, BUILD_DATE is used to hold the current date and time.

After that, we construct `LDFLAGS` using our just defined variables and pass them in using `-ldflags` when running `go build`.

For more in-depth tutorial on using `-ldflags`, see [Using ldflags to Set Version Information for Go Applications](https://www.digitalocean.com/community/tutorials/using-ldflags-to-set-version-information-for-go-applications).

### Semantic-Release - Constructing Commit Message

In order for semantic-release to know how to generate the next release version, you must follow the correct message schema.

```commit
<type>(<scope>): <subject>
<BLANK LINE>
<body>
<BLANK LINE>
<footer>
```

The **header** is mandatory and the **scope** of the header is optional. The footer can contain a closing reference to an issue.

The type must be one of the following:

| Type | Description |
| - | - |
| **feat** | A new feature |
| **fix** | A bug fix |
| **perf** | A code change that improves performance |
| **build** | Changes that affect the build system or external dependencies (example scopes: gulp, broccoli, npm) |
| **ci** | Changes to our CI configuration files and scripts (example scopes: Travis, Circle, BrowserStack, SauceLabs) |
| **docs** | Documentation only changes |
| **refactor** | A code change that neither fixes a bug nor adds a feature |
| **style** | Changes that do not affect the meaning of the code (white-space, formatting, missing semi-colons, etc) |
| **test** | Adding missing tests or correcting existing tests |

**Note:** new releases are only triggered when type `fix`, `feat` or `perf` are used in your commit message.

| Commit message | Release type |
| - | - |
| `fix(pencil): stop graphite breaking when too much pressure applied` | Patch Release |
| `feat(pencil): add 'graphiteWidth' option` | ~~Minor~~ Feature Release  |
| `perf(pencil): remove graphiteWidth option`<br><br>`BREAKING CHANGE: The graphiteWidth option has been removed.`<br>`The default graphite width of 10mm is always used for performance reasons.` | ~~Major~~ Breaking Release |

For more information, see [semantic-release](https://github.com/semantic-release/semantic-release#how-does-it-work).

### GitHub Action Workflow - Release

In our [workflow](.github/workflows/example_build.yaml), we've set it up so that the workflow is triggered whenever a pull request or a push to the master branch. The semantic-release portion of the workflow will only run once the PR has been approved and merged into master.

Assuming the pull request is approved and merged, the workflow will run again but this time it will also run the `release` [job](.github/workflows/example_build.yaml) of our workflow.

The `release` job of our workflow is responsible primarily to building our project's binaries, generating changelog, tagging the commit and creating a new GitHub release.

Lets take a moment and examine what's happening. Below you'll find a snippet of the workflow.

```yaml
release:
    name: 'release example'
    if: github.event_name == 'push' && github.ref == 'refs/heads/master'
    runs-on: ubuntu-latest
    needs: [lint, test]
    steps:
      - name: 'setup node.js'
        uses: actions/setup-node@v1.4.0
        with:
          node-version: 12

      - name: 'install go ${{ env.GOVER }}'
        uses: actions/setup-go@v1.1.2
        with:
          go-version: ${{ env.GOVER }}

      - name: 'checkout'
        uses: actions/checkout@master

      - name: 'install dependencies'
        run: npm ci

      - name: 'generate semantic version'
        run: npx semantic-release
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}

```

1. The first step is to install `node.js` onto our build agent. This is necessary for semantic-release to run.
2. Install `Go` so that we can build the example project in this repository.
3. Checkout this repository so the build agent has a copy of the project to work from.
4. Next we're going to download the required npm modules specified in [package.json](package.json).
5. With that all setup, semantic-release can do its thing!

#### Semantic-Release - Creating a GitHub Release

As mentioned [previously](#semantic-release), we configured semantic-release to utilise a couple different plugins to generate changelog and release version, build and publish the binaries.

Once our workflow hits the final step, running semantic-release, here's how semantic-release flows:

1. Analyse the commit messages and generates the next release's version.

**Note:** At this point, if there was no changes made to the project that requires a new release (e.g. type `fix`, `feat` or `pref` were not used since the last release) then semantic-release will stop here and would not continue.

2. Generate `CHANGELOG.md` with the changes.
3. Commits `CHANGELOG.md` back to the repository under the `docs` folder.
4. Export the next release version followed by building the example project for `linux`, `darwin` and `windows` architectures. The exported release version is injected when building the binaries using `-ldflags` as mentioned [previously](#build-+-ldflags).
5. Finally, a new GitHub release is created with our newly built binaries and accompanied changelog.

## Gotchas

Keep in mind while using semantic-release you may run into trouble using squash + merge when completing pull requests as noted [here](https://github.com/semantic-release/semantic-release/blob/master/docs/support/troubleshooting.md#squashed-commits-are-ignored-by-semantic-release). The reason is most git tools automatically generate the commit message and summary which is most likely not compliant with semantic-release's commit message schema.

To get around this make sure to rewrite the commit message so that it is compliant with semantic-release's messaging schema before pushing.

Another thing to note is semantic-release is case sensitive. The types used in your git commit message e.g. `fix`, `docs`, etc. has to be lowercase. Anything else, semantic-release will ignore it.
