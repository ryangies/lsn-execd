package Net::Execd::Client;
use strict;
our $VERSION = 0;

use Exporter;
use Perl::Module;
use IO::Socket;

our @EXPORT_OK = qw(execd_submit);
our %EXPORT_TAGS = (all => [@EXPORT_OK]);
push our @ISA, qw(Exporter);

sub execd_submit {
  my ($host, $port, $cmd_id) = @_;
  my $client = __PACKAGE__->new(PeerAddr => $host, PeerPort => $port);
  $client->submit($cmd_id);
}

our $Defaults = {
  Proto => 'tcp',
  PeerAddr => '172.0.0.1',
  PeerPort => 2369,
};

sub new {
  my $classname = ref($_[0]) ? ref(shift) : shift;
  my $members = overlay(overlay({}, $Defaults), {@_});
  my $self = bless $members, $classname;
  $self;
}

sub submit {
  my $self = shift;
  my $cmd_id = shift;
  my $handle = IO::Socket::INET->new(%$self) or die $!;
  $handle->autoflush(1);
  print $handle $cmd_id;
  my $out = undef;
  while (defined (my $line = <$handle>)) {
    $out = '' unless defined($out);
    $out .= $line;
  }
  $out;
}

1;

__END__

=pod:name Submit requests to the execution service

=pod:synopsis

As a command-line script:

  #!/usr/bin/perl -w
  use strict;
  use Net::Execd::Client qw(execd_submit);
  my $cmd_id = 'c58a5002d1c74969d19178c5b3360fca3bf22df3';
  print execd_submit('localhost', 7890, $cmd_id);

As an object:

  #!/usr/bin/perl -w
  use strict;
  use Net::Execd::Client;
  my $client = Net::Execd::Client->new(
    PeerAddr => 'localhost',
    PeerPort => 7890,
  );
  my $cmd_id = 'c58a5002d1c74969d19178c5b3360fca3bf22df3';
  my $out = $client->submit($cmd_id);

=pod:description

Submit a request to an execution server (L<Net::Execd::Server>).  In both of
the above cases a request is made to execute the command identified by
C<c58a5002d1c74969d19178c5b3360fca3bf22df3> to the server running at
C<localhost> on port C<7890>.

=cut
