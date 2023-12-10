weechat-activity-bar
====================

A [WeeChat] plugin that changes the [AnyBar] menu bar colour when there is
activity in buffers. This allows you to see when there are new messages when
WeeChat is not in the foreground.


[WeeChat]: https://weechat.org/
[AnyBar]: https://github.com/tonsky/AnyBar


## Install
Download [activity_bar.pl] and place it in WeeChat’s “perl” script directory.

To disable activity notifications when WeeChat is focused, turn on terminal
focus events:

    /set weechat.startup.command_after_plugins "/print -stdout \033[?1004h\n"

    # https://www.chunkhang.com/blog/fixing-focus-events-in-weechat
    /trigger add reset_focus signal "quit" "" "" "/print -stdout \033[?1004l\n"

Then disable activity_bar on focus, and enable it on unfocus:

    /key bind meta2-I /activity_bar disable
    /key bind meta2-O /activity_bar enable


[activity_bar.pl]: https://raw.githubusercontent.com/teddywing/weechat-activity-bar/master/activity_bar.pl


## License
Copyright © 2023 Teddy Wing. Licensed under the GNU GPLv3+ (see the included
COPYING file).
