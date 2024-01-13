---
title:  "How to extract a script and its history from a git repository"
tags:   git
---

A few days ago, I needed to extract a script from a git repository maintained
by another team and import it into my own repository.

## Naive approach

The first thing I did was to copy paste the script in a new repository and
start from here. However, I later realized that I also wanted to keep the
changesets of the script from the old repository. To complicate things,
the script was also modified in the new one.

For the purpose of this post, let's call `myscript` the script
I want to import, `myrepo` the new repository I created to hold this script and
`oldrepo` the repository where it was previously maintained.

## Extracting the history

The first step was to extract the changesets in the old repository that
modified my script. To do so, I first created a new branch to work on.

``` bash
$ cd /path/to/oldrepo
$ git checkout -b export_myscript
```

Then, I used `filter-branch` command from git to only extract the
commits I was interested in.

``` bash
$ git filter-branch --prune-empty --tree-filter \
  'find -not -name myscript -delete'
```

Basically, the `filter-branch` command will loop over every commit of the
current branch and execute the command provided. The `find` command I used will
delete all the files whose name is not `myscript`. Then, thanks to the
`--prune-empty` option, it will remove the empty commits, which are basically
the ones that don't alter `myscript`.

This has the same result as if you manually checkout all the commits one by
one, execute the command and perform a `git commit --amend`. However, this is
much faster and much more powerful.

You can always rollback your changes by doing `git reset --hard master` if your
parent branch is `master`. Also, the current branch is backed up under the name
`refs/original/refs/heads/YOUR_BRANCH`. So in this case you could do:

``` bash
$ git reset --hard refs/original/refs/heads/export_myscript
```

## Removing submodules

To add a little more fun, the repository contained a submodule. In that case,
you first need to unregister the submodule with the following command.

``` bash
$ git submodule deinit mysubmodule
```

Then, you can remove the submodule folder from all the commits. Because
a submodule is not a regular file, it needs to be removed with the `git rm`
command.

``` bash
$ git filter-branch -f --prune-empty --index-filter \
    "git rm -r -f --cached --ignore-unmatch mysubmodule"
```

The advantage of the `--index-filter` is that it doesn't need to checkout the
files before executing the command, making it much faster. However, it is
limited to the git commands, that's why I didn't use it before. Finally, the
`-f` flag allows you to remove the backup from the previous run of the
`filter-branch` command.

## Extracting a folder

If you need to extract a folder instead of a file, there is a very simple way
to do so. You just need to run the following command:

``` bash
$ git checkout extract-foodir
$ git filter-branch --subdirectory-filter foodir -- --all
```

After this command, the `foodir` directory becomes the new root of the
repository and all your commits are rewritten to reflect this change.

You can also use the `subtree` command which is even more straightforward. In
fact, the following command will directly create a new branch `extract-foodir`
whose root is the `foodir` directory.

``` bash
$ git subtree split --prefix=foodir -b extract-foodir
```

The `subtree` command is much more powerful as it allows you to keep the
subdirectory in the original repository and merge your changes back and forth.
You can read more in the [official subtree documentation][subtree].

## Importing the history in the new repository

Finally, I need to import the history in our repository. To do so, I will
import the old repository content in the new one.

``` bash
$ cd /path/to/myrepo
$ git remote add oldrepo /path/to/oldrepo
$ git fetch oldrepo export_myscript
```

Then I will reapply all the commits of my repository on top of the
`export_myscript` branch I just imported. I will do that on a new branch called
`import_myscript`.

``` bash
$ git checkout -b import_myscript
$ git rebase oldrepo/export_myscript
```

Git will recalculate all the diffs between commits. The consequence is that the
commit corresponding to the copy pasting of `myscript` from `oldrepo` to
`myrepo` should be empty. This can be verified with a `git log --stat`.

I can now reset your master branch to your `import_myscript` branch and do some
cleanup.

``` bash
$ git checkout master
$ git reset --hard import_myscript
$ git branch -d import_myscript
$ git remote rm oldrepo
$ cd /path/to/oldrepo
$ git checkout master
$ git branch -D export_myscript
```

## Final thoughts

This article should give you a glimpse at the power of git. If you want to
learn more about git, I recommend you the [Pro Git book][], especially chapter
7 in which you will learn some advanced tricks. Chapter 10 is also interesting
as it explains how git works internally.

[subtree]:      https://github.com/git/git/blob/master/contrib/subtree/git-subtree.txt
[Pro Git book]: https://git-scm.com/doc
