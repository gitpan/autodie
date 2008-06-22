package autodie::exception::system;
use 5.008;
use strict;
use warnings;
use base 'autodie::exception';
use Carp qw(croak);
use Scalar::Util qw(refaddr);

our $VERSION = '1.10_06';

=head1 NAME

autodie::exception::system - Exceptions from autodying system().

=head1 SYNOPSIS

    eval {
        use autodie;

        system($cmd, @args);

    };

    if (my $E = $@) {
        say "Ooops!  ",$E->caller," had problems: $@";
    }


=head1 DESCRIPTION

B<NOTE!  This is BETA code.  It is NOT the final release.  Implementation
and interface may change!>  This is I<especially> true for this class.

This is a L<autodie::exception> class for failures from the
C<system> command.

=cut

# TODO and DANGER!
#
# We're using {refaddr $this} everywhere, rather than just '$this'
# because otherwise we end up in an endless recursive loop, presumably as
# perl tries to stringify '$this' for the hash lookup.
#
# For some reason the $message_of{$this} doesn't cause the problem
# in _init() - it seems to store fine.  However we do end up with
# pain and suffering when we try to look it up again in stringify.
#
# This may be a bug in fieldhashes, or it may be something that
# I'm missing.  In the meantime, we're using refaddr.
#
# As the pod says, this code will change.

my(
    %message_of,
);

sub _init {
    my ($this, %args) = @_;

    $message_of{refaddr $this} = $args{message}
        || croak "'message' arg not supplied to autodie::exception::system->new";

    return $this->SUPER::_init(%args);

}

=head2 stringify

When stringified, C<autodie::exception::system> objects currently
use the message generated by L<IPC::System::Simple>.

=cut

sub stringify {

    my ($this) = @_;

    return $message_of{refaddr $this} . $this->add_file_and_line;

}

sub DESTROY {
    my ($this) = @_;

    delete $message_of{refaddr $this};

    $this->SUPER::DESTROY;
}

1;

__END__

=head1 LICENSE

Copyright (C)2008 Paul Fenwick

This is free software.  You may modify and/or redistribute this
code under the same terms as Perl 5.10 itself, or, at your option,
any later version of Perl 5.

=head1 AUTHOR

Paul Fenwick E<lt>pjf@perltraining.com.auE<gt>
