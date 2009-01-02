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
use Data::Dumper;


exit main();


sub main {

	my $entry = create_widgets();

	# Cancel the text selection when there's no text in the widget
	$entry->signal_connect('button-press-event' => \&on_button_press);

	# Set the default markup each time that the window is redrawn. The Pango
	# styles are quite volatile so we need to reset them after each redraw.
	# Setting the Pango markup on the 'changed' event is not enough as a resize
	# will lose the markup. The 'expose-event' is a better place.
	$entry->signal_connect(expose_event => \&on_expose);

	Gtk2->main();

	return 0;
}


sub on_expose {
	my ($widget) = @_;
	if ($widget->get_text eq "") {
		$widget->get_layout->set_markup("<span color='grey'>Search...</span>");
	}
}


sub on_button_press {
	my ($widget, $event) = @_;
	
	# This handler stops the widget from generating critical Pango warnings when
	# the text selection gesture is performed. If there's no text in the widget we
	# simply cancel the gesture.
	#
	# The gesture is done with: mouse button 1 pressed and dragged over the widget
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
	
	$window->signal_connect(delete_event => sub {
		Gtk2->main_quit();
	});
	
	$window->show_all();

	return $entry;
}

