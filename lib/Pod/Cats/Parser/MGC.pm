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

    my $ret = $self->sequence_of(sub { 
        my $odre;
        if ($self->scope_level) {
            $odre = qr/\Q$self->{delimiters}/;
        }
        else {
            $odre = qr/[\Q$self->{delimiters}\E]/; 
        }

        $self->any_of(
            sub {
                # After we're in 1 level we've committed to an exact delimiter.
                my $tag = $self->expect( qr/[A-Z](?=$odre)/ );

                $self->commit;

                my $odel;
                
                if ($self->scope_level) {
                    $odel = $self->expect( $self->{delimiters} );
                }
                else {
                    $odel = $self->expect( $odre );
                    $odel .= $self->expect( qr/\Q$odel\E*/ );
                }

                (my $cdel = $odel) =~ tr/<({[/>)}]/;

                # The opening delimiter is the same char repeated, never
                # different ones.
                local $self->{delimiters} = $odel;

                if ($tag eq 'Z') {
                    $self->expect( $cdel );
                    $self->{level}--;
                    return;
                }

                my $retval = $pod_cats->handle_entity( 
                    $tag => @{ 
                        $self->scope_of( undef, \&parse, $cdel ) 
                    }
                );
                return $retval;
            },

            sub { 
                if ($self->scope_level) {
                    return $self->substring_before( qr/[A-Z]\Q$self->{delimiters}/ );
                }
                else {
                    return $self->substring_before( qr/[A-Z]$odre/ );
                }
            },
        )
   });
}

1;
