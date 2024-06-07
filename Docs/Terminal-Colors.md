# Terminal Colors

If your terminal supports it (xterm and lxterminal definitely work), sdm changes the terminal colors when providing a command prompt in Phase 1, or when using the `--mount` command, to remind you that things are not quite "normal".

The colors used by --explore are controlled by the `--ecolors` command switch, which takes an argument specified as 3 colors. The default is `--ecolors blue:gray:red` which sets the foreground (text) blue, the background gray, and the cursor red.

The colors for the `--mount` command are controlled by the `--mcolors` switch; the default is `--mcolors black:LightSalmon1:blue`.

If your terminal emulator doesn't do a good job of setting and/or restoring the terminal colors as described above (for example `konsole` seems to have a problem restoring the terminal colors), you can use the `--ecolors 0` and `--mcolors 0` switches to disable sdm's terminal coloring.

<br>
<form>
<input type="button" value="Back" onclick="history.back()">
</form>
