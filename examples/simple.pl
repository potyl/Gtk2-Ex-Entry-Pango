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
	
	my $button = Gtk2::Button->new('Action');
	
	my $box = new Gtk2::HBox(FALSE, 0);
	$box->pack_start($entry, TRUE, TRUE, 0);
	$box->pack_start($button, FALSE, FALSE, 0);
	$window->add($box);
	
	# Use pango markup
	$entry->set_markup(
		'<span style="italic">Pango markup</span> is <span underline="error" underline_color="red">NOT</span> hard'
	);
	$entry->set(
		markup => '<b>smaller</b> text'
	);
	
	$window->signal_connect(delete_event => sub { Gtk2->main_quit(); });
	$button->signal_connect(clicked => sub {
		printf "Markup is %s\n", $entry->get('markup');
	});
	
	$window->set_default_size(850, -1);
	$window->show_all();
	Gtk2->main();

	return 0;
}
