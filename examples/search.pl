#!/usr/bin/perl

=head1 NAME

search.pl - Simple search text entry.

=head1 DESCRIPTION

This sample program tries to make a search text entry. This is a text field that
has some default text in the beginning in the background. This default text gets
erased as soon as the user enters input and as far as the text widget is
concerned this text doesn't exist.

=cut

use strict;
use warnings;

use Glib qw(TRUE FALSE);
use Gtk2 '-init';
use Gtk2::Ex::Entry::Pango;

exit main();


sub main {

	my $entry = create_widgets();
	$entry->set_empty_markup("<span color='grey' size='smaller'>Search...</span>");

	Gtk2->main();

	return 0;
}


sub create_widgets {
	my $window = Gtk2::Window->new();
	my $entry = Gtk2::Ex::Entry::Pango->new();

	$window->add($entry);
	
	$window->signal_connect(delete_event => sub {
		Gtk2->main_quit();
	});
	
	$window->show_all();

	return $entry;
}

