# README


## For cosign
Keys are generated with something like:
```
    $ COSIGN_PASSWORD=just1testing2password3 cosign generate-key-pair
```

Then upload them manually to the github repo's secrets. Name them like so:
```
    COSIGN_PASSWORD
    COSIGN_PRIVATE_KEY
    COSIGN_PUBLIC_KEY
```

Also a good tutorial is
[here](https://dev.to/n3wt0n/sign-your-container-images-with-cosign-github-actions-and-github-container-registry-3mni),
though the approach is a little more autoamted and has a keener eye towards
real-world usage.
The key-generation step would be more like the following, which automatically
uploads the public key, private key, and key secret to the github repo:
```
    $ GITHUB_TOKEN=ghp_... \
    COSIGN_PASSWORD=just1testing2password3 \
    cosign generate-key-pair github://portersrc/infra
```
This may be a better realistic case, but it puts the private key in a github
secret, and I want to just keep it open and readable in the infra repo for
testing purposes.







## For "simple signing" (i.e. with gpg)
The first step was to generate a key. Choose the default options for these
purposes. The command is:
```
    $ gpg --full-generate-key
```
It has some prompts. The user for testing purposes is:
```
    Github Runner
    git@runner.com
    just1testing2password3
```


Then we exported it. The `--export-secret-key` option is sufficient for
exporting both the secret and public key. Example command:
```
    $ gpg --export-secret-key F63DB2A1AB7C7F195F698C9ED9582CADF7FBCC5D &> github-runner.keys
```

This is all that was needed (in addition to creating a .txt file with the
password to make automation with skopeo testing easy).

The CI will import the key (using `--batch` to avoid typing the password):
```
    $ gpg --batch --import github-runner.keys
```


### Other helpful commands
List public and secret keys:
```
    $ gpg --list-keys
    $ gpg --list-secret-keys
```

Example of deleting a key (must first delete the secret one first, then the
public one):
```
    $ gpg --delete-secret-keys F63DB2A1AB7C7F195F698C9ED9582CADF7FBCC5D
    $ gpg --delete-keys F63DB2A1AB7C7F195F698C9ED9582CADF7FBCC5D
```
