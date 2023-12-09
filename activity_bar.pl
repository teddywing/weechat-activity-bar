use strict;
use warnings;

weechat::register(
	'activity_bar',
	'Teddy Wing',
	'1.0',
	'GPL-3.0-or-later',
	'Monitor activity in all buffers and update AnyBar',
	'',
	''
);

weechat::hook_print('', '', '', 0, 'print_cb', '');

sub print_cb {
	my ($data, $buffer, $date, $tags, $displayed, $highlight, $prefix, $message) = @_;

	my $buffer_type = weechat::buffer_get_string($buffer, 'localvar_type');
	my $buffer_name = weechat::buffer_get_string($buffer, 'short_name');

	if ($buffer_type eq 'private') {
		weechat::print('', "Private message in $buffer_name: $message");
	}
	elsif ($highlight == 1) {
		weechat::print('', "Highlight in $buffer_name: $message");
	}
	else {
		weechat::print('', "Message in $buffer_name: $message");
	}

	return weechat::WEECHAT_RC_OK;
}
