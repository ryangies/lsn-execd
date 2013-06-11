package Net::Execd::Command;
use strict;
use Data::Hub qw($Hub);

our $Timeout = 60; # Execution time
our $Key_Length = 40; # Command identifier length

sub new {
  my $classname = ref($_[0]) ? ref(shift) : shift;
  my $self = bless {cmd_id => shift}, $classname;
  $self;
}

sub run {
  my $self = shift;
  my $cmd_id = $self->{cmd_id};

  length($cmd_id) != $Key_Length and die "Invalid cmd_id size";
  $cmd_id !~ /^[a-z0-9]+$/ and die "Invalid cmd_id characters";

  my $cmd = $Hub->get("/conf/commands.hf/$cmd_id") or die "No such command";
  my $cmdline = $cmd->{command};
  my $path = $cmd->{path} || '/bin:/usr/bin';
  my $msgfmt = 'Execute: pid="%s" cmd="%s"';

  $ENV{PATH} = $path;

  eval {
    local $SIG{ALRM} = sub { die 'TIMEOUT'; };
    open(CMDOUT, "$cmdline |") or die "Cannot fork: $!";
    while (<CMDOUT>) {
      print $_;
    }
    close CMDOUT or die "Bad command: $! $?";
  };
  $@ eq 'TIMEOUT' and return;
}

1;
