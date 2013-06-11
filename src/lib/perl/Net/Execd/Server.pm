package Net::Execd::Server;
use strict;
use Data::Hub qw($Hub);
use Net::Execd::Command;
use base qw(Net::Server::PreFork);

our $Timeout = 5;
our $Record_Size = 40;

sub process_request {
  my $self = shift;
  my $cmd_id = undef;
  eval {
    local $SIG{ALRM} = sub { die 'TIMEOUT'; };
    my $alarm_bak = alarm($Timeout);
    read STDIN, $cmd_id, $Record_Size;
    alarm($alarm_bak);
  };
  if ($@ eq 'TIMEOUT') {
    $self->log(1, "Request timed out");
    print "Request timed out\n";
    return;
  }
  my $cmd = Net::Execd::Command->new($cmd_id);
  $self->log(1, "pid=$$");
  $cmd->run();
}

sub post_client_connection_hook {
  my $self = shift;
  $Hub->expire();
}

1;

__END__

=pod:name Command execution service

=pod:synopsis

  #!/usr/bin/perl -w
  use strict;
  use Net::Execd::Server;
  Net::Execd::Server->run();

=pod:description

See also L<Net::Server>
See also C</etc/execd/conf/execd.hf>
See also C</etc/execd/conf/commands.hf>
See also C</etc/execd/scripts>

=cut
