1. Update CHANGELOG.md
2. tag: v0.12.23
3. 56cd7859e05c36c06b56d013b55a252d0bb7e158
   9ea88f22fc6269854151c571162c5bcf958bee2b
4.
oneline:33ff1c03b:v0.12.24
oneline:b14b74c49:[Website] vmc provider links
oneline:3f235065b:Update CHANGELOG.md
oneline:6ae64e247:registry: Fix panic when server is unreachable
oneline:5c619ca1b:website: Remove links to the getting started guide's old location
oneline:06275647e:Update CHANGELOG.md
oneline:d5f9411f5:command: Fix bug when using terraform login on Windows
oneline:4b6d06cc5:Update CHANGELOG.md
oneline:dd01a3507:Update CHANGELOG.md
oneline:225466bc3:Cleanup after v0.12.23 release 

5.Consult local directories as potential mirrors of providers

6.
Remove config.go and update things using its aliases
keep .terraform.d/plugins for discovery
Add missing OS_ARCH dir to global plugin paths
move some more plugin search path logic to command
Push plugin discovery down into command package

7.
Author: James Bardin <j.bardin@gmail.com>
Author: Martin Atkins <mart@degeneration.co.uk>


