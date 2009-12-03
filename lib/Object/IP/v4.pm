use MooseX::Declare;

class Object::IP::v4 {

  our $VERSION = '0.02';

  use MooseX::Types::IPv4 qw /cidr ip2 ip3 ip4 ip4_binary
                              netmask netmask4_binary/;


  ## Internally, we store the ip address and netmask in binary.
  has 'ip'        => (
    is            => 'ro',
    isa           => ip4_binary,
    default       => '00001010000000000000000000000001',
    lazy          => 1,
    coerce        => 1,
  );


  has 'netmask'   => (
    is            => 'ro',
    isa           => netmask4_binary,
    default       => '11111111111111111111111100000000',
    lazy          => 1,
    coerce        => 1,
  );


  method broadcast ( ) {
    return(substr($self->ip(),0,$self->cidr()).'1'x(32-$self->cidr()));
  }


  method broadcast4 ( ) {
    return($self->bin2ip4($self->broadcast()));
  }


  method cidr ( cidr $cidr? ) {
    #if( $cidr ) {
    #  $self->netmask($self->cidr2bin($cidr));
    #}
    return($self->bin2cidr($self->netmask()));
  }


  ## Prototyped in.
  method ip2 ( ip2 $ip? ) {
    #if( $ip ) {
    #  $self->ip($self->ip2bin2($ip));
    #}
    return($self->bin2ip2($self->ip()));
  }


  ## Prototyped in.
  method ip3 ( ip3 $ip? ) {
    #if( $ip ) {
    #  $self->ip($self->ip2bin3($ip));
    #}
    return($self->bin2ip3($self->ip()));
  }


  method ip4 ( ip4 $ip? ) {
    #if( $ip ) {
    #  $self->ip($self->ip2bin4($ip));
    #}
    return($self->bin2ip4($self->ip()));
  }


  # 224.0.0.0/4
  method is_class_d ( ) {
    return 1 if( (3758096384 <= $self->bin2dec($self->ip)) &&
                 ($self->bin2dec($self->ip) <= 4026531839) );
    return 0;
  }


  # 240.0.0.0/4
  method is_class_e ( ) {
    return 1 if( (4026531840 <= $self->bin2dec($self->ip)) &&
                 ($self->bin2dec($self->ip) <= 4294967295) );
    return 0;
  }


  # 169.254.0.0/16
  method is_linklocal ( ) {
    return 1 if( (2851995648 <= $self->bin2dec($self->ip)) &&
                 ($self->bin2dec($self->ip) <= 2852061183) );
    return 0;
  }


  # 127.0.0.0/8
  method is_localhost ( ) {
    return 1 if( (2130706432 <= $self->bin2dec($self->ip)) &&
                 ($self->bin2dec($self->ip) <= 2147483647) );
    return 0;
  }


  ## See RFC3330 for reserved address spaces
  # 128.0.0.0/16, 191.255.0.0/16, 192.0.0.0/24, 223.255.255.0/24
  method is_reserved ( ) {
    return 1 if( (2147483648 <= $self->bin2dec($self->ip)) &&
                 ($self->bin2dec($self->ip) <= 2164260863) );
    return 1 if( (3221159936 <= $self->bin2dec($self->ip)) &&
                 ($self->bin2dec($self->ip) <= 3221225471) );
    return 1 if( (3221225472 <= $self->bin2dec($self->ip)) &&
                 ($self->bin2dec($self->ip) <= 3221225727) );
    return 1 if( (3758096128 <= $self->bin2dec($self->ip)) &&
                 ($self->bin2dec($self->ip) <= 3758096383) );
    return 0;
  }


  # 10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16
  method is_rfc1918 ( ) {
    return 1 if( (167772160 <= $self->bin2dec($self->ip)) &&
                 ($self->bin2dec($self->ip) <= 184549375) );
    return 1 if( (2886729728 <= $self->bin2dec($self->ip)) &&
                 ($self->bin2dec($self->ip) <= 2887778303) );
    return 1 if( (3232235520 <= $self->bin2dec($self->ip)) &&
                 ($self->bin2dec($self->ip) <= 3232301055) );
    return 0;
  }


  # 198.18.0.0/15
  method is_rfc2544 ( ) {
    return 1 if( (3323068416 <= $self->bin2dec($self->ip)) &&
                 ($self->bin2dec($self->ip) <= 3323199487) );
    return 0;
  }


  # 192.0.2.0/24
  method is_testnet ( ) {
    return 1 if( (3221225984 <= $self->bin2dec($self->ip)) &&
                 ($self->bin2dec($self->ip) <= 3221226239) );
    return 0;
  }


  method netmask4 ( netmask $netmask? ) {
    #if( $netmask ) {
    #  $self->netmask($self->ip2bin4($netmask));
    #}
    return $self->bin2ip4($self->netmask());
  }


  method netmask4_inv ( ) {
    return $self->bin2ip4_inv($self->netmask());
  }


  method network ( ) {
    return($self->ip() & $self->netmask() );
  }


  method network4 ( ) {
    return($self->bin2ip4($self->network()));
  }


  method next_ip ( ) {
    my $next_ip = $self->_increment( $self->ip4() );
    my $next_net = ( $self->ip2bin4($next_ip) & $self->netmask() );
    if( ( $self->network() eq $next_net &&
          $next_ip ne $self->bin2ip4($self->broadcast()) ) ||
        ( $self->cidr() == 31 || $self->cidr() == 32 ) ) {
      return $self->new( ip => $next_ip,
                         netmask => $self->netmask() );
    }
    return 0;
  }


  method previous_ip ( ) {
    my $prev_ip = $self->_decrement( $self->ip4() );
    my $prev_net = ( $self->ip2bin4($prev_ip) & $self->netmask() );
    if( ( $self->network() eq $prev_net &&
          $prev_ip ne $self->bin2ip4($self->network()) ) ||
        ( $self->cidr() == 31 || $self->cidr() == 32 ) ) {
      return $self->new( ip => $prev_ip,
                         netmask => $self->netmask() );
    }
    return 0;
  }


################################################################################
#########                                                              #########
######                                                                    ######
###                             Number Translators                           ###
######                                                                    ######
#########                                                              #########
################################################################################


  method bin2cidr ( $bin ) {
    return(rindex($bin,'1')+1);
  }


  method bin2dec ( $bin) {
    return(unpack('N',pack('B32',$bin)));
  }


  method bin2ip2 ( $bin ) {
    return(join('.',unpack('CL',pack('B32',$bin))));
  }


  method bin2ip3 ( $bin ) {
    return(join('.',unpack('C2S',pack('B32',$bin))));
  }


  method bin2ip4 ( $bin ) {
    return(join('.',unpack('C4',pack('B32',$bin))));
  }


  method bin2ip4_inv ( $bin ) {
    return(join('.',unpack('C4',pack('B32',~$bin))));
  }


  method bin2hex ( $bin ) {
    return('0x' . unpack('H*',pack('B32',$bin)));
  }


  method cidr2bin ( cidr $cidr ) {
    return("1" x $cidr . "0" x (32 - $cidr));
  }


  method ip2bin2 ( ip2 $ip ) {
    return(unpack('B32', pack('CL', split(/\D/, $ip))));
  }


  method ip2bin3 ( ip3 $ip ) {
    return(unpack('B32', pack('C2S', split(/\D/, $ip))));
  }


  method ip2bin4 ( ip4 $ip ) {
    return(unpack('B32', pack('C4', split(/\D/, $ip))));
  }



################################################################################
#########                                                              #########
######                                                                    ######
###                              Private functions                           ###
######                                                                    ######
#########                                                              #########
################################################################################


  # This cares not for the boundries of subnet masks, networks or broadcasts.
  method _decrement ( $address ) {
    my @quad = split /\./, $address;

    ## This could maybe be done simpler...
    if( $quad[3]>0 ) { $quad[3]-- }
    else {
      if( $quad[2]>0 ) { $quad[3] = 255; $quad[2]--; }
      else {
        if( $quad[1]>0 ) { $quad[3] = $quad[2] = 255; $quad[1]--; }
        else {
          if( $quad[0]>0) { $quad[3] = $quad[2] = $quad[1] = 0; $quad[0]--; }
        }
      }
    }
    return( join('.', @quad) );
  }


  # This cares not for the boundries of subnet masks, networks or broadcasts.
  method _increment ( $address ) {
    my @quad = split /\./, $address;

    ## This could maybe be done simpler...
    if( $quad[3]<255 ) { $quad[3]++ }
    else {
      if( $quad[2]<255 ) { $quad[3] = 0; $quad[2]++; }
      else {
        if( $quad[1]<255 ) { $quad[3] = $quad[2] = 0; $quad[1]++; }
        else {
          if( $quad[0]<255 ) { $quad[3] = $quad[2] = $quad[1] = 0; $quad[0]++; }
        }
      }
    }
    return( join('.', @quad) );
  }


}
################################################################################

no MooseX::Declare;

1;

__END__

=head1 NAME

Object::IP::v4 - Moose Object for IPv4 Addresses

=head1 SYNOPSIS

  use Object::IP::v4;

  # We try stay pretty loose on what we'll take in for object creation, so
  my $ip = new Object::IP::v4 ( ip => "172.16.1.1",
                                netmask => "255.255.255.0" );
  # is the same as
  my $ip = new Object::IP::v4 ( ip =>"10101100000100000000001001100001",
                                netmask => "24" );
  # As you see, the dot-quad, cidr, and binary notation are all valid ways to
  # create a new instance. Internally, we store it all as the 32bit binary
  # because it's the lowest common denominator for ip addresses.


  print "My ip address is " . $ip->ip() . "\n";     # Prints the binary
  print "My ip address is " . $ip->ip4() . "\n";    # Prints the dot-quad

  print "My netmask is " . $ip->netmask() . "\n";   # Prints the binary
  print "My netmask is " . $ip->netmask4() . "\n";  # Prints the dot-quad
  print "My cidr is " . $ip->cidr() . "\n";         # Print the cidr mask


  # And we can even easily get the inverse mask
  print "Inverse netmask is " . $ip->netmask4_inv() . "\n"; # dot-quad inverse


  # What is the next or previous ip address in the block.
  my $next_ip = $ip->next_ip();
  print "The next ip address is " . $next_ip->ip4() . "\n" if $next_ip;

  my $prev_ip = $ip->previous_ip();
  print "The previous ip address is " . $prev_ip->ip4() . "\n" if $prev_ip;

  --OR--

  print "The next ip address is " . $ip->next_ip->ip4() . "\n";

  # next_ip() will return false if you are currently at the last ip address in
  # the objects block. i.e if your ip is 172.16.0.254/24, calling next_ip()
  # will return false, because 172.16.0.255 is the broadcast address and not
  # a valid ip address. This is also the same behaviour of previous_ip()
  # The caveat here is if the CIDR is /31 or /32, since those don't strictly
  # adhear to the concept of network and broadcast address's


  ## We can easily see the network and broadcast address in our specified range

  print "Broadcast Address: " . $ip->broadcast() . "\n"; ## Prints the binary
  print "Broadcast Address: " . $ip->broadcast4() . "\n"; # Prints the dot-quad

  print "Network Address: " . $ip->network() . "\n"; ## Prints the binary
  print "Network Address: " . $ip->network4() . "\n"; # Prints the dot-quad


  # We also have some pretty generic true-false tests to determine more info
  # about our IP address

  $self->is_class_d();    # 224.0.0.0/4
  $self->is_class_e();    # 240.0.0.0/4
  $self->is_linklocal();  # 169.254.0.0/16
  $self->is_localhost();  # 127.0.0.0/8
  $self->is_reserved();   # See RFC3330; 128.0.0.0/16, 191.255.0.0/16,
                          #              192.0.0.0/24, 223.255.255.0/24

  $self->is_rfc1918();    # 10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16
  $self->is_rfc2544();    # 198.18.0.0/15
  $self->is_testnet();    # 192.0.2.0/24


=head1 DESCRIPTION

Provides an object for an IPv4 address.


=head1 SEE ALSO

=over

=item L<MooseX::Types::IPv4>

=iten L<MooseX::Declare>

=back

=head1 AUTHOR

Kyle Hultman, E<lt>khultman@gmail.com<gt>

=head1 COPYRIGHT

Copyright 2009 the above L<AUTHORS>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.


=cut
