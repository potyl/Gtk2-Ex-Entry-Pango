#!/usr/bin/perl

use strict;
use warnings;

use Glib qw(TRUE FALSE);
use Gtk2 '-init';
use Gtk2::Ex::Entry::Pango;


exit main();


sub main {

	my $window = Gtk2::Window->new();
	my $entry = Gtk2::Ex::Entry::Pango->new();
	
	my $vbox = new Gtk2::VBox(FALSE, 0);
	$vbox->pack_start($entry, FALSE, FALSE, FALSE);
	$vbox->set_focus_child($entry);
	$window->add($vbox);
	
	# Use pango markup
	$entry->set_markup(
		'<span style="italic">Pango markup</span> is <span underline="error" underline_color="red">NOT</span> hard'
	);
	
	$window->signal_connect(delete_event => sub { Gtk2->main_quit(); });
	
	$window->show_all();
	Gtk2->main();

	return 0;
}
