# VNC

Use the vnc plugin to install VNC with the command switch `--plugin vnc:arguments`.

The arguments you specify can enable RealVNC and one of tigervnc or tightvnc.

* **realvnc=resolution** &mdash; Install RealVNC server with the specified resolution on the console. The resolution is optional.
* **tigervnc=res1,res2,...resn** &mdash; Install tigervnc server with virtual VNC servers for the specified resolutions
* **tightvnc=res1,res2,...resn** &mdash; Install tightvnc server with virtual VNC servers for the specified resolutions

## Examples

* `--plugin vnc:"realvnc|tigervnc=1280x1024,1600x1200` &mdash; Install RealVNC server for the console and tigervnc virtual desktop servers for the specified resolutions.
* `--plugin vnc:"realvnc=1600x1200"` &mdash; Install RealVNC server and configure the console for 1600x1200, just as raspi-config VNC configuration does.
* `--plugin vnc:"tigervnc=1024x768,1600x1200,1280x1024"` &mdash; Install tigervnc virtual desktop servers for the specified resolutions. Only configure RealVNC if it is already installed (e.g., RasPiOS with Desktop IMG).

## Additional Details

By default Virtual VNC desktops are configured with ports 5901, 5902, ... This can be modified with the `--vncbase` *base* switch. For instance, `--vncbase 6400` would place the VNC virtual desktops at ports 6401, 6402, ... Setting `--vncbase` does not change the RealVNC server port.

For RasPiOS Desktop, RealVNC Server will be enabled automatically. Well, actually, it will be disabled for the first boot of the system as will the graphical desktop, and the sdm FirstBoot service will-reenable both for subsequent use.

For RasPiOS Lite, if `--poptions nodmconsole` is specified AND the Display Manager is xdm or wdm, the Display Manager will not be started on the console, and neither will RealVNC Server. It can be started later, if desired, with `sudo systemctl enable --now vncserver-x11-serviced`. Note, however, that you must enable the Display Manager as well for it to really be enabled. To enable the Display Manager:

* **xdm:**&nbsp;`sed -i "s/\#\:0 local \/usr\/bin\/X :0 vt7 -nolisten tcp/\:0 local \/usr\/bin\/X :0 vt7 -nolisten tcp/"  /etc/X11/xdm/Xservers`
* **wdm:** `sed -i "s/\#\:0 local \/usr\/bin\/X :0 vt7 -nolisten tcp/\:0 local \/usr\/bin\/X :0 vt7 -nolisten tcp/"  /etc/X11/wdm/Xservers`
<br>
<br>
<form>
<input type="button" value="Back" onclick="history.back()">
</form>
