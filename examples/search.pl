#!/usr/bin/perl

=head1 NAME

test.pl - Try to make a search text entry

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
use Data::Dumper;


exit main();


sub main {

	my $entry = create_widgets();

	# Display the widget's default markup when the widget is empty. Needs to be
	# done each time time that there's a change or that the widget is rendered.
	$entry->signal_connect('button-press-event' => \&set_default_markup);
	$entry->signal_connect(changed => \&set_default_markup);

	# Each time that the window is redrawn we might need to add the default text.
	# The Pango styles are quite volatile so we need to reset them.
	$entry->signal_connect(expose_event => \&set_default_markup);

	Gtk2->main();

	return 0;
}



sub set_default_markup {
	my ($widget) = @_;
	if ($widget->get_text eq "") {
		$widget->get_layout->set_markup("<span color='grey'>Search...</span>");
	}
}



sub on_button_press {
	my ($widget, $event) = @_;
	
	# This handler stops the widget from generating critical Pango warnings when
	# the text selection gesture is performed on the widget. If there's no text in
	# the widget we simply cancel the gesture.
	#
	# The gesture is done with: mouse button 1 pressed and draged over the widget
	# while the button is still pressed.
	if ($widget->get_text eq "") {
		$widget->grab_focus();
		return TRUE;
	}
	
	return FALSE;
}


sub create_widgets {
	my $window = Gtk2::Window->new();
	my $entry = Gtk2::Entry->new();

	$window->add($entry);
	
	$window->signal_connect(delete_event => sub { Gtk2->main_quit(); });
	
	$window->show_all();

	return $entry;
}
