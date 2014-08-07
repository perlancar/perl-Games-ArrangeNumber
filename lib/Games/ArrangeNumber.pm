package Games::ArrangeNumber;

# DATE
# VERSION

use Color::ANSI::Util qw(ansibg ansifg);
use List::Util qw(shuffle);
use Term::ReadKey;
use Time::HiRes qw(sleep);

use 5.010;
use Mo qw(build default);

has frame_rate   => (is => 'rw', default=>15);
has board_size   => (is => 'rw', default=>4);
has needs_redraw => (is => 'rw', default=>1);
has num_moves    => (is => 'rw');
has start_time   => (is => 'rw');
has board        => (is => 'rw'); # a 2-d matrix of numbers

sub draw_board {
    my $self = shift;
    return unless $self->needs_redraw;
    use DD; dd $self->board;
    $self->needs_redraw(0);
}

# borrowed from Games::2048
sub read_key {
    my $self = shift;
    state @keys;

    if (@keys) {
        return shift @keys;
    }

    my $char;
    my $packet = '';
    while (defined($char = ReadKey -1)) {
        $packet .= $char;
    }

    while ($packet =~ m(
                           \G(
                               \e \[          # CSI
                               [\x30-\x3f]*   # Parameter Bytes
                               [\x20-\x2f]*   # Intermediate Bytes
                               [\x40-\x7e]    # Final Byte
                           |
                               .              # Otherwise just any character
                           )
                   )gsx) {
        push @keys, $1;
    }

    return shift @keys;
}

sub has_won {
    my $self = shift;
    join(",", map { @$_ } @{$self->board}) eq
        join(",", 1 .. ($self->board_size ** 2 -1), 0);
}

sub new_game {
    my $self = shift;

    my $s = $self->board_size;
    die "Board size must be between 2 and 7 \n" unless $s >= 2 && $s <= 7;

    my $board;
    while (1) {
        my @num0 = (1 .. ($s ** 2 -1), 0);
        my @num  = shuffle @num0;
        redo if join(",",@num0) eq join(",",@num);
        $board = [];
        while (@num) {
            push @$board, [splice @num, 0, $s];
        }
        last;
    }
    $self->board($board);
    $self->num_moves(0);
    $self->start_time(time());

    $self->needs_redraw(1);
    $self->draw_board;
}

sub init {
    my $self = shift;
    $SIG{INT}     = sub { $self->cleanup; exit 1 };
    $SIG{__DIE__} = sub { warn shift; $self->cleanup; exit 1 };
    ReadMode "cbreak";
}

sub cleanup {
    my $self = shift;
    ReadMode "normal";
}

sub run {
    my $self = shift;

    $self->init;
    $self->new_game;
    while (1) {
        my $key = $self->read_key // '';
        use DD; dd $key;
        if ($key eq 'q' || $key eq 'Q') {
            last;
        } elsif ($key eq 'r' || $key eq 'R') {
            $self->new_game;
        } elsif ($key eq "\e[D") { # left arrow
        } elsif ($key eq "\e[A") { # up arrow
        } elsif ($key eq "\e[C") { # right arrow
        } elsif ($key eq "\e[B") { # down arrow
        }
        $self->draw_board;
        sleep 1/$self->frame_rate;
    }
    $self->cleanup;
}

# ABSTRACT: Arrange number game

=for Pod::Coverage ^(.+)$
