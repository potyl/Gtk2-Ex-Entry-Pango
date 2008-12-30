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

	my $markup = Gtk2::Entry->new();
	
	my $button_print = Gtk2::Button->new('Print');
	my $button_markup = Gtk2::Button->new('Markup');
	my $button_apply = Gtk2::Button->new('Aply');
	
	my $hbox_top = new Gtk2::HBox(FALSE, 0);
	$hbox_top->pack_start($entry, TRUE, TRUE, 0);
	$hbox_top->pack_start($button_print, FALSE, FALSE, 0);
	$hbox_top->pack_start($button_markup, FALSE, FALSE, 0);
	
	my $hbox_bottom = new Gtk2::HBox(FALSE, 0);
	$hbox_bottom->pack_start($markup, TRUE, TRUE, 0);
	$hbox_bottom->pack_start($button_apply, FALSE, FALSE, 0);


	my $vbox = new Gtk2::VBox(FALSE, 0);
	$vbox->pack_start($hbox_top,    TRUE, TRUE, 0);
	$vbox->pack_start($hbox_bottom, TRUE, TRUE, 0);

	$window->add($vbox);
	
	# Use pango markup
	$entry->set_markup(
		'<span style="italic">Pango markup</span> is <span underline="error" underline_color="red">NOT</span> hard'
	);
	

	# Connect the signals
	$window->signal_connect(delete_event => sub { Gtk2->main_quit(); });

	$button_print->signal_connect(clicked => sub {
		$entry->debug();
	});

	$button_markup->signal_connect(clicked => sub {
		$entry->set(
			markup => '<b>smaller</b> text'
		);
	});


	# Apply the user's Pango text
	$button_apply->signal_connect(clicked => sub {
		$markup->signal_emit('activate');
	});
	$markup->signal_connect(activate => sub {
		$entry->set_markup($markup->get_text);
	});

	
	$window->set_default_size(850, -1);
	$window->show_all();
	Gtk2->main();

	return 0;
}
