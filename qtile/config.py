import os
import socket
from libqtile.config import Key, Screen, Group, Drag, Click
from libqtile.command import lazy
from libqtile import layout, bar, widget, hook

scriptPath = "/home/mawi/.config/qtile/scripts"
colors = [
    ["#282828", "#282828"],  # panel background
    ["#504945", "#504945"],  # background for current screen tab
    ["#928374", "#928374"],  # font color for group names
    ["#928374", "#928374"],  # border line color for current tab
    ["#1d2021", "#1d2021"],  # border line color for other tab and odd widgets
    ["#282828", "#282828"],  # color for the even widgets
    ["#928374", "#928374"]
]  # window name
##### PROMPT #####
prompt = "{0}@{1}: ".format(os.environ["USER"], socket.gethostname())
#This is  set  for the  main window
##### DEFAULT WIDGET SETTINGS #####
widget_defaults = dict(font="Ubuntu Mono",
                       fontsize=14,
                       padding=3,
                       background=colors[2])
extension_defaults = widget_defaults.copy()
screens = [
    Screen(top=bar.Bar(
        [
            # This is a list of our virtual desktops.
            widget.GroupBox(font="Ubuntu Bold",
                            fontsize=9,
                            margin_y=3,
                            margin_x=0,
                            padding_y=5,
                            padding_x=5,
                            borderwidth=3,
                            active=colors[2],
                            inactive=colors[2],
                            rounded=False,
                            highlight_color=colors[1],
                            highlight_method="line",
                            this_current_screen_border=colors[3],
                            this_screen_border=colors[4],
                            other_current_screen_border=colors[0],
                            other_screen_border=colors[0],
                            foreground=colors[2],
                            background=colors[0]),

            # A prompt for spawning processes or switching groups. This will be
            # invisible most of the time.
            widget.Prompt(prompt=prompt,
                          font="Ubuntu Mono",
                          padding=10,
                          foreground=colors[3],
                          background=colors[1]),

            # Current window name.
            widget.WindowName(foreground=colors[6], background=colors[0]),
            widget.Notify(),
            widget.Systray(),
            widget.Volume(),
            widget.Battery(
                energy_now_file='charge_now',
                energy_full_file='charge_full',
                power_now_file='current_now',
                update_delay=5,
            ),
            widget.Systray(),
            widget.CurrentLayoutIcon(custum_icon_paths=[
                os.path.expanduser(os.path.expanduser("~/.config/qtile/icons"))
            ],
                                     padding=0,
                                     scale=0.7),
            widget.CurrentLayout(padding=5),
            widget.Clock(format='%A, %B %d [%H:%M]'),
        ],
        opacity=0.65,
        size=30,
        margin=8))  # our bar is (xx)px high
]


@hook.subscribe.client_new
def dialogs(window):
    if (window.window.get_wm_type() == 'dialog'
            or window.window.get_wm_transient_for()):
        window.floating = True


@hook.subscribe.client_new
def idle_dialogues(window):
    if ((window.window.get_name() == 'Search Dialog')
            or (window.window.get_name() == 'Module')
            or (window.window.get_name() == 'Goto')
            or (window.window.get_name() == 'IDLE Preferences')):
        window.floating = True


@hook.subscribe.client_new
def libreoffice_dialogues(window):
    if ((window.window.get_wm_class() == ('VCLSalFrame', 'libreoffice-calc'))
            or
        (window.window.get_wm_class() == ('VCLSalFrame', 'LibreOffice 3.4'))):
        window.floating = True


@hook.subscribe.client_new
def inkscape_dialogues(window):
    if (window.window.get_name() == 'Sozi'):
        window.floating = True


@hook.subscribe.client_new
def inkscape_dialogues(window):
    if ((window.window.get_name() == 'Create new database')):
        window.floating = True


# Super_L (the Windows key) is typically bound to mod4 by default, so we use
# that here.
mod = "mod4"
alt = "mod1"
myTerm = "alacritty"
keys = [
    ##ALT--USED FOR NAV
    ##########USING  ALT###############
    #Reserved for changing layouts
    Key([alt], "q", lazy.window.kill()),
    Key([alt], "o", lazy.spawncmd()),
    Key([alt],
        "j",
        lazy.layout.up(),
        desc='Move focus up in current stack pane'),
    Key([alt],
        "h",
        lazy.layout.grow(),
        lazy.layout.increase_nmaster(),
        desc='Expand window (MonadTall), increase number in master pane (Tile)'
        ),
    Key([alt],
        "l",
        lazy.layout.shrink(),
        lazy.layout.decrease_nmaster(),
        desc='Shrink window (MonadTall), decrease number in master pane (Tile)'
        ),
    Key([alt],
        "n",
        lazy.layout.normalize(),
        desc='normalize window size ratios'),
    Key([alt],
        "m",
        lazy.layout.maximize(),
        desc='toggle window between minimum and maximum sizes'),
    Key([alt],
        "k",
        lazy.layout.down(),
        desc='Move focus down in current stack pane'),
    Key([alt], "Return", lazy.spawn(myTerm)),
    Key([alt], "c", lazy.spawn(scriptPath + "/compton-toggle.sh")),
    ##########USING  ALT SIMBOL###############
    Key([alt, "control"],
        "f",
        lazy.window.toggle_floating(),
        desc='toggle floating'),
    Key([alt, "control"],
        "k",
        lazy.layout.shuffle_down(),
        desc='Move windows down in current stack'),
    Key([alt, "control"],
        "j",
        lazy.layout.shuffle_up(),
        desc='Move windows up in current stack'),
    Key([alt, "control"],
        "space",
        lazy.layout.rotate(),
        lazy.layout.flip(),
        desc='Switch which side main pane occupies (XmonadTall)'),
    Key([alt],
        "space",
        lazy.layout.next(),
        desc='Switch window focus to other pane(s) of stack'),
    Key([alt], "Tab", lazy.next_layout()),
    ##MOD-- APPS PROCESS
    ##########USING  MOD ###############
    ##########USING  MOD SYMBOL###############
    Key([mod, "shift"], "q", lazy.shutdown()),
    Key([mod, "shift"], "r", lazy.restart()),
    #Layout related
    ###Window  controls
    Key([mod, "control"],
        "Return",
        lazy.layout.toggle_split(),
        desc='Toggle between split and unsplit sides of stack'),
    # start specific apps
    Key([mod], "b", lazy.spawn("brave")),

    # System  keys
    Key([], "XF86AudioRaiseVolume",
        lazy.spawn("amixer -c 0 -q set Master 2dB+")),
    Key([], "XF86AudioLowerVolume",
        lazy.spawn("amixer -c 0 -q set Master 2dB-")),
    Key([], "XF86AudioMute", lazy.spawn("amixer -c 0 -q set Master toggle")),

    #bash scripts
]

# This allows you to drag windows around with the mouse if you want.
mouse = [
    Drag([mod],
         "Button1",
         lazy.window.set_position_floating(),
         start=lazy.window.get_position()),
    Drag([mod],
         "Button3",
         lazy.window.set_size_floating(),
         start=lazy.window.get_size()),
    Click([mod], "Button2", lazy.window.bring_to_front())
]

# Next, we specify group names, and use the group name list to generate an appropriate
# set of bindings for group switching.
# TODO: Learn python to refacto this ugly  code and  make  the  group keys and names run on single  for single data structure instead of separeted
group_names = [("WEB", {
    'layout': 'monadtall'
}), ("FRN", {
    'layout': 'monadtall'
}), ("BCK", {
    'layout': 'monadtall'
}), ("TST", {
    'layout': 'monadtall'
}), ("GIT", {
    'layout': 'monadtall'
}), ("DOC", {
    'layout': 'monadtall'
}), ("EXT", {
    'layout': 'monadtall'
})]
group_keys = ["w", "f", "b", "t", "g", "d", "e"]
groups = [Group(name, **kwargs) for name, kwargs in group_names]

for i, (name, kwargs) in enumerate(group_names, 1):
    keys.append(Key([alt], group_keys[i - 1],
                    lazy.group[name].toscreen()))  # Switch to another group
    keys.append(
        Key([alt, "shift"], group_keys[i - 1], lazy.window.togroup(name)))

layout_theme = {
    "border_width": 1,
    "margin": 8,
    "border_focus": "fbf1c7",
    "border_normal": "3c3836"
}
layouts = [
    layout.Stack(**layout_theme),
    layout.MonadTall(**layout_theme),
    layout.Max(**layout_theme),
]

main = None
follow_mouse_focus = True

import subprocess, re


def is_running(process):
    s = subprocess.Popen(["ps", "axuw"], stdout=subprocess.PIPE)
    for x in s.stdout:
        if re.search(process, x):
            return True
    return False


def execute_once(process):
    if not is_running(process):
        return subprocess.Popen(process.split())


# start the applications at Qtile startup
@hook.subscribe.startup
def startup():
    rc_dir = "/home/arkchar/.config/wmStartupScripts/"
    subprocess.Popen("sleep 3".split())
    execute_once("nm-applet")
    execute_once("synergys")
    execute_once("xcompmgr")
    execute_once(rc_dir + "xmodmap.py")
    execute_once("ibus-daemon --xim")
    execute_once("hsetroot -tile /home/arkchar/Pictures/desktop.jpg")
    execute_once(rc_dir + "trackpoint.sh")
    execute_once("xsetroot -cursor_name left_ptr")
    execute_once(scriptPath + "compton-toggle.sh")
    # execute_once("xset m 4 0")
