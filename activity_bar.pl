# Copyright (c) 2023  Teddy Wing
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <https://www.gnu.org/licenses/>.


use strict;
use warnings;

use IO::Socket::INET;

weechat::register(
	'activity_bar',
	'Teddy Wing',
	'1.1',
	'GPL-3.0-or-later',
	'Monitor activity in all buffers and update AnyBar',
	'shutdown',
	''
);

# Flush socket immediately.
$| = 1;

my $socket = IO::Socket::INET->new(
	PeerAddr => 'localhost',
	PeerPort => '1738',
	Proto => 'udp',
) or die "error: can't create socket: $!";

sub shutdown {
	$socket->close();
}


# Map colours to priority levels. Higher number is higher priority.
my %color_priorities = (
	'hollow' => 0,
	'blue' => 1,
	'purple' => 2,
	'orange' => 3,
);

# Store the most recent colour set to AnyBar. Default to 'hollow'.
my $anybar_last_color = 'hollow';

my $print_hook = weechat::hook_print('', '', '', 0, 'print_cb', '');
weechat::hook_command(
	'activity_bar',
	'Activity Bar commands',
	'[clear] | [enable|disable]',
	'To disable activity notifications when WeeChat is focused, turn on terminal focus events:

    /set weechat.startup.command_after_plugins "/print -stdout \033[?1004h\n"
    /trigger add reset_focus signal "quit" "" "" "/print -stdout \033[?1004l\n"

Then disable activity_bar on focus, and enable it on unfocus:

    /key bind meta2-I /activity_bar disable
    /key bind meta2-O /activity_bar enable

  clear: change AnyBar icon to hollow
 enable: enable activity notification
disable: clear the AnyBar icon and disable activity notification',
	'clear
		 || enable
		 || disable',
	'activity_bar_command_cb',
	''
);

sub print_cb {
	my ($data, $buffer, $date, $tags, $displayed, $highlight, $prefix, $message) = @_;

	my $buffer_type = weechat::buffer_get_string($buffer, 'localvar_type');
	my $buffer_notify = weechat::buffer_get_integer($buffer, 'notify');

	if ($buffer_type eq 'private') {
		anybar_send('orange');
	}
	elsif ($highlight == 1) {
		anybar_send('purple');
	}

	# Notify about regular messages if the buffer's `notify` property allows it.
	elsif ($buffer_notify > 1) {
		anybar_send('blue');
	}

	return weechat::WEECHAT_RC_OK;
}

sub anybar_send {
	my ($message) = @_;

	if (
		$message ne 'hollow'

		# If the current priority is lower than the previous colour.
		&& $color_priorities{$message} < $color_priorities{$anybar_last_color}
	) {
		return;
	}

	$anybar_last_color = $message;

	$socket->send($message);
}

sub activity_bar_command_cb {
	my ($data, $buffer, $args) = @_;

	if ($args eq 'clear') {
		anybar_send('hollow');
	}
	if ($args eq 'disable') {
		anybar_send('hollow');
		weechat::unhook($print_hook);
		$print_hook = undef;
	}
	if ($args eq 'enable' && !$print_hook) {
		$print_hook = weechat::hook_print('', '', '', 0, 'print_cb', '');
	}

	return weechat::WEECHAT_RC_OK;
}
