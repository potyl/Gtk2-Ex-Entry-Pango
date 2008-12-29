#!/usr/bin/perl

use strict;
use warnings;
use 5.006000;

use ExtUtils::MakeMaker;

# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME              => 'Gtk2::Ex::Entry::Pango',
    VERSION_FROM      => 'lib/Gtk2/Ex/Entry/Pango.pm', # finds $VERSION
    PREREQ_PM         => {}, # e.g., Module::Name => 1.1
    ($] >= 5.005 ?     ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM  => 'lib/Gtk2/Ex/Entry/Pango.pm', # retrieve abstract from module
       AUTHOR         => 'Emmanuel Rodriguez <potyl@cpan.org>') : ()),
);
