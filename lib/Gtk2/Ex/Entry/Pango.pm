package Gtk2::Ex::Entry::Pango;

=head1 NAME

Gtk2::Ex::Entry::Pango - Gtk2 Entry that accepts Pango markup.

=head1 SYNOPSIS

	use Gtk2 qw(-init);
	use Glib qw(TRUE FALSE);
	use Gtk2::Ex::Entry::Pango;
	
	my $window = Gtk2::Window->new();
	my $entry = Gtk2::Ex::Entry::Pango->new();
	
	# You can use any method defined in Gtk2::Entry or set_markup()
	$entry->set_markup('<span style="italic">Pango markup</span> is easy');
	
	my $vbox = new Gtk2::VBox(FALSE, 0);
	$vbox->pack_start($entry, FALSE, FALSE, FALSE);
	$vbox->set_focus_child($entry);
	$window->add($vbox);
	
	$window->signal_connect(delete_event => sub { Gtk2->main_quit(); });
	
	$window->show_all();
	Gtk2->main();

=head1 HIERARCHY

C<Gtk2::Ex::Entry::Pango> is a subclass of L<Gtk2::Entry>.

	Glib::Object
	+----Glib::InitiallyUnowned
	     +----Gtk2::Object
	          +----Gtk2::Widget
	               +----Gtk2::Entry
	                    +----Gtk2::Ex::Entry::Pango


=head1 DESCRIPTION

C<Gtk2::Ex::Entry::Pango> is a L<Gtk2::Entry> that can accept Pango markup as
input (for more information about Pango text markup language see 
L<http://library.gnome.org/devel/pango/stable/PangoMarkupFormat.html>).

=head1 INTERFACES

	Glib::Object::_Unregistered::AtkImplementorIface
	Gtk2::Buildable
	Gtk2::CellEditable
	Gtk2::Editable

=head1 METHODS

The following methods are added by this widget:

=head2 new

Creates a new instance.

=cut


use strict;
use warnings;

use Glib qw(TRUE FALSE);
use Gtk2;
use Data::Dumper;

our $VERSION = '0.01';

# See http://gtk2-perl.sourceforge.net/doc/pod/Glib/Object/Subclass.html
use Glib::Object::Subclass 'Gtk2::Entry' =>

	signals => {
		changed      => \&callback_changed,
		expose_event => \&callback_expose_event,
	},

	properties => [
		Glib::ParamSpec->string(
			'markup',
			'markup',
			'The Pango markup used for displaying the contents of entry.',
			'',
			Glib::G_PARAM_READWRITE
		),
	],
;



=head2 set_markup

Sets the text of the entry .
Parses str which is marked up with the Pango text markup language, setting the label's text and attribute list based on the parse results. If the str is external data, you may need to escape it with g_markup_escape_text() or g_markup_printf_escaped(): 

Parameters:

=over

=item * $markup

The text to add to the entry, the text is expecte to be using Pango markup. This
means that even if no markup is used special characters like 'E<lt>','E<gt>' and
&, ' and " need to be escaped. Keep in mind that Pango markup is a subset of
XML.

You might want to use the following code snipet for escaping the characters:

	use Glib::Markup qw(escape_text);
	$entry->set_markup(
		sprintf "The <i>%s</i> <b>%s</b> fox <sup>jumps</sup> over the lazy dog",
			map { escape_text($_) } ('quick', 'brown')
	);

=back	

=cut

sub set_markup {
	my $self = shift;
	my ($markup) = @_;
	$self->set(markup => $markup);
}


sub SET_PROPERTY {
	my ($self, $pspec, $newval) = @_;
	
	my $field = $pspec->get_name;
	my $oldval = $self->{$field} || '';
printf "Setting %s = %s\n", $field, $newval;
	$self->{$field} = $newval;  # per default GET_PROPERTY

	if ($field eq 'markup') {
print "Changed field markup\n";
		#  Tell the callback_changed event that the text was changed
		$self->{changed} = 1;
print "Calling changed\n";
#		$self->signal_emit('changed');
print "Called changed\n";
	}
	else {
		delete $self->{changed};
	}
#	if ($oldval ne $newval) {
#		$self->set_text($newval);
#	}
}



sub callback_changed {
	my $self = shift;

printf "Callback changed called (changed? %s)\n", $self->{changed} ? 'TRUE' : 'FALSE';
	if ($self->{changed}) {
		$self->apply_markup();
	}
	else {
		# The text was changed without using markup, this means that
		# $self->set_text() was called.
		delete $self->{markup};
	}
	delete $self->{changed};

	
	if ($self->realized) {
		my $size = $self->allocation;
		my $rectangle = Gtk2::Gdk::Rectangle->new(0, 0, $size->width, $size->height);
		$self->window->invalidate_rect($rectangle, TRUE);
	}

	$self->signal_chain_from_overridden(@_);
}



sub callback_expose_event {
	my $self = shift;
	my ($event) = @_;
	
	$self->apply_markup();
	$self->signal_chain_from_overridden(@_);
}


#
# Applies the Pango markup if a markup was set. Returns TRUE if the markup was
# applied FALSE otherwise.
#
sub apply_markup {
	my $self = shift;

	my $markup = $self->{markup};
	return FALSE unless defined $markup;
	$self->debug();
	
	# FIXME this doesn't seem to be enough. The problem is that if the markup
	#       changes the width of the string there will be big problems. The string
	#       will be rendered properly but the entry will not have the right data!
	
	#       Instead try to do $self->set_text($text) and $self->layout->set_attributes().
	#       Use the following function: ($attr_list, $text, $accel_char) = Gtk2::Pango->parse_markup ($markup_text, $accel_marker)
	#       See: http://gtk2-perl.sourceforge.net/doc/pod/Gtk2/Pango/AttrList.html#_attr_list_text_acce
	
	$self->get_layout->set_markup($markup);
	return TRUE;
}


sub debug {
	my $self = shift;

	my $markup = $self->get('markup');
	printf "Markup is %s\n", defined $markup ? "'$markup'" : "undef";
	printf "Text   is '%s'\n", $self->get_text;
	print "\n";
}


# Return a true value
1;

=head1 PROPERTIES

The following properties are added by this widget:

=head2 markup

The markup text used by this widget.

(string : readable / writable / private)

=head1 AUTHORS

Emmanuel Rodriguez E<lt>potyl@cpan.orgE<gt>.

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2008 by Emmanuel Rodriguez.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.8 or,
at your option, any later version of Perl 5 you may have available.

=cut
