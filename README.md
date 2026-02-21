# Squonk2 VS Code Python DevContainer

![build](https://github.com/informaticsmatters/squonk2-python-vscode-dev-container/actions/workflows/build.yaml/badge.svg?branch=3.13)

An evolving set of files that can be used to create a [dev-container] to satisfy
our Python development with Visual Studio Code. Just put these files into
your workspace `.devcontainer` directory and VS Code should do the rest.

>   We recommend that you place these files in your **workspace** folder rather
    than the repository clone/project folder. Why? We have *lots* of repositories
    that share this configuration and although requirements may vary a little from
    one source to another having one dev-container configuration is (at the moment)
    better than than repeating it 20 or 30 times across all our repositories!

1.  `devcontainer.json`
2.  `Dockerfile`
3.  `requirements.txt`

The above creates an image with the user "vscode" and the following tools
installed (amongst others): -

-   python (3.13 debian)
-   uv (0.10.4)
-   pre-commit (4.2)
-   ansible (11.8)
-   kubectl (1.35)
-   popeye (0.22)
-   Docker-in-Docker

**NOTE** You need a directory `~/k8s-config` on your local machine. The
Dev-Container expects this. This is where we put all our kubernetes cluster
config files and it wil lbe mounted into the DevContainer as `/k8s-config`.

A **postCreateCommand** is used to fix volume permissions of the command-history
file when you first start the dev-container. This allows command history to
persist between containers. You'll see a few messages ending with
**Done. Press any key to close the terminal.**. Hit any key and you'll be *good-to-go*.

>   Separate branches of this repository will be maintained
    for each active Major/Minor Python version used in our Projects.
    So you'll find a 3.13 branch for our Python 3.13 projects.

---

[dev-container]: https://code.visualstudio.com/docs/devcontainers/containers
