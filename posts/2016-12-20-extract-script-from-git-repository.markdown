---
title:  "How to extract a script from a git repository"
tags:   git
---

A few days ago, I needed to extract a script from a git repository maintained
by another team and import it in our newly created repository. This would allow
us to implement our own continuous integration pipeline.

## Naive approach

The first thing I did was to copy paste the script in a new repository and
start from here. However, I later realized that I also wanted to keep the
changesets of the script from the old repository. To complicate things, the
script was also modified in the new one.

For the purpose of this post, let's call `myscript` the script
I want to import, `myrepo` the new repository I created to hold this script and
`oldrepo` the repository where it was previously maintained.

## Extracting the history

The first step was to extract the history in the old repository that concerned
my script. To do so, I first created a branch to be sure I would lose all my
data, although I could always clone the repository later.

``` bash
$ cd /path/to/oldrepo
$ git checkout -b export_myscript
```

Then, I used `filter-branch` command from `git` to only extract the part that
concerned my script.

``` bash
$ git filter-branch --prune-empty --tree-filter 'find -not -name myscript -delete'
```

Basically, this will run through each commit of the current branch and execute
the command. The `find` command we execute will delete any file whose name is
not `myscript`. Then, thanks to the `--prune-empty` option, it will remove the
empty commits, which are basically the ones not concerning `myscript`.

This has the same result as checking out all commits one by one, execute the
command you provided and perform a `git commit --amend`. However, this is much
faster and much more powerful.

You can always rollback your changes by doing `git reset --hard master` if your
parent branch was `master`. Also, the current branch is backed up under the
name `refs/original/refs/heads/YOUR_BRANCH`. So in this case you could do:

``` bash
$ git reset --hard refs/original/refs/heads/export_myscript
```

## Removing submodules

To make things a little more fun, the repository contained a submodule. First,
we had to unregister the submodule with the following command.

``` bash
$ git submodule deinit mysubmodule
```

Then, we had to remove the submodule folder from all the commits. Because this
is not a regular file, it needs to be removed with the `git rm` command.

``` bash
$ git filter-branch -f --prune-empty --index-filter \
    "git rm -r -f --cached --ignore-unmatch mysubmodule"
```

The advantage of the `--index-filter` is that it doesn't need to checkout the
files before executing the command, making it much faster. However, we are
limited to the git commands, and filtering all files except our script would be
little tricky. Finally, we use the `-f` flag to remove the backup from the
previous run of the `filter-branch` command.

## Extracting a folder

If you need to extract a folder instead of a file, there is a very simple way
to do so. You just need to run the following command:

``` bash
$ git filter-branch --subdirectory-filter foodir -- --all
```

## Importing the history in the new repository

Now, you need to import the history in our repository. To do so, we will import
the old repository content in the new one.

``` bash
$ cd /path/to/myrepo
$ git remote add oldrepo /path/to/oldrepo
$ git fetch oldrepo export_myscript
```

Then we will reapply all the commits of our repository on top of the
`export_myscript` branch we just imported. We will do that on a new branch
called `import_myscript` in case we do a mistake.

``` bash
$ git checkout -b import_myscript
$ git rebase oldrepo/export_myscript
```

Running `git log --stat`, you can see that the commit corresponding to the copy
of the script in your repository is now empty. In fact, git will recalculate
all the diffs between commits and will deduce that `myscript` didn't change.

You can now reset your master branch to your `import_myscript` branch and do
some cleanup.

``` bash
$ git checkout master
$ git reset --hard import_myscript
$ git branch -d import_myscript
$ git remote rm oldrepo
$ cd /path/to/oldrepo
$ git checkout master
$ git branch -D export_myscript
```

## Final thoughts

This article should give you some glimpse at the powerful things you can do
with git. I recommend you to read the [Pro Git book][], especially chapter 7
if you want to discover other advanced tricks with git and chapter 10 to
discover how git works internally.

