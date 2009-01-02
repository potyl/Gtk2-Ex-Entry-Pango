#!/usr/bin/perl

use strict;
use warnings;

use Gtk2::TestHelper tests => 20;

BEGIN {
	use_ok('Gtk2::Ex::Entry::Pango')
};


my $MARKUP_VOID = -1;
my $MAX_INT = 0;


exit main();


sub main {


	my $entry = Gtk2::Ex::Entry::Pango->new();
	
	# The styles always end at MAX INT and not at the lenght of the string. This
	# code find the maximum size that a style can have.
	$MAX_INT = get_styles($entry)->[0][1];
	ok($MAX_INT > 0);


	# Intercept all markup changes. $MARKUP_VOID indicates that the callback
	# wasn't called.
	my $markup_signal = $MARKUP_VOID;
	$entry->signal_connect(markup_changed => sub{
		my ($widget, $markup) = @_;
		$markup_signal = $markup;
	});
	
	
	# Use some markup	
	$markup_signal = $MARKUP_VOID;
	$entry->set_markup("<b>markup</b>");
	is($entry->get_text(), "markup");
	is($markup_signal, "<b>markup</b>");
	is_deeply(
		get_styles($entry),
		[
			[0, 6, 'bold'],
			[6, $MAX_INT, undef],
		]
	);
	
	
	# Use some markup	with the same text but the styles are different
	$markup_signal = $MARKUP_VOID;
	$entry->set_markup("m<b>a</b>rk<b>u</b>p");
	is($entry->get_text(), "markup");
	is($markup_signal, "m<b>a</b>rk<b>u</b>p");
	is_deeply(
		get_styles($entry),
		[
			[0, 1, undef],
			[1, 2, 'bold'],
			[2, 4, undef],
			[4, 5, 'bold'],
			[5, $MAX_INT, undef],
		]
	);
	
	
	# Try to remove the markup of the same input text.
	# NOTE: this fails as set_text() doesn't detect a text difference.
	$markup_signal = $MARKUP_VOID;
	$entry->set_text("markup");
	is($entry->get_text(), "markup");
	is($markup_signal, $MARKUP_VOID);
	is_deeply(
		get_styles($entry),
		[
			[0, 1, undef],
			[1, 2, 'bold'],
			[2, 4, undef],
			[4, 5, 'bold'],
			[5, $MAX_INT, undef],
		]
	);
	
	
	
	
	# Reset the text
	$markup_signal = $MARKUP_VOID;
	$entry->set_text("reset");
	is($entry->get_text(), "reset");
	is($markup_signal, undef);
	is_deeply(
		get_styles($entry),
		[
			[0, $MAX_INT, undef],
		]
	);
	
	
	# Use some markup	
	$markup_signal = $MARKUP_VOID;
	$entry->set_markup("<b>markup</b>");
	is($entry->get_text(), "markup");
	is($markup_signal, "<b>markup</b>");
	is_deeply(
		get_styles($entry),
		[
			[0, 6, 'bold'],
			[6, $MAX_INT, undef],
		]
	);
	

	# Clear the markup
	$markup_signal = $MARKUP_VOID;
	$entry->clear_markup();
	is($entry->get_text(), "");
	is($markup_signal, undef);
	is_deeply(
		get_styles($entry),
		[
			[0, $MAX_INT, undef],
		]
	);
}



sub get_styles {
	my ($widget) = @_;

	my @collected = ();
	
	my $iter = $widget->get_layout->get_attributes->get_iterator;
	do {
		my ($start, $end) = $iter->range;
		my $attribute = $iter->get('weight');
		$attribute = defined $attribute ? $attribute->value : undef;
		push @collected, [$start, $end, $attribute];
	} while ($iter->next);
	
	return \@collected;
}

