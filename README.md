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