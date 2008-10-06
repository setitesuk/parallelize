package Parallelize;

use 5.010_000;

use warnings;
use strict;

use version;
use autodie qw(:system :file);

use Cwd;
use File::Spec;

use Moose;
use Moose::Util::TypeConstraints;
use IPC::System::Simple qw(capture);

our $VERSION = qv('0.1.1');

# Module implementation here

# Should create a type constraint on this attribute
subtype 'ExistingFile'
  => as 'Str'
  => where { -e };

has 'files' => (
    is         => 'ro',
    isa        => 'ArrayRef[ExistingFile]',
    required   => 1,
    auto_deref => 1,
);

# File to be passed to bsub - job-array-file
# NOTE: Naming convention here sounds wrong. I want exec[utable]
# to be a user specified (perhaps one you wrote two weeks ago)
# stand-alone script as opposed to the job-array-file.
# In essence, you should either have an executable file (for
# one-liners) or code in a HERE_DOC within a file.
has 'exec' => (
    is      => 'rw',
    default => sub {
        File::Spec->catfile( cwd, '.parallelize' );
    },
);

# Perhaps I should define users-code-file here??

# Need a coersion here to make sub { ... }
# a valid argument to new( code => '' ).
subtype 'Code'
  => as 'Str'
  => where { $_ ne q{} };

coerce 'Code'
  => from 'ArrayRef'
  => via { join q{}, @{ $_ } };

has 'code' => (
    is     => 'ro',
    isa    => 'Code',
    coerce => 1,
    writer => 'set_code',
);

sub BUILD {
    my ( $self, $params ) = @_;

    # Set the code if you have one
    if ( $params->{code} ) {
        $self->set_code( $params->{code} );
    }

    # Write the code to a temporary file ... NEED TO REMOVE AFTERWARDS
    my $code_file = File::Spec->catfile( cwd, '.users-code' );

    open my $code_handle, '>', $code_file;

    print {$code_handle} $self->code();

    # Check that it compiles ...
    # NOTE: Would like to silence the output of this.
    # Perhaps we can use string form of eval?? Would prefer
    # IPC::System::Simple::capture() for this.
    my $output = capture("perl -c $code_file");
    if ( $output =~ m/\A \w+ syntax ok \z/xms ) {
	confess "Your code does not compile: ($output)";
    }

    # Execute the commands on each file
    open my $exec_handle, '>', $self->exec();

    for my $file ( $self->files ) {
        say {$exec_handle} "perl $code_file $file";
    }

    close($_) for $exec_handle, $code_handle;

    # Now submit the jobs to the farm as a job array
    # NOTE:
    # Here's where the bsubs will be. Perhaps this should be
    # a separate function Parallelize::run() or something like
    # that? Ps: Only cat seems to work here ... source doesn't.
    system( 'cat', $self->exec );

    return $self;
}

# NOTE:
# Don't forget to remove the files created when everything's
# finished. Perhaps you can try File::Temp again with UNLINK
# set to true.

__PACKAGE__->meta->make_immutable;

no Moose;

1;    # Magic true value required at end of module

__END__

=head1 NAME

Parallelize - [One line description of module's purpose here]


=head1 VERSION

This document describes Parallelize version 0.0.1


=head1 SYNOPSIS

    use Parallelize;

    my $data = [qw(A B C)];
    my $code = <<'END_CODE';
    #! /usr/bin/env perl
    use 5.010;
    say 'This is a test: ', shift;
    exit 0;
    END_CODE

    my $parallelize = Parallelize->new(
        data => $data,
        code => $code,   # ideally [<DATA>]
        exec => $script, # preferably ...
    );

    exit 0;

=head1 DESCRIPTION

=for author to fill in:
    Write a full description of the module and its features here.
    Use subsections (=head2, =head3) as appropriate.


=head1 INTERFACE 

=for author to fill in:
    Write a separate section listing the public components of the modules
    interface. These normally consist of either subroutines that may be
    exported, or methods that may be called on objects belonging to the
    classes provided by the module.


=head1 DIAGNOSTICS

=for author to fill in:
    List every single error and warning message that the module can
    generate (even the ones that will "never happen"), with a full
    explanation of each problem, one or more likely causes, and any
    suggested remedies.

=over

=item C<< Error message here, perhaps with %s placeholders >>

[Description of error here]

=item C<< Another error message here >>

[Description of error here]

[Et cetera, et cetera]

=back


=head1 CONFIGURATION AND ENVIRONMENT

=for author to fill in:
    A full explanation of any configuration system(s) used by the
    module, including the names and locations of any configuration
    files, and the meaning of any environment variables or properties
    that can be set. These descriptions must also include details of any
    configuration language used.
  
Parallelize requires no configuration files or environment variables.


=head1 DEPENDENCIES

=for author to fill in:
    A list of all the other modules that this module relies upon,
    including any restrictions on versions, and an indication whether
    the module is part of the standard Perl distribution, part of the
    module's distribution, or must be installed separately. ]

None.


=head1 INCOMPATIBILITIES

=for author to fill in:
    A list of any modules that this module cannot be used in conjunction
    with. This may be due to name conflicts in the interface, or
    competition for system or program resources, or due to internal
    limitations of Perl (for example, many modules that use source code
    filters are mutually incompatible).

None reported.


=head1 BUGS AND LIMITATIONS

=for author to fill in:
    A list of known problems with the module, together with some
    indication Whether they are likely to be fixed in an upcoming
    release. Also a list of restrictions on the features the module
    does provide: data types that cannot be handled, performance issues
    and the circumstances in which they may arise, practical
    limitations on the size of data sets, special cases that are not
    (yet) handled, etc.

No bugs have been reported.

Please report any bugs or feature requests to
C<bug-parallelize@rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org>.


=head1 AUTHOR

Nelo Onyiah  C<< <nelo.onyiah@gmail.com> >>


=head1 LICENCE AND COPYRIGHT

Copyright (c) 2008, Nelo Onyiah C<< <nelo.onyiah@gmail.com> >>. All rights reserved.

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself. See L<perlartistic>.


=head1 DISCLAIMER OF WARRANTY

BECAUSE THIS SOFTWARE IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY
FOR THE SOFTWARE, TO THE EXTENT PERMITTED BY APPLICABLE LAW. EXCEPT WHEN
OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER PARTIES
PROVIDE THE SOFTWARE "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER
EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE
ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE SOFTWARE IS WITH
YOU. SHOULD THE SOFTWARE PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL
NECESSARY SERVICING, REPAIR, OR CORRECTION.

IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING
WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MAY MODIFY AND/OR
REDISTRIBUTE THE SOFTWARE AS PERMITTED BY THE ABOVE LICENCE, BE
LIABLE TO YOU FOR DAMAGES, INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL,
OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR INABILITY TO USE
THE SOFTWARE (INCLUDING BUT NOT LIMITED TO LOSS OF DATA OR DATA BEING
RENDERED INACCURATE OR LOSSES SUSTAINED BY YOU OR THIRD PARTIES OR A
FAILURE OF THE SOFTWARE TO OPERATE WITH ANY OTHER SOFTWARE), EVEN IF
SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE POSSIBILITY OF
SUCH DAMAGES.

=cut

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
