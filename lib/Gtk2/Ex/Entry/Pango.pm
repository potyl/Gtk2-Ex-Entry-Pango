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
			'The Pango markup used for displaying the contents of the entry.',
			'',
			Glib::G_PARAM_READWRITE
		),
	],
;



=head2 set_markup

Sets the text of the entry .
Parses str which is marked up with the Pango text markup language, setting the
label's text and attribute list based on the parse results. If the string has
external data, you may need to escape it with g_markup_escape_text() or 
g_markup_printf_escaped(): 

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
	$self->{$field} = $newval;

	if ($field eq 'markup') {
		$self->apply_markup();
	}

#	if ($oldval ne $newval) {
#		$self->set_text($newval);
#	}
}



sub callback_changed {
	my $self = shift;

	if (! $self->{internal_change}) {
		# The text was changed as if it was a normal Gtk2::Entry through set_text()
		# or set(text => $text). This means that we have to remove the markup code.
		# Now the widget will render a plain text string.
		delete $self->{markup};
	}

	$self->signal_chain_from_overridden(@_);
}


#
# Called each time that the widget needs to be rendered. This happens quite
# often as the cursor is blinking. Without this callback the Pango style would
# be lost randonly.
#
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
	
	# Calling $self->get_layout->set_markup($markup); is not enough. For instance,
	# if the text within the markup differs from the actual text in the
	# Gtk2::Entry and changes in width there will be some problems. Sure the
	# entry's text will be rendered properly but the entry will not have the right
	# data within it's buffer. This means that $self->get_text() will still return
	# the old text even though the widget displays the new string. Furthermore,
	# the widget will fail to edit text because the cursor could be placed at a
	# position that's further than the actual data in the widget.
	#
	# To solve this problem the new text has to be added to the entry and the
	# style has to be applied afterwards.
	#

	# FIXME parse the markup is the setter. Catch the exception there.
	my ($attributes, $text) = Gtk2::Pango->parse_markup($markup);

	local $self->{internal_change} = 1;
	$self->set_text($text);
	$self->get_layout->set_attributes($attributes);
	
	#$self->get_layout->set_markup($markup);
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
