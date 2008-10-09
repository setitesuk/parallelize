package Parallelize;

use 5.010_000;

use warnings;
use strict;

use version;
use autodie qw(:system :file);

use Cwd qw(cwd abs_path);
use File::Spec;

use Moose;
use Moose::Util::TypeConstraints;
use IPC::System::Simple qw(capture $EXITVAL EXIT_ANY);

our $VERSION = qv('0.1.5');

# Module implementation here

# Define attribute files:
subtype 'ExistingFile'
  => as 'Str'
  => where { -e };

has 'files' => (
    is         => 'ro',
    isa        => 'ArrayRef[ExistingFile]',
    required   => 1,
    auto_deref => 1,
);

# Define attribute code:
subtype 'Code'
  => as 'Str'
  => where { $_ ne q{} };

coerce 'Code'
  => from 'ArrayRef'
  => via { join q{}, @{$_} };

# Need a coersion here to make sub { ... } a valid argument.
# Consider using Storage or Data::Dumper for this.
#  => from 'CodeRef'
#    => via { ... }

has 'code' => (
    is     => 'ro',
    isa    => 'Code',
    coerce => 1,
    writer => 'set_code',
);

# Define an exec_file attribute:
has 'exec_file' => (
    is      => 'rw',
    default => sub {
        File::Spec->catfile( cwd, '.users-code' );
    },
);

# Define a jobs_file attribute:
has 'jobs_file' => (
    is      => 'rw',
    isa     => 'Str',
    default => sub {
        File::Spec->catfile( cwd, '.parallelize' );
    },
);

sub BUILD {
    my ( $self, $params ) = @_;

    # Make sure you have files to play with ...
    # A nicer error message perhaps =)
    if ( scalar @{ $params->{files} } == 0 ) {
	confess 'Please specify the files you wish to work on'
    }

    # Set the code if you have one
    if ( $params->{code} ) {
        $self->set_code( $params->{code} );
    }

    my $code_file = $self->exec_file();

    # Write code to .user-code if no exec_file was specified
    # NOTE: The code must be defined for this bit to work ... duh!
    if ( !$params->{exec_file} && $params->{code} ) {
        open my $code_handle, '>', $code_file;
        print {$code_handle} $self->code();
        close $code_handle;

        # Make it executable
        system("chmod 0755 $code_file");
    }

    # Check that it compiles ...
    # NOTE: Would like to silence the output of this.
    # Perhaps we can use string form of eval?? Would prefer
    # IPC::System::Simple::capture() for this.
    # NOTE: May have to skip this entirely if you want to
    # allow programs written in other languages. Either that
    # come up with something very clever ...
    # $self->_verify_compilation( )
    my $output = capture("perl -c $code_file");
    if ( $output =~ m/\A \w+ syntax ok \z/xms ) {
	confess "Your code does not compile: ($output)";
    }

    # Execute the commands on each file
    open my $jobs_file_handle, '>', $self->jobs_file();

    for my $file ( $self->files ) {
        say {$jobs_file_handle} abs_path($code_file) . q{ } . $file;
    }

    close $jobs_file_handle;

    # Make the jobs file executable
    my $jobs_file = $self->jobs_file;
    system("chmod 0755 $jobs_file");

    return $self;
}

# Now submit the jobs to the farm as a job array (can pass bsub arguments here)
sub run {
    my ( $self, %args ) = @_;

    system($self->jobs_file);
}


# NOTE:
# Don't forget to remove the files created when everything's
# finished. Perhaps you can try File::Temp again with UNLINK
# set to true.
#sub DEMOLISH {
#    my ($self) = @_;
#    unlink $self->exec_file # ... etc
#}

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
        jobs_file => $script, # preferably ...
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

=over 4

=item IPC::System::Simple::system()

Currently this requires me to stringify the command ... "$command". Look into
other means of running system commands that don't require this.

=back

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
