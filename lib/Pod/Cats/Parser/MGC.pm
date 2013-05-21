package Pod::Cats::Parser::MGC;
use strict;
use warnings;
use 5.010;

use parent qw(Parser::MGC);

sub new {
    my $self = shift->SUPER::new(@_);
    my %o = @_;
    $self->{obj} = $o{object} or die "Expected argument 'object'";
    $self->{delimiters} = $o{delimiters} || "<";

    return $self;
}

sub parse {
    my $self = shift;
    my $pod_cats = $self->{obj};

    # Can't grab the whole lot with one re (yet) so I will grab one and expect
    # more.
    my $odre = qr/[\Q$self->{delimiters}\E]/; 

    my $ret = $self->sequence_of(sub { 
        $self->any_of(
            sub { 
                my $tag = $self->expect( qr/[A-Z](?=$odre)/ );
                $self->commit;

                my $odel = $self->expect( $odre );
                $odel .= $self->expect( qr/\Q$odel\E*/ );

                (my $cdel = $odel) =~ tr/<({[/>)}]/;

                # The opening delimiter is the same char repeated, never
                # different ones.
                local $self->{delimiters} = substr $odel, 0, 1;

                return [ $pod_cats->handle_entity( 
                    $tag => @{ 
                        $self->scope_of( undef, \&parse, $cdel ) 
                    }
                ) ] unless $tag eq 'Z';

                return undef;
            },

            sub { 
                my $r = $self->substring_before( qr/[A-Z]$odre/ );
                $r;
            },
        )
   });
}

1;
