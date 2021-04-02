# FFXI Roll Distance

Tracks and displays the distance between you and other party members so you know who is in range for your next Phantom Roll.

## Example

![Roll Distance example](readme/demo.png)

* Green = in range.
* White = not in range.
* ?? = in zone, over 50 yalms away.
* -- = not in zone.

If everyone is in range, the background turns green.

## Commands

### //rd luzaf

Toggles whether you're using Luzaf's Ring for double range. Phantom Roll range is 8 yalms, and is doubled to 16 with Luzaf's Ring.

Default: true

### //rd interval &lt;number&gt;

Sets the refresh interval to the given number of seconds.

Default: 0.5

### //rd help

Displays help text in the chat log.
