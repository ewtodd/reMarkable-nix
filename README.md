# reMarkable-nix!
Declarative packaging for the reMarkable desktop app - using nix flakes + wrapWine by [lucasew](https://github.com/lucasew/nixcfg/blob/e542e743774f499f996a4f886a8d4a4133fce258/packages/wrapWine.nix). Since it's packaged with nix, it will just work!

## Usage
### Standalone
```
git clone https://github.com/YOUR_USERNAME/reMarkable-nix.git
cd reMarkable-nix
nix build
./result/bin/remarkable
```

### NixOS Configuration

```
# in your flake.nix
inputs = {
  # your other inputs
  remarkable.url = "github:ewtodd/reMarkable-nix";
};
# ...

# in your configuration.nix
{ inputs, ... }: 
let 
  remarkable = inputs.remarkable.packages."x86_64-linux".default;
in {
  # ...
  environment.systemPackages = [ remarkable ];
  # ...
}
```
