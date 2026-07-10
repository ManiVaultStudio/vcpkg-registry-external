### ManiVaultStudio custom vcpkg-registry

Contains common third-party libraries consumed in ManiVault core or plugins
that have specific port requirements. For example our Qt port (consumed by core and all plugins) is limited to non-viral license packages.

In general however plugins are free to use their own vcpkg ports via the
normal vcpkg.json mechanism. 

### Configuration

In order to pick-up the custom ports each project should include the
. In practice developers using the DevBundle system
do not need to do this manually because from DevBindle version 2 the
`vcpkg-configuration.json` file is automatically injected by the DevBundle
`use` sub-command. 

### Developers notes

This registry was created using instructions in the [Microsoft vcpkg doc] (https://learn.microsoft.com/en-us/vcpkg/produce/publish-to-a-git-registry)

### SHA512 tip for portfile

Gitven a repo with a tag of the form `vxxx.yyy.zzz.aaa` - in this example FreeImage. The following powershell command can be used to get the GitHub SHA512 for the portfile 

```pwsh
Invoke-WebRequest -Uri "https://github.com/biovault/FreeImage/archive/refs/tags/v3.19.0.2.zip" -OutFile "repo.zip"; (Get-FileHash -Path "repo.zip" -Algorithm SHA512).Hash; Remove-Item "repo.zip"
```

This can then be used in the `vcpkg_from_github` call. 

### git-tree tip for version file

git-tree in the version file is the SHA for the directory object of the port. As long as the contents of the port directory remain unchanged this git-tre SHA will remain constand (this is the basic optimization that git achieves using Merkle trees). So after the commit if the stable port directory, in this example freeimag, then the following can be used to retrieve the git-tree SHA that can ben then added manually to the versions file

```pwsh
git rev-parse HEAD:ports/freeimage                            
```

Substitute any other port for freeimage. 