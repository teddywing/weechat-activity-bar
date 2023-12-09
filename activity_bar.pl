use strict;
use warnings;

use IO::Socket::INET;

weechat::register(
	'activity_bar',
	'Teddy Wing',
	'1.0',
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


weechat::hook_print('', '', '', 0, 'print_cb', '');

sub print_cb {
	my ($data, $buffer, $date, $tags, $displayed, $highlight, $prefix, $message) = @_;

	my $buffer_type = weechat::buffer_get_string($buffer, 'localvar_type');

	if ($buffer_type eq 'private') {
		anybar_send('blue');
	}
	elsif ($highlight == 1) {
		anybar_send('purple');
	}
	else {
		anybar_send('orange');
	}

	return weechat::WEECHAT_RC_OK;
}

sub anybar_send {
	my ($message) = @_;

	$socket->send($message);
}
