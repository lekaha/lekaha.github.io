---
layout: post
title: Hello My Wiki
categories: wiki
---

## Changing author info
To change the name and/or email address recorded in existing commits, you must rewrite the entire history of your Git repository.

> Warning: This action is destructive to your repository's history. If you're collaborating on a repository with others, it's considered bad practice to rewrite published history. You should only do this in an emergency.

### Changing the Git history of your repository using a script
We've created a script that will change any commits that previously had the old email address in its author or committer fields to use the correct name and email address.

> Note: Running this script rewrites history for all repository collaborators. After completing these steps, any person with forks or clones must fetch the rewritten history and rebase any local changes into the rewritten history.`

Before running this script, you'll need:

- The old email address that appears in the author/committer fields that you want to change
- The correct name and email address that you would like such commits to be attributed to

1. Open Terminal.
2. Create a fresh, bare clone of your repository:
```
git clone --bare https://github.com/user/repo.git
cd repo.git
```
3. Copy and paste the script, replacing the following variables based on the information you gathered:

- OLD_EMAIL
- CORRECT_NAME
- CORRECT_EMAIL

```
#!/bin/sh

git filter-branch --env-filter '
OLD_EMAIL="your-old-email@example.com"
CORRECT_NAME="Your Correct Name"
CORRECT_EMAIL="your-correct-email@example.com"
if [ "$GIT_COMMITTER_EMAIL" = "$OLD_EMAIL" ]
then
    export GIT_COMMITTER_NAME="$CORRECT_NAME"
    export GIT_COMMITTER_EMAIL="$CORRECT_EMAIL"
fi
if [ "$GIT_AUTHOR_EMAIL" = "$OLD_EMAIL" ]
then
    export GIT_AUTHOR_NAME="$CORRECT_NAME"
    export GIT_AUTHOR_EMAIL="$CORRECT_EMAIL"
fi
' --tag-name-filter cat -- --branches --tags
```

<script src="https://gist.github.com/octocat/0831f3fbd83ac4d46451.js"></script>

4. Press Enter to run the script.
5. Review the new Git history for errors.
6. Push the corrected history to GitHub

```
git push --force --tags origin 'refs/heads/*'
```
7. Clean up the temporary clone:

```
cd ..
rm -rf repo.git
```

### References
[Changing author info](https://help.github.com/articles/changing-author-info/)
