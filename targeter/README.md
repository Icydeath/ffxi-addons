# FFXI Targeter

*Note: This is a work in progress. For some reason, there is a targeting delay in lag-prone areas such as Dynamis Divergence - I'll be looking into this to see if it can be fixed or improved, as server-side lag should have no real impact on this addon.*

An FFXI Windower 4 addon that targets the nearest enemy to you based on a target list.

*Example:* In Dynamis Divergence, quickly target the closest statue amongst other enemies, even if it is right behind you.

## Load

`//lua load targeter`

## Setting a target

`//targ add mandragora` or `//targ a mandragora` adds mandragora to the target list.

Simply running `//targ add` will add the currently selected target to the target list.

## Target an enemy

`//targ target` or `//targ t` targets the nearest enemy to you from the target list.

## Removing a target

`//targ remove mandragora` or `//targ r mandragora` removes mandragora from the target list.

Simply running `//targ remove` will remove the currently selected target remove the target list.

## Target an enemy once

Sometimes you want to just target an enemy once without adding them to the target list:

`//targ once aurix` or `//targ o aurix` targets aurix and leaves your target list unchanged.

## Removing all targets

`//targ removeall` or `//targ ra` removes all targets from the target list.

## Display the target list

`//targ list` or `//targ l`

## Display Targeter help

`//targ` or `//targ help`

## Target sets

You can save sets of targets for future use. For example, you can set up a target set for Dynamis Divergence statues with the following:

```
//targ add corporal tombstone
//targ add lithicthrower image
//targ add incarnation idol
//targ add impish statue
//targ save statues
```

In the future, use the following to switch to the saved set:

`//targ load statues`

## Contributing

If you notice something not quite right, please [raise an issue](https://github.com/xurion/ffxi-targeter/issues).

Or better yet, [pull requests](https://github.com/xurion/ffxi-targeter/pulls) are welcome!
