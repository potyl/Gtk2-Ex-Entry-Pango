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

Keep in mind that a C<Gtk2::Entry> is a simple widget that doesn't support
advanced text editing and that the markup styles are ephemeral. This means that
if the widget's text is set using Pango markup than the rendering styles will
disappear as soon as the users edits the text, even a single key stroke will
suffice. If the markup style has to persist it's up to the caller to do it by
registering a I<changed> signal callback and calling L</set_markup>.

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
use Carp;
use Data::Dumper;

our $DEBUG = 1;
our $VERSION = '0.01';

# See http://gtk2-perl.sourceforge.net/doc/pod/Glib/Object/Subclass.html
use Glib::Object::Subclass 'Gtk2::Entry' =>

	signals => {
		'changed'        => \&callback_changed,
		'expose-event'   => \&callback_expose_event,

		'markup-changed' => {
			flags => ['run-last'],
			param_types => ['Glib::String'],
		}
	},

	properties => [
		Glib::ParamSpec->string(
			'markup',
			'markup',
			'The Pango markup used for displaying the contents of the entry.',
			'',
			['readable', 'writable'],
		),

		Glib::ParamSpec->boolean(
			'internal-change',
			'internal-change',
			'Tells the changed callback if we changed the text.',
			'',
			['readable', 'writable'],
		),

#		Glib::ParamSpec->boxed(
#			'attributes',
#			'attributes',
#			'The Pango markup attributes (rendering styles) to apply to the text.',
#			'Gtk2::Pango::AttrList',
#			['readable', 'writable'],
#		),
	],
;


#
# Gtk2 constructor.
#
sub INIT_INSTANCE {
	my $self = shift;

	# The Pango attributes to apply to the text. If set to undef then there are no
	# attributes and the text is rendered normally.
	#$self->{attributes} = undef;
}


#
# Gtk2 generic property setter.
#
sub SET_PROPERTY {
	my ($self, $pspec, $value) = @_;
	
	my $field = $pspec->get_name;
warn ">>>>>>>>> $field = $value";
	$self->{$field} = $value;

	if ($field eq 'markup') {
		# The widget doesn't need to keep the value of the markup, just to parse it
		warn "$self Generic set $field = $value" if $DEBUG;
		$self->_set_markup($value, 1);
	}
}



=head2 set_markup

Sets the text of the entry using Pango markup.

Parameters:

=over

=item * $markup

The text to add to the entry, the text is expected to be using Pango markup.
This means that even if no markup is used special characters like E<lt>, E<gt>,
&, ' and " need to be escaped. Keep in mind that Pango markup is a subset of
XML.

You might want to use the following code snippet for escaping the characters:

	use Glib::Markup qw(escape_text);
	$entry->set_markup(
		sprintf "The <i>%s</i> <b>%s</b> fox <sup>%s</sup> over the lazy dog",
			map { escape_text($_) } ('quick', 'brown', 'jumps')
	);

=back	

=cut

sub set_markup {
	my $self = shift;
	my ($markup) = @_;
	warn "$self Called set_markup($markup)" if $DEBUG;
	$self->set(markup => $markup);
}


#
# The actual setter for the property 'markup'. The markup string is parsed into
# a text to be displayed an attribute list (the styles to apply). The text is
# added normally to the widget as if it was a Gtk2::Entry, while the attributes
# are stored in order to be latter applied each time that the widget is
# rendered.
#
# The actual Pango markup string doesn't need to be stored by this widget and is
# discarded.
#
sub _set_markup {
	my $self = shift;
	my ($markup, $set_text) = @_;

	# Parse the markup, this will die if the markup is invalid
	my ($attributes, $text);
	eval {
		my $pango = defined $markup ? $markup : '';
		($attributes, $text) = Gtk2::Pango->parse_markup($pango);
	};
	if ($@) {
		warn "$self Failed to parse the markup $markup because $@" if $DEBUG;
		croak $@;	
	}

	# Change the internal text (we tell our selves that we are doing it)
#	$self->signal_stop_emission_by_name('changed');
	if ($set_text) {
warn "========== Setting internal change to 1";
		$self->set('internal-change' => 1);
		warn "$self Setting the Gtk2::Text to $text" if $DEBUG;
		$self->set_text($text);
#		$self->set('internal-change' => 0);
		warn "--------------returned from set_text";
	}

	# The text region must be invalidate in order to be repainted. This is true
	# even if the same text is the same. Remember that the text in the Pango
	# markup could turn out to be the same text that was previously in the widget
	# but with new styles (this is most common when showing an error with a red
	# underline). In such a case the Gtk2::Entry will not refresh it's appearance
	# because the text didn't change. Here we are forcing the update.
	if ($self->realized) {
		my $size = $self->allocation;
		my $rectangle = Gtk2::Gdk::Rectangle->new(0, 0, $size->width, $size->height);
		$self->window->invalidate_rect($rectangle, TRUE);
	}

	# Tell the others that the markup has changed	
	$self->signal_emit('markup-changed'=> $markup);
}



#
# Called when the text of the entry is changed. The callback is used for monitor
# when the user resets the text of the widget without markup. In that case we
# need to erase the markup.
#
sub callback_changed {
	my $self = shift;

	my $internal_change = $self->get('internal-change');
warn "========$self Changed called is internal change? ", $internal_change ? 'TRUE' : 'FALSE' if $DEBUG;

	if (! $internal_change) {
		# The text was changed as if it was a normal Gtk2::Entry either through
		# $widget->set_text($text) or $widget->set(text => $text). This means that
		# the markup style has to be removed from the widget. Now the widget will
		# rendered in plain text without any styles.
		#$self->set_attributes(undef);		
		#delete $self->{attributes};
		warn "Erasing markup";
#		$self->set('internal-change' => 0);
		$self->{markup} = undef;
warn "===========MARKUP is removed";
		if ($self->realized) {
			my $size = $self->allocation;
			my $rectangle = Gtk2::Gdk::Rectangle->new(0, 0, $size->width, $size->height);
			$self->window->invalidate_rect($rectangle, TRUE);
		}

		# Tell the others that the markup has changed	
		$self->signal_emit('markup-changed'=> undef);
	}
	$self->set('internal-change' => 0);

	$self->signal_chain_from_overridden(@_);
}



#
# Called each time that the widget needs to be rendered. This happens quite
# often as the cursor is blinking. Without this callback the Pango style would
# be lost randomly.
#
sub callback_expose_event {
	my $self = shift;
	my ($event) = @_;
	
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
	warn "$self Expose event using pango? ", $self->{markup} ? 'YES' : 'NO' if $DEBUG;
#	if (my $attributes = $self->get_attributes) {
#		$self->get_layout->set_attributes($attributes);
#	}

if ($self->{markup}) {
	my ($attributes, $text) = Gtk2::Pango->parse_markup($self->{markup});
	warn "setting layout attributes";
	$self->set_text($text);
	$self->get_layout->set_attributes($attributes);
}

	$self->signal_chain_from_overridden(@_);
}



# Return a true value
1;

=head1 PROPERTIES

The following properties are added by this widget:

=head2 markup

(string: writable)

The markup text used by this widget. This property is a string that's only
writable. That's right there's no way for extracting the markup from the widget.

=head1 SIGNALS

=head2 markup-changed

Emitted when the markup has been changed.

Signature:

	sub markup_changed {
		my ($widget, $markup) = @_;
		# Returns nothing
	}

Parameters:

=over

=item * $markup

The new markup that's been applied. This field is a normal Perl string. If
C<$markup> is C<undef> then the markup was removed.

=back	

=head1 SEE ALSO

Take a look at the examples for getting some ideas or inspiration. For a more
powerful text widget take a look at L<Gtk2::TextView>.

=head1 AUTHORS

Emmanuel Rodriguez E<lt>potyl@cpan.orgE<gt>.

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2008 by Emmanuel Rodriguez.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.8 or,
at your option, any later version of Perl 5 you may have available.

=cut
